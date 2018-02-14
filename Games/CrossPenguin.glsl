// https://www.shadertoy.com/view/4dKXDG
/*

(06/11/16)

Some instructions on how to play:

Space: Used to start the game and restarting on Game Over.
Arrows: Move around the player character.
1-4: Change the render buffer resolution to get a
     big speedup (1 - 100%, 2 - 75%, 3 - 50%, 4 - 25%).

--------------------------------------

Known Issues:

- Some drivers might take long to compile the shader, we're currently looking into this.
- You might find that the player moves weirdly when jumping
  on water tiles, we'll try to figure out a better way to handle those cases.

Potential Issues:

- We haven't battle tested the shader on other GPUs than NVIDIA,
  so we don't know if they'll work at all.

*/

// =============================================================================
// START OF SHARED CODE
// =============================================================================

// -- Constants ----------------------------------------------------------------

// State constants.

const float kStateTitle      = 0.0;
const float kStateInGame     = 1.0;
const float kStateGameOver   = 2.0;
const float kStateRestarting = 3.0;

// Scene constants.

const float kSceneWidth         = 5.0;
const float kSceneMinTileSpeed  = 2.0;
const float kSceneMaxTileSpeed  = 2.0;

const float kSceneNumChunks     = 3.0;     // Number of pre-defined chunks in the scene.
const float kSceneChunkTiles    = 5.0;     // Number of tiles per chunk.
const float kSceneInvChunkTiles = 0.2;     // Inverse number of tiles per chunk.

const float kSceneTileSnow      = 0.0;     // Id of the snow tile.
const float kSceneTileIceRoad   = 1.0;     // Id of the ice road tile.
const float kSceneTileWater     = 2.0;     // Id of the water tile.

const float kBehavGround        = 0.0;
const float kBehavWater         = 1.0;
const float kBehavObstacle      = 2.0;
const float kBehavHazard        = 3.0;
const float kBehavOutOfScreen   = 4.0;

// Player motion constants.

const float kPlayerSpeed      = 5.0;
const float kPlayerJumpHeight = 0.3;

// State coordinates.

const vec2 kTexState1 = vec2(0.0, 0.0); // x   = Current state,  y  = State time, w = Init
const vec2 kTexState2 = vec2(1.0, 0.0); // xy  = Current coords, zw = Next coords
const vec2 kTexState3 = vec2(2.0, 0.0); // x   = Motion time, y = Rotation, z = NextRotation, w = Scale
const vec2 kTexState4 = vec2(3.0, 0.0); // xyz = Coordinates, w = Rotation
const vec2 kTexState5 = vec2(4.0, 0.0); // x   = Death cause, y = Death time, z = Score, w = Fb. Scale

// Misc constants.

const float kPi = 3.14159265359;
const float kOneOverPi = 0.31830988618;
const float kOmega = 1e20;

// -- Global values ------------------------------------------------------------

float gGameState;
float gGameStateTime;
float gGameInit;
float gGameSeed;
vec2  gPlayerCoords;
vec2  gPlayerNextCoords;
float gPlayerMotionTimer;
float gPlayerRotation;
float gPlayerNextRotation;
float gPlayerScale;
vec3  gPlayerVisualCoords;
float gPlayerVisualRotation;
float gPlayerDeathCause;
float gPlayerDeathTime;
float gScore;
float gFbScale;

// -- State functions ----------------------------------------------------------

float IsInside(vec2 p, vec2 c)
{
    vec2 d = abs(p - 0.5 - c) - 0.5;
    return -max(d.x, d.y);
}

vec4 LoadValue(vec2 st)
{
    return texture(iChannel0, (0.5 + st) / iChannelResolution[0].xy, -100.0);
}

void StoreValue(vec2 st, vec4 value, inout vec4 fragColor, in vec2 fragCoord)
{
    fragColor = (IsInside(fragCoord, st) > 0.0 )? value : fragColor;
}

void LoadState()
{
    vec4 state1 = LoadValue(kTexState1);
    vec4 state2 = LoadValue(kTexState2);
    vec4 state3 = LoadValue(kTexState3);
    vec4 state4 = LoadValue(kTexState4);
    vec4 state5 = LoadValue(kTexState5);
    
    gGameState            = state1.x;
    gGameStateTime        = state1.y;
    gGameSeed             = state1.z;
    gGameInit             = state1.w;
    gPlayerCoords         = state2.xy;
    gPlayerNextCoords     = state2.zw;
    gPlayerMotionTimer    = state3.x;
    gPlayerRotation       = state3.y;
    gPlayerNextRotation   = state3.z;
    gPlayerScale          = state3.w;
    gPlayerVisualCoords   = state4.xyz;
    gPlayerVisualRotation = state4.w;
    gPlayerDeathCause     = state5.x;
    gPlayerDeathTime      = state5.y;
    gScore                = state5.z;
    gFbScale              = state5.w;
}

void StoreState(inout vec4 fragColor, in vec2 fragCoord)
{
    vec4 state1 = vec4(gGameState, gGameStateTime, gGameSeed, gGameInit);
    vec4 state2 = vec4(gPlayerCoords, gPlayerNextCoords);
    vec4 state3 = vec4(gPlayerMotionTimer, gPlayerRotation, gPlayerNextRotation, gPlayerScale);
    vec4 state4 = vec4(gPlayerVisualCoords, gPlayerVisualRotation);
    vec4 state5 = vec4(gPlayerDeathCause, gPlayerDeathTime, gScore, gFbScale);
    
    StoreValue(kTexState1, state1, fragColor, fragCoord);
    StoreValue(kTexState2, state2, fragColor, fragCoord);
    StoreValue(kTexState3, state3, fragColor, fragCoord);
    StoreValue(kTexState4, state4, fragColor, fragCoord);
    StoreValue(kTexState5, state5, fragColor, fragCoord);
}

// -- Hashing functions --------------------------------------------------------

vec4 Hash(float p)
{
    vec2 h = vec2(p) * vec2(1.271,3.117) + gGameSeed;
    return texture(iChannel3, h / iChannelResolution[3].xy, -100.0);
}

vec4 Hash(vec2 p)
{
    vec2 h = p.xy * vec2(1.271,3.117) + gGameSeed;
    return texture(iChannel3, h / iChannelResolution[3].xy, -100.0);
}

vec4 Hash(vec3 p)
{
    vec2 h = p.xy * vec2(1.271,3.117) + p.z * vec2(1.833,4.192) + gGameSeed;
    return texture(iChannel3, h / iChannelResolution[3].xy, -100.0);
}

// -- Scene tile functions -----------------------------------------------------

// Procedural tile management.

float GetSceneTileIndex(float z)
{
    // The scene is separated into chunks of 5 consecutive tiles, where
    // each chunk is simply a predefined set of tiles.
    
    // First, determine the chunk index and it's type, based on that index.
    float chunkIndex = floor(z * kSceneInvChunkTiles);
    float chunkType  = floor(kSceneNumChunks * Hash(chunkIndex).x) * step(1.0, chunkIndex);
        
   	// Second, determine the tile number we're referring to inside the chunk.
	float tileNum = floor(kSceneChunkTiles * (z * kSceneInvChunkTiles - chunkIndex));
    
    // Finally, depending upon the chunk type, determine which tile occupies
    // that location.
	float tileIdx = 0.0;
	
	if (chunkType == 0.0)
	{
		tileIdx = kSceneTileSnow;
	}
	else if (chunkType == 1.0)
	{
		tileIdx = mix(kSceneTileIceRoad, kSceneTileSnow, step(1.5, tileNum));
		tileIdx = mix(tileIdx, kSceneTileIceRoad,        step(2.5, tileNum));
	}
	else if (chunkType == 2.0)
	{
		tileIdx = mix(kSceneTileSnow, kSceneTileWater, step(0.5, tileNum));
		tileIdx = mix(tileIdx, kSceneTileSnow,         step(2.5, tileNum));
	}
	
	return tileIdx;
}

// Snow tile management.

float GetSceneSnowTileTreeChance(float coords, float treeIdx)
{
    return step(0.5, Hash(vec2(coords, treeIdx)).x) * step(0.5, coords);
}

float GetSceneSnowTileTreeCoord(float coords, float treeIdx)
{
    return floor(-kSceneWidth + 2.0 * kSceneWidth * Hash(vec2(coords, treeIdx)).y);
}

// Water and ice tiles common management.

vec4 GetSceneTileVSS(float coords, float minWidth, float maxWidth, float playerCoef)
{
    vec4 t;
    vec3 h = Hash(coords).xyz;
    t.x = (kSceneMinTileSpeed + floor(kSceneMaxTileSpeed * h.x)) * (2.0 * step(0.5, h.y) - 1.0);
    t.y = floor(mix(minWidth, maxWidth, h.z));
    t.z = 2.0 * t.y;
    t.w = playerCoef;
    return t;
}

vec4 GetSceneTileVss(vec3 coordsTile)
{
    vec4 vss = vec4(0.0);
    
    if (coordsTile.z == kSceneTileWater)
        vss = GetSceneTileVSS(coordsTile.y, 3.0, 6.0, 1.0);

    if (coordsTile.z == kSceneTileIceRoad)
		vss = GetSceneTileVSS(coordsTile.y, 3.0, 8.0, 0.0);
    
    return vss;
}

// -- Scene gameplay functions -------------------------------------------------

// Tile gameplay management.

vec3 GetSceneCoordsTile(vec2 loc)
{
    return vec3(floor(loc), GetSceneTileIndex(loc.y));
}

float GetSceneTileLocalSpaceLoc(float loc, vec4 vss)
{
    loc = loc - iTime * vss.x;
    return vss.z * fract(loc / vss.z);
}

vec4 GetSceneTileVss(vec2 loc)
{
    vec3 coordsTile = GetSceneCoordsTile(loc);
    return GetSceneTileVss(coordsTile);
}

float GetSceneTileBehaviour(vec2 loc)
{
    vec3 coordsTile = GetSceneCoordsTile(loc);
    vec4 vss = GetSceneTileVss(coordsTile);
    
    // Anything below or above the scene width is an obstacle.
	float isObstacle = max(step(1.0, -coordsTile.y), step(kSceneWidth + 0.5, abs(coordsTile.x)));
	float isWater = 0.0;
    float isHazard = 0.0;
    float isOutOfScreen = 0.0;
    
    // Check for each tile case.
    if (coordsTile.z == kSceneTileSnow)
    {
        for (int i = 0; i < 5; i++)
        {
            float treeChance = GetSceneSnowTileTreeChance(coordsTile.y, float(i));
            float treeCoord = GetSceneSnowTileTreeCoord(coordsTile.y, float(i));
            
            isObstacle = max(isObstacle, treeChance * (1.0 - step(0.5, abs(coordsTile.x - treeCoord))));
        }
    }
    else if (coordsTile.z == kSceneTileWater)
    {
        isOutOfScreen = isObstacle;
        isObstacle = 0.0;
        
        float l = GetSceneTileLocalSpaceLoc(loc.x, vss);        
        if (l > vss.y) isWater = 1.0;
    }
    else if (coordsTile.z == kSceneTileIceRoad)
    {
        float l = GetSceneTileLocalSpaceLoc(loc.x, vss);
        if (l < 2.0) isHazard = 1.0;
    }
    
    float behav = kBehavGround;
    behav = mix(behav, kBehavWater, isWater);
    behav = mix(behav, kBehavHazard, isHazard);
    behav = mix(behav, kBehavObstacle, isObstacle);
    behav = mix(behav, kBehavOutOfScreen, isOutOfScreen);
    
    return behav;
}

vec2 GetNextCoordinates(vec2 loc)
{
    float behav = GetSceneTileBehaviour(loc);
    vec4 vss = GetSceneTileVss(loc);
    
    float lsloc = vss.w == 0.0 && behav != kBehavWater? loc.x : GetSceneTileLocalSpaceLoc(loc.x, vss);
    float lsloc0 = floor(lsloc) + 0.5;
    
    loc.y = floor(loc.y) + 0.5;
    loc.x += (lsloc0 - lsloc);    
    return loc;
}

// =============================================================================
// END OF SHARED CODE
// =============================================================================

// =============================================================================
// BEGIN OF FONT CODE
// =============================================================================

// --- Global values -----------------------------------------------------------

float gCharPadding  = 2.0;
vec2  gCharPrintPos = vec2(0.0);

// --- Character printing functions --------------------------------------------

float CharRect(vec2 p, vec2 b)
{
	vec2 d = abs(p) - b;
  	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float CharRect(vec2 p, float minX, float minY, float maxX, float maxY)
{
	vec2 minCoord = vec2(minX, minY);
	vec2 maxCoord = vec2(maxX, maxY);
	vec2 b = 0.5 * (maxCoord - minCoord);
    vec2 c = 0.5 * (maxCoord + minCoord);
    return CharRect(p - c, b);
}

float CharA(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;
	
    d = min(d, CharRect(p, 3.0, 3.0, 7.0, 12.0));
    d = min(d, CharRect(p, 9.0, 3.0, 13.0, 12.0));
    d = min(d, CharRect(p, 7.0, 7.0, 9.0, 9.0));
    d = min(d, CharRect(p, 4.0, 11.0, 12.0, 13.0));
    
    return d;
}

float CharB(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;
	
    d = min(d, CharRect(p, 3.0, 3.0, 7.0, 13.0));
    d = min(d, CharRect(p, 3.0, 3.0, 12.0, 5.0));
    d = min(d, CharRect(p, 3.0, 7.0, 12.0, 9.0));
    d = min(d, CharRect(p, 3.0, 11.0, 12.0, 13.0));
    d = min(d, CharRect(p, 9.0, 4.0, 13.0, 7.0));
    d = min(d, CharRect(p, 9.0, 9.0, 13.0, 12.0));
    return d;
}

float CharC(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 4.0, 7.0, 12.0));
    d = min(d, CharRect(p, 4.0, 3.0, 13.0, 5.0));
    d = min(d, CharRect(p, 4.0, 11.0, 13.0, 13.0));
    return d;
}

float CharD(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 3.0, 7.0, 13.0));
    d = min(d, CharRect(p, 9.0, 3.0, 12.0, 13.0));
    d = min(d, CharRect(p, 3.0, 3.0, 12.0, 5.0));
    d = min(d, CharRect(p, 3.0, 11.0, 12.0, 13.0));
    d = min(d, CharRect(p, 9.0, 4.0, 13.0, 12.0));
    return d;
}

float CharE(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 4.0, 7.0, 12.0));
    d = min(d, CharRect(p, 4.0, 3.0, 13.0, 5.0));
    d = min(d, CharRect(p, 4.0, 11.0, 13.0, 13.0));
    d = min(d, CharRect(p, 7.0, 7.0, 10.0, 9.0));
    return d;
}

float CharF(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 3.0, 7.0, 12.0));
    d = min(d, CharRect(p, 3.0, 7.0, 10.0, 9.0));
    d = min(d, CharRect(p, 4.0, 11.0, 13.0, 13.0));
    return d;
}

float CharG(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 4.0, 7.0, 12.0));
    d = min(d, CharRect(p, 4.0, 3.0, 13.0, 5.0));
    d = min(d, CharRect(p, 9.0, 3.0, 13.0, 9.0));
    d = min(d, CharRect(p, 8.0, 7.0, 13.0, 9.0));
    d = min(d, CharRect(p, 4.0, 11.0, 13.0, 13.0));
    return d;
}

float CharH(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 3.0, 7.0, 13.0));
    d = min(d, CharRect(p, 9.0, 3.0, 13.0, 13.0));
    d = min(d, CharRect(p, 3.0, 7.0, 13.0, 9.0));
    return d;
}

float CharI(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(11.0, 0.0);
	gCharPrintPos.x += 4.0 + gCharPadding;

    d = min(d, CharRect(p, 6.0, 3.0, 10.0, 13.0));
    return d;
}

float CharJ(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 3.0, 12.0, 5.0));
    d = min(d, CharRect(p, 9.0, 4.0, 13.0, 13.0));
    return d;
}

float CharK(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 3.0, 7.0, 13.0));
    d = min(d, CharRect(p, 3.0, 7.0, 12.0, 9.0));
    d = min(d, CharRect(p, 9.0, 3.0, 13.0, 7.0));
    d = min(d, CharRect(p, 9.0, 9.0, 13.0, 13.0));
    return d;
}

float CharL(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 3.0, 7.0, 13.0));
    d = min(d, CharRect(p, 3.0, 3.0, 13.0, 5.0));
    return d;
}

float CharM(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(5.0, 0.0);
	gCharPrintPos.x += 16.0 + gCharPadding;

    d = min(d, CharRect(p, 0.0, 3.0, 4.0, 13.0));
    d = min(d, CharRect(p, 6.0, 3.0, 10.0, 13.0));
    d = min(d, CharRect(p, 12.0, 3.0, 16.0, 12.0));
    d = min(d, CharRect(p, 0.0, 11.0, 15.0, 13.0));
    return d;
}

float CharN(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 3.0, 7.0, 13.0));
    d = min(d, CharRect(p, 3.0, 11.0, 12.0, 13.0));
    d = min(d, CharRect(p, 9.0, 3.0, 13.0, 12.0));
    return d;
}

float CharO(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 4.0, 7.0, 12.0));
    d = min(d, CharRect(p, 9.0, 4.0, 13.0, 12.0));
    d = min(d, CharRect(p, 4.0, 3.0, 12.0, 5.0));
    d = min(d, CharRect(p, 4.0, 11.0, 12.0, 13.0));
    return d;
}

float CharP(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 3.0, 7.0, 13.0));
    d = min(d, CharRect(p, 6.0, 7.0, 12.0, 9.0));
    d = min(d, CharRect(p, 9.0, 8.0, 13.0, 12.0));
    d = min(d, CharRect(p, 6.0, 11.0, 12.0, 13.0));
    return d;
}

float CharQ(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 4.0, 7.0, 12.0));
    d = min(d, CharRect(p, 9.0, 4.0, 13.0, 12.0));
    d = min(d, CharRect(p, 4.0, 3.0, 12.0, 5.0));
    d = min(d, CharRect(p, 4.0, 11.0, 12.0, 13.0));
    d = min(d, CharRect(p, 8.0, 1.0, 13.0, 3.0));
    return d;
}

float CharR(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 3.0, 7.0, 13.0));
    d = min(d, CharRect(p, 6.0, 7.0, 12.0, 9.0));
    d = min(d, CharRect(p, 9.0, 8.0, 13.0, 12.0));
    d = min(d, CharRect(p, 6.0, 11.0, 12.0, 13.0));
    d = min(d, CharRect(p, 9.0, 3.0, 13.0, 7.0));
    return d;
}

float CharS(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 3.0, 12.0, 5.0));
    d = min(d, CharRect(p, 4.0, 7.0, 12.0, 9.0));
    d = min(d, CharRect(p, 4.0, 11.0, 13.0, 13.0));
    d = min(d, CharRect(p, 9.0, 4.0, 13.0, 8.0));
    d = min(d, CharRect(p, 3.0, 8.0, 7.0, 12.0));
    return d;
}

float CharT(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 6.0, 3.0, 10.0, 13.0));
    d = min(d, CharRect(p, 3.0, 11.0, 13.0, 13.0));
    return d;
}

float CharU(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 4.0, 7.0, 13.0));
    d = min(d, CharRect(p, 9.0, 4.0, 13.0, 13.0));
    d = min(d, CharRect(p, 4.0, 3.0, 12.0, 5.0));
    return d;
}

float CharV(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 3.0, 7.0, 13.0));
    d = min(d, CharRect(p, 9.0, 4.0, 13.0, 13.0));
    d = min(d, CharRect(p, 4.0, 3.0, 12.0, 5.0));
    return d;
}

float CharW(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(5.0, 0.0);
	gCharPrintPos.x += 16.0 + gCharPadding;

    d = min(d, CharRect(p, 0.0, 3.0, 4.0, 13.0));
    d = min(d, CharRect(p, 6.0, 3.0, 10.0, 13.0));
    d = min(d, CharRect(p, 12.0, 4.0, 16.0, 13.0));
    d = min(d, CharRect(p, 0.0, 3.0, 15.0, 6.0));
    return d;
}

float CharX(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 3.0, 7.0, 7.0));
    d = min(d, CharRect(p, 9.0, 3.0, 13.0, 7.0));
    d = min(d, CharRect(p, 3.0, 9.0, 7.0, 13.0));
    d = min(d, CharRect(p, 9.0, 9.0, 13.0, 13.0));
    d = min(d, CharRect(p, 4.0, 7.0, 12.0, 9.0));
    return d;
}

float CharY(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 6.0, 3.0, 10.0, 7.0));
    d = min(d, CharRect(p, 3.0, 8.0, 7.0, 13.0));
    d = min(d, CharRect(p, 9.0, 8.0, 13.0, 13.0));
    d = min(d, CharRect(p, 4.0, 7.0, 12.0, 9.0));
    return d;
}

float CharZ(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 3.0, 13.0, 5.0));
    d = min(d, CharRect(p, 4.0, 7.0, 12.0, 9.0));
    d = min(d, CharRect(p, 3.0, 11.0, 13.0, 13.0));
    d = min(d, CharRect(p, 9.0, 8.0, 13.0, 13.0));
    d = min(d, CharRect(p, 3.0, 4.0, 7.0, 8.0));
    return d;
}

float Char0(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 4.0, 7.0, 12.0));
    d = min(d, CharRect(p, 9.0, 4.0, 13.0, 12.0));
    d = min(d, CharRect(p, 4.0, 3.0, 12.0, 5.0));
    d = min(d, CharRect(p, 4.0, 11.0, 12.0, 13.0));
    d = min(d, CharRect(p, 7.0, 7.0, 9.0, 9.0));
    return d;
}

float Char1(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(10.0, 0.0);
	gCharPrintPos.x += 8.0 + gCharPadding;

    d = min(d, CharRect(p, 7.0, 3.0, 11.0, 12.0));
    d = min(d, CharRect(p, 6.0, 11.0, 10.0, 13.0));
    return d;
}

float Char2(vec2 p, inout float d)
{
    return CharZ(p, d);
}

float Char3(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 3.0, 12.0, 5.0));
    d = min(d, CharRect(p, 9.0, 4.0, 13.0, 7.0));
    d = min(d, CharRect(p, 6.0, 7.0, 12.0, 9.0));
    d = min(d, CharRect(p, 9.0, 9.0, 13.0, 12.0));
    d = min(d, CharRect(p, 3.0, 11.0, 12.0, 13.0));
    return d;
}

float Char4(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 9.0, 3.0, 13.0, 13.0));
    d = min(d, CharRect(p, 4.0, 7.0, 13.0, 9.0));
    d = min(d, CharRect(p, 3.0, 8.0, 7.0, 13.0));
    return d;
}

float Char5(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 3.0, 12.0, 5.0));
    d = min(d, CharRect(p, 4.0, 7.0, 12.0, 9.0));
    d = min(d, CharRect(p, 3.0, 11.0, 13.0, 13.0));
    d = min(d, CharRect(p, 9.0, 4.0, 13.0, 8.0));
    d = min(d, CharRect(p, 3.0, 8.0, 7.0, 12.0));
    return d;
}

float Char6(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 4.0, 7.0, 12.0));
    d = min(d, CharRect(p, 4.0, 3.0, 12.0, 5.0));
    d = min(d, CharRect(p, 9.0, 4.0, 13.0, 8.0));
    d = min(d, CharRect(p, 3.0, 7.0, 12.0, 9.0));
    d = min(d, CharRect(p, 4.0, 11.0, 13.0, 13.0));
    return d;
}

float Char7(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 9.0, 3.0, 13.0, 12.0));
    d = min(d, CharRect(p, 3.0, 11.0, 12.0, 13.0));
    return d;
}

float Char8(vec2 p, inout float d)
{
	p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;

    d = min(d, CharRect(p, 3.0, 4.0, 7.0, 7.0));
    d = min(d, CharRect(p, 9.0, 4.0, 13.0, 7.0));
    d = min(d, CharRect(p, 3.0, 9.0, 7.0, 12.0));
    d = min(d, CharRect(p, 9.0, 9.0, 13.0, 12.0));
    d = min(d, CharRect(p, 4.0, 7.0, 12.0, 9.0));
    d = min(d, CharRect(p, 4.0, 3.0, 12.0, 5.0));
    d = min(d, CharRect(p, 4.0, 11.0, 12.0, 13.0));
    return d;
}

float Char9(vec2 p, inout float d)
{
    p -= gCharPrintPos - vec2(8.0, 0.0);
	gCharPrintPos.x += 10.0 + gCharPadding;
    
	d = min(d, CharRect(p, 3.0, 3.0, 12.0, 5.0));
    d = min(d, CharRect(p, 9.0, 4.0, 13.0, 12.0));
    d = min(d, CharRect(p, 4.0, 11.0, 12.0, 13.0));
    d = min(d, CharRect(p, 3.0, 8.0, 7.0, 12.0));
    d = min(d, CharRect(p, 4.0, 7.0, 13.0, 9.0));
    return d;
}

void CharSpace()
{
    gCharPrintPos.x += 10.0 + gCharPadding;
}

float CharDigit(vec2 p, float n, inout float d)
{
    n = floor(n);
    
    if (n == 0.0) return Char0(p, d);
    if (n == 1.0) return Char1(p, d);
    if (n == 2.0) return Char2(p, d);
    if (n == 3.0) return Char3(p, d);
    if (n == 4.0) return Char4(p, d);
    if (n == 5.0) return Char5(p, d);
    if (n == 6.0) return Char6(p, d);
    if (n == 7.0) return Char7(p, d);
    if (n == 8.0) return Char8(p, d);
    if (n == 9.0) return Char9(p, d);
    return d;
}

void Print(vec2 p, float n
           , inout float d)
{   
	for (int i = 5; i >= 0; i--)
    {
        float w = pow(10.0, float(i));
        float k = mod(n / w, 10.0);
        
        if (abs(n) > w || i == 0)
            CharDigit(p, k, d);
    }   
}    

// =============================================================================
// END OF FONT CODE
// =============================================================================

// =============================================================================
// START OF UI RENDER CODE
// =============================================================================

void RenderUI(inout vec4 fragColor, vec2 fragCoord, vec2 uv, float aspect)
{
    uv *= 128.0;
       
    // Render CROSSY PENGUIN logo upon the title screen or during the first
    // seconds of the game (with an animation!).
    
    if (gGameState == kStateTitle || (gGameState == kStateInGame && gGameStateTime < 4.0))
    {
        float logoSdf = kOmega;        
        vec2 logoUv = uv * 0.5;
        logoUv.x -= (gGameState == kStateInGame)? 500.0 * gGameStateTime * gGameStateTime : 0.0;
        logoUv.y += uv.x * 0.13;
                
        vec2 subLogoUv = logoUv * 3.0;
        
        gCharPrintPos = vec2(-34.0, 7.0);
        CharC(logoUv, logoSdf);
        CharR(logoUv, logoSdf);
        CharO(logoUv, logoSdf);
        CharS(logoUv, logoSdf);
        CharS(logoUv, logoSdf);
        CharY(logoUv, logoSdf);
        gCharPrintPos = vec2(-38.0, -7.0);
        CharP(logoUv, logoSdf);
        CharE(logoUv, logoSdf);
        CharN(logoUv, logoSdf);
        CharG(logoUv, logoSdf);
        CharU(logoUv, logoSdf);
        CharI(logoUv, logoSdf);
        CharN(logoUv, logoSdf);
        gCharPrintPos = vec2(-132.0, -40.0);
        CharA(subLogoUv, logoSdf);
        CharSpace();
        CharC(subLogoUv, logoSdf);
        CharR(subLogoUv, logoSdf);
        CharO(subLogoUv, logoSdf);
        CharS(subLogoUv, logoSdf);
        CharS(subLogoUv, logoSdf);
        CharY(subLogoUv, logoSdf);
        CharSpace();
        CharR(subLogoUv, logoSdf);
        CharO(subLogoUv, logoSdf);
        CharA(subLogoUv, logoSdf);
        CharD(subLogoUv, logoSdf);
        CharSpace();
        CharT(subLogoUv, logoSdf);
        CharR(subLogoUv, logoSdf);
        CharI(subLogoUv, logoSdf);
        CharB(subLogoUv, logoSdf);
        CharU(subLogoUv, logoSdf);
        CharT(subLogoUv, logoSdf);
        CharE(subLogoUv, logoSdf);
        
        fragColor.rgb = mix(fragColor.rgb, vec3(0.0), step(-3.0, -logoSdf));
        fragColor.rgb = mix(fragColor.rgb, vec3(1.0), step(0.0, -logoSdf));
    }
    
    // Render the score during the InGame state and hide on GameOver.
    
    if (gGameState == kStateInGame || (gGameState == kStateGameOver && gGameStateTime < 4.0))
    {
        float scoreSdf = kOmega;
        vec2 scoreUv = uv;
        
        if (gGameState == kStateInGame) scoreUv.y -= 64.0 - 64.0 * min(1.0, gGameStateTime);
        else                            scoreUv.y -= 64.0 * min(1.0, gGameStateTime);
        
        gCharPrintPos = vec2(-120.0 * aspect, 104.0);
        Print(scoreUv, gScore, scoreSdf);
        
        fragColor.rgb = mix(fragColor.rgb, vec3(0.0), step(-3.0, -scoreSdf));
        fragColor.rgb = mix(fragColor.rgb, vec3(1.0), step(0.0, -scoreSdf));
    }
    
    // Fade to blue upon GameOver and show score.
   
    if (gGameState == kStateGameOver || gGameState == kStateRestarting)
    {
        fragColor.rgb  = mix(fragColor.rgb, vec3(0.2, 0.7, 1.0), min(0.5, gGameStateTime));
        
        float gameOverSdf = kOmega;        
        vec2 gameOverUv = uv * 0.5;
        float gameOverTime = gGameState == kStateRestarting? 1.0 : min(gGameStateTime * 0.7, 1.0);
        
        gameOverUv.y -= 128.0 * abs(cos(2.0 * kPi * gameOverTime * gameOverTime)) * (1.0 - gameOverTime);
                       
        gCharPrintPos = vec2(-45.0, 0.0);
        CharG(gameOverUv, gameOverSdf);
        CharA(gameOverUv, gameOverSdf);
        CharM(gameOverUv, gameOverSdf);
        CharE(gameOverUv, gameOverSdf);
        CharSpace();
        CharO(gameOverUv, gameOverSdf);
        CharV(gameOverUv, gameOverSdf);
        CharE(gameOverUv, gameOverSdf);
        CharR(gameOverUv, gameOverSdf);
        
        fragColor.rgb = mix(fragColor.rgb, vec3(0.0), step(-3.0, -gameOverSdf));
        fragColor.rgb = mix(fragColor.rgb, vec3(1.0), step(0.0, -gameOverSdf));
        
        float messageSdf = kOmega;
        vec2 messageUv = uv * 1.5;
        float messageTime = gGameState == kStateRestarting? 1.0 : clamp(gGameStateTime * 0.7 - 1.0, 0.0, 1.0);
        
        messageUv.x -= 1024.0 * (1.0 - messageTime) * (1.0 - messageTime);
                 
        if (gPlayerDeathCause == kBehavWater)
        {
            gCharPrintPos = vec2(-170.0, -40.0);
            CharS(messageUv, messageSdf);
            CharE(messageUv, messageSdf);
            CharE(messageUv, messageSdf);
            CharM(messageUv, messageSdf);
            CharS(messageUv, messageSdf);
            CharSpace();
            CharL(messageUv, messageSdf);
            CharI(messageUv, messageSdf);
            CharK(messageUv, messageSdf);
            CharE(messageUv, messageSdf);
            CharSpace();
            CharT(messageUv, messageSdf);
            CharH(messageUv, messageSdf);
            CharI(messageUv, messageSdf);
            CharS(messageUv, messageSdf);
            CharSpace();
            CharP(messageUv, messageSdf);
            CharE(messageUv, messageSdf);
            CharN(messageUv, messageSdf);
            CharG(messageUv, messageSdf);
            CharU(messageUv, messageSdf);
            CharI(messageUv, messageSdf);
            CharN(messageUv, messageSdf);
            CharSpace();
            CharC(messageUv, messageSdf);
            CharA(messageUv, messageSdf);
            CharN(messageUv, messageSdf);
            CharT(messageUv, messageSdf);
            CharSpace();
            CharS(messageUv, messageSdf);
            CharW(messageUv, messageSdf);
            CharI(messageUv, messageSdf);
            CharM(messageUv, messageSdf);
        }
        else if (gPlayerDeathCause == kBehavOutOfScreen)
        {
            gCharPrintPos = vec2(-220.0, -40.0);
            CharY(messageUv, messageSdf);
            CharO(messageUv, messageSdf);
            CharU(messageUv, messageSdf);
            CharSpace();
            CharW(messageUv, messageSdf);
            CharE(messageUv, messageSdf);
            CharN(messageUv, messageSdf);
            CharT(messageUv, messageSdf);
            CharSpace();
            CharO(messageUv, messageSdf);
            CharN(messageUv, messageSdf);
            CharSpace();
            CharA(messageUv, messageSdf);
            CharSpace();
            CharJ(messageUv, messageSdf);
            CharO(messageUv, messageSdf);
            CharU(messageUv, messageSdf);
            CharR(messageUv, messageSdf);
            CharN(messageUv, messageSdf);
            CharE(messageUv, messageSdf);
            CharY(messageUv, messageSdf);
            CharSpace();
            CharT(messageUv, messageSdf);
            CharO(messageUv, messageSdf);
            CharSpace();
            CharF(messageUv, messageSdf);
            CharA(messageUv, messageSdf);
            CharR(messageUv, messageSdf);
            CharSpace();
            CharA(messageUv, messageSdf);
            CharW(messageUv, messageSdf);
            CharA(messageUv, messageSdf);
            CharY(messageUv, messageSdf);
            CharSpace();
            CharL(messageUv, messageSdf);
            CharA(messageUv, messageSdf);
            CharN(messageUv, messageSdf);
            CharD(messageUv, messageSdf);
            CharS(messageUv, messageSdf);
        }
        else if (gPlayerDeathCause == kBehavHazard)
        {
            gCharPrintPos = vec2(-170.0, -40.0);
            CharD(messageUv, messageSdf);
            CharI(messageUv, messageSdf);
            CharD(messageUv, messageSdf);
            CharSpace();
            CharA(messageUv, messageSdf);
            CharN(messageUv, messageSdf);
            CharY(messageUv, messageSdf);
            CharO(messageUv, messageSdf);
            CharN(messageUv, messageSdf);
            CharE(messageUv, messageSdf);
            CharSpace();
            CharC(messageUv, messageSdf);
            CharA(messageUv, messageSdf);
            CharT(messageUv, messageSdf);
            CharC(messageUv, messageSdf);
            CharH(messageUv, messageSdf);
            CharSpace();
            CharT(messageUv, messageSdf);
            CharH(messageUv, messageSdf);
            CharE(messageUv, messageSdf);
            CharSpace();
            CharL(messageUv, messageSdf);
            CharI(messageUv, messageSdf);
            CharC(messageUv, messageSdf);
            CharE(messageUv, messageSdf);
            CharN(messageUv, messageSdf);
            CharS(messageUv, messageSdf);
            CharE(messageUv, messageSdf);
            CharSpace();
            CharP(messageUv, messageSdf);
            CharL(messageUv, messageSdf);
            CharA(messageUv, messageSdf);
            CharT(messageUv, messageSdf);
            CharE(messageUv, messageSdf);
        }
        
        fragColor.rgb = mix(fragColor.rgb, vec3(0.0), step(-3.0, -gameOverSdf));
        fragColor.rgb = mix(fragColor.rgb, vec3(1.0), step(0.0, -gameOverSdf));
        fragColor.rgb = mix(fragColor.rgb, vec3(0.0), step(-3.0, -messageSdf));
        fragColor.rgb = mix(fragColor.rgb, vec3(1.0), step(0.0, -messageSdf));
    }   
    
    // Fade to white upon Restarting
    
    if (gGameState == kStateRestarting)
        fragColor.rgb = mix(mix(fragColor.rgb, vec3(0.2, 0.7, 1.0), 0.5), vec3(1.0), min(1.0, gGameStateTime));
    
    // Fade from white at the title.
    
    if (gGameState == kStateTitle)
    	fragColor.rgb = mix(vec3(1.0), fragColor.rgb, min(1.0, gGameStateTime));
    
    // Press space to continue.
    
    if (step(0.5, fract(iTime * 0.75)) > 0.5 && (gGameState == kStateTitle || gGameState == kStateGameOver) && gGameStateTime > 1.0)
    {
        float messageSdf = kOmega;
        vec2 messageUv = uv * 1.75;
                 
        gCharPrintPos = vec2(-130.0, -100.0);
        CharP(messageUv, messageSdf);
        CharR(messageUv, messageSdf);
        CharE(messageUv, messageSdf);
        CharS(messageUv, messageSdf);
        CharS(messageUv, messageSdf);
        CharSpace();
        CharS(messageUv, messageSdf);
        CharP(messageUv, messageSdf);
        CharA(messageUv, messageSdf);
        CharC(messageUv, messageSdf);
        CharE(messageUv, messageSdf);
        CharSpace();
        CharT(messageUv, messageSdf);
        CharO(messageUv, messageSdf);
        CharSpace();
        CharC(messageUv, messageSdf);
        CharO(messageUv, messageSdf);
        CharN(messageUv, messageSdf);
        CharT(messageUv, messageSdf);
        CharI(messageUv, messageSdf);
        CharN(messageUv, messageSdf);
        CharU(messageUv, messageSdf);
        CharE(messageUv, messageSdf);
        
        fragColor.rgb = mix(fragColor.rgb, vec3(0.0), step(-3.0, -messageSdf));
        fragColor.rgb = mix(fragColor.rgb, vec3(1.0, 1.0, 0.0), step(0.0, -messageSdf));
    }
}

// =============================================================================
// END OF UI RENDER CODE
// =============================================================================

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    LoadState();

	// Compute uv coords.
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    // Render lower-res back buffer.
    fragColor = texture(iChannel1, uv * gFbScale);
    
    // Render UI
    float aspect = iResolution.x / iResolution.y;
    uv = 2.0 * uv - 1.0;
    uv.x *= aspect;    

    RenderUI(fragColor, fragCoord, uv, aspect);
}
