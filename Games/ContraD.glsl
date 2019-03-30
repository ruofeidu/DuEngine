
// UI and some foreground stuff

#define SPRITE_DEC_2( x, i ) mod( floor( i / pow( 2.0, mod( x, 24.0 ) ) ), 2.0 )
#define SPRITE_DEC_3( x, i ) mod( floor( i / pow( 4.0, mod( x, 11.0 ) ) ), 4.0 )
#define SPRITE_DEC_4( x, i ) mod( floor( i / pow( 4.0, mod( x, 8.0 ) ) ), 4.0 )
#define RGB( r, g, b ) vec3( float( r ) / 255.0, float( g ) / 255.0, float( b ) / 255.0 )

const float NES_RES_X               = 224.0;
const float NES_RES_Y               = 192.0;
const float GAME_STATE_TITLE		= 0.0;
const float GAME_STATE_LEVEL		= 1.0;
const float GAME_STATE_LEVEL_DIE	= 2.0;
const float GAME_STATE_LEVEL_WIN	= 3.0;
const float GAME_STATE_GAME_OVER	= 4.0;
const float GAME_STATE_VICTORY		= 5.0;
const float WEAPON_RIFLE        	= 0.0;
const vec2  BULLET_SIZE         	= vec2( 3.0,  3.0  );
const vec2  POWER_UP_SIZE       	= vec2( 24.0, 14.0 );
const float UI_VICTORY_TIME			= 300.0;

// storage
const vec2 txPlayer 			= vec2( 0.0, 0.0 ); 	// xy - pos, z - jump start, w - jump dir
const vec2 txPlayerState		= vec2( 1.0, 0.0 ); 	// x - state, y - frame, z - jump tick, w - lifes
const vec2 txPlayerDir			= vec2( 2.0, 0.0 ); 	// xy - dir, z - flip, w - immortality
const vec2 txPlayerWeapon		= vec2( 3.0, 0.0 ); 	// x - weapon, y - weapon cooldown, z - weapon fire rate, w - weapon bullet num
const vec2 txCamera 			= vec2( 4.0, 0.0 ); 	// x - cam offset, y - spawn counter, z - soldier spawn counter
const vec2 txSoldier0 			= vec2( 5.0, 0.0 ); 	// xy - pos, z - flip
const vec2 txSoldier1 			= vec2( 5.0, 1.0 ); 	// xy - pos, z - flip
const vec2 txSoldier2 			= vec2( 5.0, 2.0 ); 	// xy - pos, z - flip
const vec2 txSoldier0State 		= vec2( 6.0, 0.0 ); 	// x - state, y - frame, z - jump tick
const vec2 txSoldier1State 		= vec2( 6.0, 1.0 ); 	// x - state, y - frame, z - jump tick
const vec2 txSoldier2State 		= vec2( 6.0, 2.0 ); 	// x - state, y - frame, z - jump tick
const vec2 txSniper	 			= vec2( 7.0, 0.0 ); 	// xy - pos, z - flip, w - weapon cooldown
const vec2 txPlayerBullet0 		= vec2( 8.0, 0.0 ); 	// xy - pos, xy - dir
const vec2 txPlayerBullet1 		= vec2( 8.0, 1.0 ); 	// xy - pos, xy - dir
const vec2 txPlayerBullet2 		= vec2( 8.0, 2.0 ); 	// xy - pos, xy - dir
const vec2 txPlayerBullet3 		= vec2( 8.0, 3.0 ); 	// xy - pos, xy - dir
const vec2 txPlayerBullet4 		= vec2( 8.0, 4.0 ); 	// xy - pos, xy - dir
const vec2 txPlayerBullet5 		= vec2( 8.0, 5.0 ); 	// xy - pos, xy - dir
const vec2 txEnemyBullet0 		= vec2( 9.0, 0.0 ); 	// xy - pos, xy - dir
const vec2 txEnemyBullet1 		= vec2( 9.0, 1.0 ); 	// xy - pos, xy - dir
const vec2 txEnemyBullet2 		= vec2( 9.0, 2.0 ); 	// xy - pos, xy - dir
const vec2 txEnemyBullet3 		= vec2( 9.0, 3.0 ); 	// xy - pos, xy - dir
const vec2 txExplosion 			= vec2( 10.0, 0.0 ); 	// xy - pos, z - frame
const vec2 txHit 				= vec2( 11.0, 0.0 ); 	// xy - pos, z - frame
const vec2 txTurret0			= vec2( 12.0, 0.0 ); 	// xy - pos, z - angle
const vec2 txTurret1			= vec2( 12.0, 1.0 ); 	// xy - pos, z - angle
const vec2 txTurret0State		= vec2( 13.0, 0.0 ); 	// x - HP, y - weapon cooldown
const vec2 txTurret1State		= vec2( 13.0, 1.0 ); 	// x - HP, y - weapon cooldown
const vec2 txPowerUp			= vec2( 14.0, 0.0 ); 	// xy - pos, z - frame
const vec2 txPowerUpState		= vec2( 15.0, 0.0 ); 	// x - state, y - initial height, z - jump tick
const vec2 txBossCore			= vec2( 16.0, 0.0 ); 	// xy - pos, z - HP
const vec2 txBossCannon0		= vec2( 17.0, 0.0 ); 	// xy - pos, z - cooldown, w - HP
const vec2 txBossCannon1		= vec2( 17.0, 1.0 ); 	// xy - pos, z - cooldown, w - HP
const vec2 txBossBullet0		= vec2( 18.0, 0.0 ); 	// xy - pos, zw - velocity
const vec2 txBossBullet1		= vec2( 18.0, 1.0 ); 	// xy - pos, zw - velocity
const vec2 txGameState			= vec2( 19.0, 0.0 ); 	// x - state, y - state tick
const vec2 txBridge				= vec2( 20.0, 0.0 ); 	// x - draw start, y - explode tick

vec4 LoadValue( vec2 tx )
{
    return floor( texture( iChannel0, ( tx + 0.5 ) / iChannelResolution[ 0 ].xy ) );
}

float Rand( vec2 co )
{
    return fract( sin( dot( co.xy, vec2( 12.9898, 78.233 ) ) ) * 43758.5453 );
}

void SpritePowerBullet( inout vec3 color, float x, float y )
{
    float idx = 0.0;
    
    idx = y == 4.0 ? ( x <= 7.0 ? 84.0 : 0.0 ) : idx;
    idx = y == 3.0 ? ( x <= 7.0 ? 349.0 : 0.0 ) : idx;
    idx = y == 2.0 ? ( x <= 7.0 ? 405.0 : 0.0 ) : idx;
    idx = y == 1.0 ? ( x <= 7.0 ? 361.0 : 0.0 ) : idx;
    idx = y == 0.0 ? ( x <= 7.0 ? 84.0 : 0.0 ) : idx;

    idx = SPRITE_DEC_4( x, idx );
    idx = x >= 0.0 && x < 5.0 ? idx : 0.0;
    
    color = idx == 1.0 ? RGB( 255,  46,   0 ) : color;
    color = idx == 2.0 ? RGB( 255, 112,  78 ) : color;
    color = idx == 3.0 ? RGB( 255, 255, 255 ) : color;
}

void SpriteBullet( inout vec3 color, float x, float y )
{
    float idx = 0.0;
    
    idx = y == 2.0 ? ( x <= 7.0 ? 4.0 : 0.0 ) : idx;
    idx = y == 1.0 ? ( x <= 7.0 ? 21.0 : 0.0 ) : idx;
    idx = y == 0.0 ? ( x <= 7.0 ? 4.0 : 0.0 ) : idx;

    idx = SPRITE_DEC_4( x, idx );
    idx = x >= 0.0 && x < 3.0 ? idx : 0.0;
    
    color = idx == 1.0 ? RGB( 255, 255, 255 ) : color;
}

void SpriteHit( inout vec3 color, float x, float y )
{
    float idx = 0.0;    
    
    idx = y == 6.0 ? 608.0 : idx;
    idx = y == 5.0 ? 2056.0 : idx;
    idx = y == 4.0 ? 8194.0 : idx;
    idx = y == 3.0 ? 4097.0 : idx;
    idx = y == 2.0 ? 8194.0 : idx;
    idx = y == 1.0 ? 2056.0 : idx;
    idx = y == 0.0 ? 608.0 : idx;

    idx = SPRITE_DEC_3( x, idx );
    idx = x >= 0.0 && x < 7.0 ? idx : 0.0;
    
    color = idx == 1.0 ? RGB( 228,  68,  52 ) : color;
    color = idx == 2.0 ? RGB( 255, 140, 124 ) : color;
}

void SpriteExplosion( inout vec3 color, float x, float y, float frame )
{
    float idx = 0.0;
    
    x = abs( x );
    y = abs( y );

    if ( frame == 0.0 )
    {
        idx = y == 11.0 ? ( x <= 7.0 ? 21.0 : 0.0 ) : idx;
        idx = y == 10.0 ? ( x <= 7.0 ? 342.0 : 0.0 ) : idx;
        idx = y == 9.0 ? ( x <= 7.0 ? 5541.0 : 0.0 ) : idx;
        idx = y == 8.0 ? ( x <= 7.0 ? 26990.0 : 0.0 ) : idx;
        idx = y == 7.0 ? ( x <= 7.0 ? 32182.0 : ( x <= 15.0 ? 1.0 : 0.0 ) ) : idx;
        idx = y == 6.0 ? ( x <= 7.0 ? 39595.0 : ( x <= 15.0 ? 5.0 : 0.0 ) ) : idx;
        idx = y == 5.0 ? ( x <= 7.0 ? 64183.0 : ( x <= 15.0 ? 6.0 : 0.0 ) ) : idx;
        idx = y == 4.0 ? ( x <= 7.0 ? 44783.0 : ( x <= 15.0 ? 23.0 : 0.0 ) ) : idx;
        idx = y == 3.0 ? ( x <= 7.0 ? 48127.0 : ( x <= 15.0 ? 22.0 : 0.0 ) ) : idx;
        idx = y == 2.0 ? ( x <= 7.0 ? 44799.0 : ( x <= 15.0 ? 103.0 : 0.0 ) ) : idx;
        idx = y == 1.0 ? ( x <= 7.0 ? 64511.0 : ( x <= 15.0 ? 90.0 : 0.0 ) ) : idx;
        idx = y == 0.0 ? ( x <= 7.0 ? 49151.0 : ( x <= 15.0 ? 90.0 : 0.0 ) ) : idx;
    }
    else if ( frame == 1.0 )
    {
        idx = y == 13.0 ? ( x <= 7.0 ? 25.0 : 0.0 ) : idx;
        idx = y == 12.0 ? ( x <= 7.0 ? 1705.0 : 0.0 ) : idx;
        idx = y == 11.0 ? ( x <= 7.0 ? 23295.0 : 0.0 ) : idx;
        idx = y == 10.0 ? ( x <= 7.0 ? 32682.0 : ( x <= 15.0 ? 5.0 : 0.0 ) ) : idx;
        idx = y == 9.0 ? ( x <= 7.0 ? 65232.0 : ( x <= 15.0 ? 22.0 : 0.0 ) ) : idx;
        idx = y == 8.0 ? ( x <= 7.0 ? 58384.0 : ( x <= 15.0 ? 27.0 : 0.0 ) ) : idx;
        idx = y == 7.0 ? ( x <= 7.0 ? 57600.0 : ( x <= 15.0 ? 107.0 : 0.0 ) ) : idx;
        idx = y == 6.0 ? ( x <= 7.0 ? 41216.0 : ( x <= 15.0 ? 110.0 : 0.0 ) ) : idx;
        idx = y == 5.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 430.0 : 0.0 ) ) : idx;
        idx = y == 4.0 ? ( x <= 7.0 ? 32768.0 : ( x <= 15.0 ? 430.0 : 0.0 ) ) : idx;
        idx = y == 3.0 ? ( x <= 7.0 ? 16384.0 : ( x <= 15.0 ? 442.0 : 0.0 ) ) : idx;
        idx = y == 2.0 ? ( x <= 7.0 ? 4096.0 : ( x <= 15.0 ? 1462.0 : 0.0 ) ) : idx;
        idx = y == 1.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 1520.0 : 0.0 ) ) : idx;
        idx = y == 0.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 1460.0 : 0.0 ) ) : idx;
    }
    else
    {   
        idx = y == 15.0 ? ( x <= 7.0 ? 68.0 : 0.0 ) : idx;
        idx = y == 14.0 ? ( x <= 7.0 ? 1280.0 : 0.0 ) : idx;
        idx = y == 13.0 ? ( x <= 7.0 ? 16384.0 : 0.0 ) : idx;
        idx = y == 12.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 5.0 : 0.0 ) ) : idx;
        idx = y == 11.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 16.0 : 0.0 ) ) : idx;
        idx = y == 10.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 64.0 : 0.0 ) ) : idx;
        idx = y == 8.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 256.0 : 0.0 ) ) : idx;
        idx = y == 5.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 4096.0 : 0.0 ) ) : idx;
        idx = y == 3.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 16384.0 : 0.0 ) ) : idx;
        idx = y == 2.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 16384.0 : 0.0 ) ) : idx;
        
    }

    idx = SPRITE_DEC_4( x, idx );
    idx = x >= 0.0 && x < 12.0 + frame * 2.0 ? idx : 0.0;
    
    color = idx == 1.0 ? RGB( 228,  68,  52 ) : color;
    color = idx == 2.0 ? RGB( 255, 140, 124 ) : color;
    color = idx == 3.0 ? RGB( 255, 255, 255 ) : color;
}

void SpritePowerUp( inout vec3 color, float x, float y, float frame )
{
    float idx = 0.0;    
    
    if ( frame == 0.0 )
    {
        idx = y == 13.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 5460.0 : 0.0 ) ) : idx;
        idx = y == 12.0 ? ( x <= 7.0 ? 16384.0 : ( x <= 15.0 ? 32765.0 : 1.0 ) ) : idx;
        idx = y == 11.0 ? ( x <= 7.0 ? 54272.0 : ( x <= 15.0 ? 54615.0 : 23.0 ) ) : idx;
        idx = y == 10.0 ? ( x <= 7.0 ? 23808.0 : ( x <= 15.0 ? 31421.0 : 117.0 ) ) : idx;
        idx = y == 9.0 ? ( x <= 7.0 ? 55104.0 : ( x <= 15.0 ? 65215.0 : 471.0 ) ) : idx;
        idx = y == 8.0 ? ( x <= 7.0 ? 40276.0 : ( x <= 15.0 ? 43690.0 : 5494.0 ) ) : idx;
        idx = y == 7.0 ? ( x <= 7.0 ? 57193.0 : ( x <= 15.0 ? 43690.0 : 27127.0 ) ) : idx;
        idx = y == 6.0 ? ( x <= 7.0 ? 57193.0 : ( x <= 15.0 ? 64175.0 : 27127.0 ) ) : idx;
        idx = y == 5.0 ? ( x <= 7.0 ? 56660.0 : ( x <= 15.0 ? 65215.0 : 5495.0 ) ) : idx;
        idx = y == 4.0 ? ( x <= 7.0 ? 55104.0 : ( x <= 15.0 ? 64175.0 : 471.0 ) ) : idx;
        idx = y == 3.0 ? ( x <= 7.0 ? 23808.0 : ( x <= 15.0 ? 27305.0 : 117.0 ) ) : idx;
        idx = y == 2.0 ? ( x <= 7.0 ? 54272.0 : ( x <= 15.0 ? 54615.0 : 23.0 ) ) : idx;
        idx = y == 1.0 ? ( x <= 7.0 ? 16384.0 : ( x <= 15.0 ? 32765.0 : 1.0 ) ) : idx;
        idx = y == 0.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 5460.0 : 0.0 ) ) : idx;
    }
    else
    {
        idx = y == 14.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 320.0 : 0.0 ) ) : idx;
        idx = y == 13.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 1744.0 : 0.0 ) ) : idx;
        idx = y == 12.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 6836.0 : 0.0 ) ) : idx;
        idx = y == 11.0 ? ( x <= 7.0 ? 2389.0 : ( x <= 15.0 ? 1680.0 : 21856.0 ) ) : idx;
        idx = y == 10.0 ? ( x <= 7.0 ? 8123.0 : ( x <= 15.0 ? 21845.0 : 61172.0 ) ) : idx;
        idx = y == 9.0 ? ( x <= 7.0 ? 31078.0 : ( x <= 15.0 ? 26969.0 : 39277.0 ) ) : idx;
        idx = y == 8.0 ? ( x <= 7.0 ? 42669.0 : ( x <= 15.0 ? 27241.0 : 31386.0 ) ) : idx;
        idx = y == 7.0 ? ( x <= 7.0 ? 39252.0 : ( x <= 15.0 ? 27305.0 : 5478.0 ) ) : idx;
        idx = y == 6.0 ? ( x <= 7.0 ? 27344.0 : ( x <= 15.0 ? 27305.0 : 1961.0 ) ) : idx;
        idx = y == 5.0 ? ( x <= 7.0 ? 42304.0 : ( x <= 15.0 ? 27033.0 : 346.0 ) ) : idx;
        idx = y == 4.0 ? ( x <= 7.0 ? 44288.0 : ( x <= 15.0 ? 26969.0 : 122.0 ) ) : idx;
        idx = y == 3.0 ? ( x <= 7.0 ? 21504.0 : ( x <= 15.0 ? 26969.0 : 21.0 ) ) : idx;
        idx = y == 2.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 26969.0 : 0.0 ) ) : idx;
        idx = y == 1.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 26969.0 : 0.0 ) ) : idx;
        idx = y == 0.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 21845.0 : 0.0 ) ) : idx;
    }

    idx = SPRITE_DEC_4( x, idx );
    idx = x >= 0.0 && x < 24.0 ? idx : 0.0;    
    
    color = idx == 1.0 ? RGB( 0,    0,   0   ) : color;
    color = idx == 2.0 ? RGB( 228,  68,  52  ) : color;
    color = idx == 3.0 ? RGB( 255,  184, 168 ) : color;
}

void SpriteLife( inout vec3 color, float x, float y )
{
    float idx = 0.0;
    
    idx = y == 15.0 ? 21845.0 : idx;
    idx = y == 14.0 ? 26985.0 : idx;
    idx = y == 13.0 ? 26985.0 : idx;
    idx = y == 12.0 ? 26985.0 : idx;
    idx = y == 11.0 ? 26985.0 : idx;
    idx = y == 10.0 ? 6500.0 : idx;
    idx = y == 9.0 ? 1360.0 : idx;
    idx = y == 8.0 ? 1744.0 : idx;
    idx = y == 7.0 ? 1360.0 : idx;
    idx = y == 6.0 ? 7140.0 : idx;
    idx = y == 5.0 ? 28345.0 : idx;
    idx = y == 4.0 ? 31725.0 : idx;
    idx = y == 3.0 ? 31725.0 : idx;
    idx = y == 2.0 ? 28345.0 : idx;
    idx = y == 1.0 ? 7140.0 : idx;
    idx = y == 0.0 ? 1360.0 : idx;    
    
    idx = SPRITE_DEC_4( x, idx );
    
    color = idx == 1.0 ? RGB( 0,    0,   0   ) : color;
    color = idx == 2.0 ? RGB( 48,   31,  252 ) : color;
    color = idx == 3.0 ? RGB( 255,  218, 144 ) : color;
}

void SpriteStage1( inout vec3 color, float x, float y )
{
    float idx = 0.0;

    idx = y == 6.0 ? ( x <= 23.0 ? 4095806.0 : ( x <= 47.0 ? 32574.0 : 30.0 ) ) : idx;
    idx = y == 5.0 ? ( x <= 23.0 ? 8330311.0 : ( x <= 47.0 ? 1895.0 : 28.0 ) ) : idx;
    idx = y == 4.0 ? ( x <= 23.0 ? 7412743.0 : ( x <= 47.0 ? 1799.0 : 28.0 ) ) : idx;
    idx = y == 3.0 ? ( x <= 23.0 ? 7412798.0 : ( x <= 47.0 ? 32631.0 : 28.0 ) ) : idx;
    idx = y == 2.0 ? ( x <= 23.0 ? 8330352.0 : ( x <= 47.0 ? 1895.0 : 28.0 ) ) : idx;
    idx = y == 1.0 ? ( x <= 23.0 ? 7412851.0 : ( x <= 47.0 ? 1911.0 : 28.0 ) ) : idx;
    idx = y == 0.0 ? ( x <= 23.0 ? 7412798.0 : ( x <= 47.0 ? 32606.0 : 62.0 ) ) : idx;
    
    idx = SPRITE_DEC_2( x, idx );
    idx = x >= 0.0 && x < 54.0 ? idx : 0.0;

    color = idx == 1.0 ? RGB( 255, 255, 255 ) : color;
}

void SpriteJungle( inout vec3 color, float x, float y )
{
    float idx = 0.0;

    idx = y == 6.0 ? ( x <= 23.0 ? 6776700.0 : 8324926.0 ) : idx;
    idx = y == 5.0 ? ( x <= 23.0 ? 7300920.0 : 460647.0 ) : idx;
    idx = y == 4.0 ? ( x <= 23.0 ? 8087352.0 : 460551.0 ) : idx;
    idx = y == 3.0 ? ( x <= 23.0 ? 7563064.0 : 8324983.0 ) : idx;
    idx = y == 2.0 ? ( x <= 23.0 ? 6514489.0 : 460647.0 ) : idx;
    idx = y == 1.0 ? ( x <= 23.0 ? 6514489.0 : 460663.0 ) : idx;
    idx = y == 0.0 ? ( x <= 23.0 ? 6503966.0 : 8355678.0 ) : idx;

    idx = SPRITE_DEC_2( x, idx );
    idx = x >= 0.0 && x < 47.0 ? idx : 0.0;

    color = idx == 1.0 ? RGB( 255, 255, 255 ) : color;
}

void SpriteGameOver( inout vec3 color, float x, float y )
{
    float idx = 0.0;

    idx = y == 6.0 ? ( x <= 23.0 ? 6503998.0 : ( x <= 47.0 ? 4063359.0 : 4161399.0 ) ) : idx;
    idx = y == 5.0 ? ( x <= 23.0 ? 7831399.0 : ( x <= 47.0 ? 7536647.0 : 6752119.0 ) ) : idx;
    idx = y == 4.0 ? ( x <= 23.0 ? 8352007.0 : ( x <= 47.0 ? 7536647.0 : 6752054.0 ) ) : idx;
    idx = y == 3.0 ? ( x <= 23.0 ? 6123895.0 : ( x <= 47.0 ? 7536767.0 : 4161334.0 ) ) : idx;
    idx = y == 2.0 ? ( x <= 23.0 ? 4816743.0 : ( x <= 47.0 ? 7536647.0 : 3606300.0 ) ) : idx;
    idx = y == 1.0 ? ( x <= 23.0 ? 4288887.0 : ( x <= 47.0 ? 8323079.0 : 6752028.0 ) ) : idx;
    idx = y == 0.0 ? ( x <= 23.0 ? 4288862.0 : ( x <= 47.0 ? 4063359.0 : 6782728.0 ) ) : idx;

    idx = SPRITE_DEC_2( x, idx );
    idx = x >= 0.0 && x < 71.0 ? idx : 0.0;

    color = idx == 1.0 ? RGB( 255, 255, 255 ) : color;
}

void SpriteHelicopter( inout vec3 color, float x, float y )
{
    float idx = 0.0;    
    
	idx = y == 10.0 ? ( x <= 7.0 ? 0.0 : 32768.0 ) : idx;
	idx = y == 9.0 ? ( x <= 7.0 ? 0.0 : 28672.0 ) : idx;
	idx = y == 8.0 ? ( x <= 7.0 ? 0.0 : 24672.0 ) : idx;
	idx = y == 7.0 ? ( x <= 7.0 ? 0.0 : 6155.0 ) : idx;
	idx = y == 6.0 ? ( x <= 7.0 ? 57344.0 : 1600.0 ) : idx;
	idx = y == 5.0 ? ( x <= 7.0 ? 6400.0 : 424.0 ) : idx;
	idx = y == 4.0 ? ( x <= 7.0 ? 36944.0 : 106.0 ) : idx;
	idx = y == 3.0 ? ( x <= 7.0 ? 58373.0 : 27.0 ) : idx;
	idx = y == 2.0 ? ( x <= 7.0 ? 57600.0 : 26.0 ) : idx;
	idx = y == 1.0 ? ( x <= 7.0 ? 43264.0 : 5.0 ) : idx;
	idx = y == 0.0 ? ( x <= 7.0 ? 21760.0 : 0.0 ) : idx;
    
    idx = SPRITE_DEC_4( x, idx );
    idx = x >= 0.0 && x < 16.0 ? idx : 0.0;

    color = idx == 1.0 ? RGB( 0,   91,  0 )   : color;
    color = idx == 2.0 ? RGB( 0,   171, 71 )  : color;
    color = idx == 3.0 ? RGB( 184, 248, 216 ) : color;
}

void SpriteVictory( inout vec3 color, float x, float y )
{
    float idx = 0.0;

    idx = y == 6.0 ? ( x <= 23.0 ? 6766142.0 : ( x <= 47.0 ? 4079422.0 : ( x <= 71.0 ? 485247.0 : ( x <= 95.0 ? 4095806.0 : ( x <= 119.0 ? 4089662.0 : 28.0 ) ) ) ) ) : idx;
    idx = y == 5.0 ? ( x <= 23.0 ? 7304039.0 : ( x <= 47.0 ? 8349543.0 : ( x <= 71.0 ? 485148.0 : ( x <= 95.0 ? 1842303.0 : ( x <= 119.0 ? 4681587.0 : 28.0 ) ) ) ) ) : idx;
    idx = y == 4.0 ? ( x <= 23.0 ? 8090471.0 : ( x <= 47.0 ? 7431943.0 : ( x <= 71.0 ? 485148.0 : ( x <= 95.0 ? 1842289.0 : ( x <= 119.0 ? 490355.0 : 28.0 ) ) ) ) ) : idx;
    idx = y == 3.0 ? ( x <= 23.0 ? 7566087.0 : ( x <= 47.0 ? 7421815.0 : ( x <= 71.0 ? 485148.0 : ( x <= 95.0 ? 1842289.0 : ( x <= 119.0 ? 4092787.0 : 28.0 ) ) ) ) ) : idx;
    idx = y == 2.0 ? ( x <= 23.0 ? 6517607.0 : ( x <= 47.0 ? 8337255.0 : ( x <= 71.0 ? 485148.0 : ( x <= 95.0 ? 1842303.0 : ( x <= 119.0 ? 7365491.0 : 0.0 ) ) ) ) ) : idx;
    idx = y == 1.0 ? ( x <= 23.0 ? 6520679.0 : ( x <= 47.0 ? 7432055.0 : ( x <= 71.0 ? 485148.0 : ( x <= 95.0 ? 1842289.0 : ( x <= 119.0 ? 7562111.0 : 0.0 ) ) ) ) ) : idx;
    idx = y == 0.0 ? ( x <= 23.0 ? 6503998.0 : ( x <= 47.0 ? 7432030.0 : ( x <= 71.0 ? 8338972.0 : ( x <= 95.0 ? 4070513.0 : ( x <= 119.0 ? 4088638.0 : 28.0 ) ) ) ) ) : idx;

    idx = SPRITE_DEC_2( x, idx );
    idx = x >= 0.0 && x < 125.0 ? idx : 0.0;

    color = idx == 1.0 ? RGB( 255, 255, 255 ) : color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
    // we want 224x192 (overscan) and we want multiples of pixel size
    float resMultX      = floor( iResolution.x / NES_RES_X );
    float resMultY      = floor( iResolution.y / NES_RES_Y );
    float resRcp        = 1.0 / max( min( resMultX, resMultY ), 1.0 );
    float screenWidth   = floor( iResolution.x * resRcp );
    float screenHeight  = floor( iResolution.y * resRcp );
    float pixelX        = floor( fragCoord.x * resRcp );
    float pixelY        = floor( fragCoord.y * resRcp );   
    
    vec4 playerState    = LoadValue( txPlayerState );
    vec4 playerWeapon   = LoadValue( txPlayerWeapon );    
    vec4 camera         = LoadValue( txCamera );
    vec4 playerBullet0  = LoadValue( txPlayerBullet0 );
    vec4 playerBullet1  = LoadValue( txPlayerBullet1 );
    vec4 playerBullet2  = LoadValue( txPlayerBullet2 );
    vec4 playerBullet3  = LoadValue( txPlayerBullet3 );
    vec4 playerBullet4  = LoadValue( txPlayerBullet4 );
    vec4 playerBullet5  = LoadValue( txPlayerBullet5 );
    vec4 enemyBullet0   = LoadValue( txEnemyBullet0 );
    vec4 enemyBullet1   = LoadValue( txEnemyBullet1 );
    vec4 enemyBullet2   = LoadValue( txEnemyBullet2 );
    vec4 enemyBullet3   = LoadValue( txEnemyBullet3 );
    vec4 bossBullet0	= LoadValue( txBossBullet0 );
    vec4 bossBullet1	= LoadValue( txBossBullet1 );
    vec4 powerUp        = LoadValue( txPowerUp );    
    vec4 explosion      = LoadValue( txExplosion );
    vec4 hit            = LoadValue( txHit );    
    vec4 gameState      = LoadValue( txGameState );

    float worldX        = pixelX + camera.x;
    float worldY        = pixelY - 8.0;    

    vec2 screenUV = fragCoord.xy / iResolution.xy;
    vec3 color = texture( iChannel1, screenUV ).xyz; 
    
    SpritePowerUp( color, worldX - powerUp.x + POWER_UP_SIZE.x * 0.5, worldY - powerUp.y, powerUp.z );
    if ( playerWeapon.x == WEAPON_RIFLE )
    {
        SpriteBullet( color, worldX - playerBullet0.x + 1.0, worldY - playerBullet0.y );
        SpriteBullet( color, worldX - playerBullet1.x + 1.0, worldY - playerBullet1.y );
        SpriteBullet( color, worldX - playerBullet2.x + 1.0, worldY - playerBullet2.y );
        SpriteBullet( color, worldX - playerBullet3.x + 1.0, worldY - playerBullet3.y );
        SpriteBullet( color, worldX - playerBullet4.x + 1.0, worldY - playerBullet4.y );
        SpriteBullet( color, worldX - playerBullet5.x + 1.0, worldY - playerBullet5.y );
    }
    else
    {
        SpritePowerBullet( color, worldX - playerBullet0.x + 2.0, worldY - playerBullet0.y );
        SpritePowerBullet( color, worldX - playerBullet1.x + 2.0, worldY - playerBullet1.y );
        SpritePowerBullet( color, worldX - playerBullet2.x + 2.0, worldY - playerBullet2.y );
        SpritePowerBullet( color, worldX - playerBullet3.x + 2.0, worldY - playerBullet3.y );
        SpritePowerBullet( color, worldX - playerBullet4.x + 2.0, worldY - playerBullet4.y );
        SpritePowerBullet( color, worldX - playerBullet5.x + 2.0, worldY - playerBullet5.y );
    }
    SpriteBullet( color, worldX - enemyBullet0.x + 1.0, worldY - enemyBullet0.y );
    SpriteBullet( color, worldX - enemyBullet1.x + 1.0, worldY - enemyBullet1.y );
    SpriteBullet( color, worldX - enemyBullet2.x + 1.0, worldY - enemyBullet2.y );
    SpriteBullet( color, worldX - enemyBullet3.x + 1.0, worldY - enemyBullet3.y );
	SpritePowerBullet( color, worldX - bossBullet0.x + 2.0, worldY - bossBullet0.y );
	SpritePowerBullet( color, worldX - bossBullet1.x + 2.0, worldY - bossBullet1.y );    
    SpriteExplosion( color, worldX - explosion.x, worldY - explosion.y, explosion.z );
    SpriteHit( color, worldX - hit.x, worldY - hit.y );      
    
    if ( pixelX > 32.0 && pixelX < 32.0 + 8.0 * ( playerState.w - 1.0 ) )
    {
        SpriteLife( color, pixelX, pixelY - screenHeight + 32.0 );
    }
    
    if ( gameState.x == GAME_STATE_TITLE )
    {
        color = vec3( 0.0 );
        SpriteStage1( color, pixelX - floor( screenWidth * 0.5 - 30.5 ), pixelY - floor( screenHeight * 0.5 - 10.5 ) );
        SpriteJungle( color, pixelX - floor( screenWidth * 0.5 - 30.5 ), pixelY - floor( screenHeight * 0.5 + 10.5 ) );
    }
    else if ( gameState.x == GAME_STATE_GAME_OVER )
    {
        color = vec3( 0.0 );
        SpriteGameOver( color, pixelX - floor( screenWidth * 0.5 - 36.5 ), pixelY - floor( screenHeight * 0.5 ) );
    }
    else if ( gameState.x == GAME_STATE_VICTORY )
    {
        // water / sky
        color = pixelY < 80.0 ? RGB( 0, 112, 236 ) : vec3( 0.0 );
        
        // stars
        float starRand = Rand( vec2( worldX * 0.01, worldY * 0.01 ) );
        if ( starRand > 0.998 && worldY > 130.0 )
        {
            color = fract( iTime + starRand * 113.17 + worldX * 3.14 ) < 0.5 ? RGB( 255, 255, 255 ) : RGB( 0, 112, 236 );
        }        
        
        SpriteVictory( color, pixelX - floor( screenWidth * 0.5 - 63.5 ), pixelY - floor( screenHeight * 0.5 ) - 20.0 );
        SpriteHelicopter( color, floor( pixelX - screenWidth * ( 0.25 + 0.5 * ( 1.0 - gameState.y / UI_VICTORY_TIME ) ) ), pixelY - 90.0 );
    }
    else if ( gameState.x == GAME_STATE_LEVEL )
    {
		float fadeAlpha = clamp( ( gameState.y - 30.0 ) / 30.0, 0.0, 1.0 );
        color = pixelX < fadeAlpha * screenWidth ? color : vec3( 0.0 );
    }
    
    fragColor = vec4( color, 1.0 );
}
