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

// -- Constants ----------------------------------------------------------------

// Key constants.

const float kKeyLeft  = 37.5 / 256.0;
const float kKeyUp    = 38.5 / 256.0;
const float kKeyRight = 39.5 / 256.0;
const float kKeyDown  = 40.5 / 256.0;
const float kKeySpace = 32.5 / 256.0;
const float kKey1     = 49.5 / 256.0;
const float kKey2     = 50.5 / 256.0;
const float kKey3     = 51.5 / 256.0;
const float kKey4     = 52.5 / 256.0;

// -- Aux functions ------------------------------------------------------------

float MixAngle(float a, float b, float t)
{
    float d = (b - a);
    d -= floor(d * 0.5 * kOneOverPi) * 2.0 * kPi;
    
    if (d > kPi)
        d -= 2.0 * kPi;
    
    return a + d * t;
}

float JumpCurve(float x)
{
    return 1.0 - 4.0 * (x - 0.5) * (x - 0.5);
}

// -- IO functions -------------------------------------------------------------

float SampleKey(float key)
{
	return step(0.5, texture(iChannel1, vec2(key, 0.25)).x);
}

vec2 SampleAxes()
{
    vec2 axes;
    axes.x = SampleKey(kKeyRight) - SampleKey(kKeyLeft);
    axes.y = (axes.x == 0.0)? SampleKey(kKeyUp) - SampleKey(kKeyDown) : 0.0;
    return axes;
}

// -- State functions ----------------------------------------------------------

void GameSetState(float state)
{
    gGameState     = state;
    gGameStateTime = 0.0;
}

void GameRestart(float state)
{
    GameSetState(state);
    gGameSeed             = iTime;
    gPlayerCoords         = vec2(0.5, 0.5);
    gPlayerNextCoords     = vec2(0.5, 0.5);
    gPlayerMotionTimer    = 0.0;
    gPlayerRotation       = 0.0;
    gPlayerNextRotation   = 0.0;
    gPlayerScale          = 1.0;
    gPlayerVisualCoords   = vec3(gPlayerCoords, 0.0).xzy;
    gPlayerVisualRotation = 0.0;
    gPlayerDeathCause     = 0.0;
    gScore                = 1.0;
}

void GameUpdate()
{
    float behav = GetSceneTileBehaviour(gPlayerNextCoords);
    
    if (behav == kBehavObstacle)
    {
        GameSetState(kStateGameOver);
        gPlayerDeathCause = behav;
        gPlayerDeathTime = iTime;
    }
    else if (gPlayerMotionTimer >= 1.0 && gGameState != kStateGameOver)
    {       
        gPlayerCoords = gPlayerNextCoords;
        gPlayerRotation = gPlayerNextRotation;
        
        if (behav != kBehavGround)
        {
            GameSetState(kStateGameOver);
            gPlayerDeathCause = behav;
            gPlayerDeathTime = iTime;
        }
        else
        {       
            vec2 axes = SampleAxes();

            if (dot(axes, axes) > 0.0)
            {
                vec2 nextCoords = GetNextCoordinates(gPlayerCoords + axes);

                if (GetSceneTileBehaviour(nextCoords) != kBehavObstacle)
                {
                    gPlayerNextCoords = nextCoords;
                    gPlayerMotionTimer = 0.0;
                    gPlayerNextRotation = atan(axes.x, axes.y);
					gScore = max(gScore, floor(nextCoords.y));
                }
            }
        }
    }
    else
    {
        gPlayerMotionTimer += iTimeDelta * kPlayerSpeed;
    }
        
    vec4 coordsVss = GetSceneTileVss(gPlayerCoords);
    vec4 nextCoordsVss = GetSceneTileVss(gPlayerNextCoords);
    gPlayerCoords.x += coordsVss.x * coordsVss.w * iTimeDelta;
    gPlayerNextCoords.x += nextCoordsVss.x * nextCoordsVss.w * iTimeDelta;
    gPlayerVisualCoords.xz = mix(gPlayerCoords, gPlayerNextCoords, clamp(gPlayerMotionTimer, 0.0, 1.0));
    gPlayerVisualCoords.y  = kPlayerJumpHeight * JumpCurve(min(1.0, gPlayerMotionTimer));
    gPlayerVisualRotation  = MixAngle(gPlayerRotation, gPlayerNextRotation, clamp(gPlayerMotionTimer, 0.0, 1.0));
    gPlayerScale = 1.0 + 0.1 * JumpCurve(min(1.0, gPlayerMotionTimer));
    
    if (gGameState == kStateGameOver)
    {
         if (gPlayerDeathCause == kBehavWater)
             gPlayerVisualCoords.y = kPlayerJumpHeight * JumpCurve(gPlayerMotionTimer);
    }
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    if (fragCoord.x > 14.0 || fragCoord.y > 14.0)
        discard;

    LoadState();
       
    if (gGameInit == 0.0)
    {
		GameRestart(kStateTitle);
        gFbScale = 1.0;
        gGameInit = 1.0;
    }
    else if (gGameState == kStateTitle)
    {
        if (SampleKey(kKeySpace) == 1.0)
            GameSetState(kStateInGame);
    }
    else if (gGameState == kStateInGame)
    {
        GameUpdate();
    }
    else if (gGameState == kStateGameOver)
    {
        GameUpdate();
        
        if (SampleKey(kKeySpace) == 1.0)
            GameSetState(kStateRestarting);
    }
    else
    {
        if (gGameStateTime > 1.0)
            GameRestart(kStateTitle);
    }
 
    if (SampleKey(kKey1) == 1.0)
        gFbScale = 1.0;
    
    if (SampleKey(kKey2) == 1.0)
        gFbScale = 0.75;
    
    if (SampleKey(kKey3) == 1.0)
        gFbScale = 0.5;
    
    if (SampleKey(kKey4) == 1.0)
        gFbScale = 0.25;
    
   	gGameStateTime += iTimeDelta;
    StoreState(fragColor, fragCoord);
}
