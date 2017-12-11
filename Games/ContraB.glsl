
// Background

#define SPRITE_DEC_2( x, i ) mod( floor( i / pow( 2.0, mod( x, 24.0 ) ) ), 2.0 )
#define SPRITE_DEC_3( x, i ) mod( floor( i / pow( 4.0, mod( x, 11.0 ) ) ), 4.0 )
#define SPRITE_DEC_4( x, i ) mod( floor( i / pow( 4.0, mod( x, 8.0 ) ) ), 4.0 )
#define RGB( r, g, b ) vec3( float( r ) / 255.0, float( g ) / 255.0, float( b ) / 255.0 )

const float NES_RES_X           = 224.0;
const float NES_RES_Y           = 192.0;
const float JUNGLE_START        = 32.0 * 52.0;
const float JUNGLE_END          = 32.0 * 108.0 + 16.0;
const float WATER_END           = 32.0 * 63.0;
const vec2  BOSS_CORE_SIZE      = vec2( 24.0, 31.0 );
const vec2  BOSS_CANNON_SIZE    = vec2( 14.0, 6.0 );
const float BRIDGE_0_START_TILE = 30.0;
const float BRIDGE_0_END_TILE   = 35.0;
const float BRIDGE_1_START_TILE = 40.0;
const float BRIDGE_1_END_TILE   = 45.0;

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

float Rand( vec2 co )
{
    return fract( sin( dot( co.xy, vec2( 12.9898, 78.233 ) ) ) * 43758.5453 );
}

vec4 LoadValue( vec2 tx )
{
    return floor( texture( iChannel0, ( tx + 0.5 ) / iChannelResolution[ 0 ].xy ) );
}

void SpriteBush( inout vec3 color, float x, float y )
{
    float idx = 0.0;    
    
    idx = y == 8.0 ? ( x <= 10.0 ? 1419584.0 : ( x <= 21.0 ? 1.0 : 1360.0 ) ) : idx;
    idx = y == 7.0 ? ( x <= 10.0 ? 2796196.0 : ( x <= 21.0 ? 21.0 : 22176.0 ) ) : idx;
    idx = y == 6.0 ? ( x <= 10.0 ? 2796201.0 : ( x <= 21.0 ? 87125.0 : 87721.0 ) ) : idx;
    idx = y == 5.0 ? ( x <= 10.0 ? 2534058.0 : ( x <= 21.0 ? 436310.0 : 88681.0 ) ) : idx;
    idx = y == 4.0 ? ( x <= 10.0 ? 1681065.0 : ( x <= 21.0 ? 365637.0 : 71061.0 ) ) : idx;
    idx = y == 3.0 ? ( x <= 10.0 ? 1464937.0 : ( x <= 21.0 ? 91137.0 : 1381.0 ) ) : idx;
    idx = y == 2.0 ? ( x <= 10.0 ? 1332565.0 : ( x <= 21.0 ? 283908.0 : 266564.0 ) ) : idx;
    idx = y == 1.0 ? ( x <= 10.0 ? 332884.0 : ( x <= 21.0 ? 267328.0 : 65616.0 ) ) : idx;

    idx = SPRITE_DEC_3( x, idx );

    color = y >= 0.0 && y < 9.0 ? RGB( 0, 0, 0 ) : color;
    color = idx == 1.0 ? RGB( 0,   144, 0 ) : color;
    color = idx == 2.0 ? RGB( 144, 213, 0 ) : color;
}

void SpriteRockTop( inout vec3 color, float x, float y )
{
    float idx = 0.0;    
    
    idx = y == 7.0 ? ( x <= 7.0 ? 20480.0 : ( x <= 15.0 ? 89.0 : ( x <= 23.0 ? 0.0 : 341.0 ) ) ) : idx;
    idx = y == 6.0 ? ( x <= 7.0 ? 38144.0 : ( x <= 15.0 ? 5466.0 : ( x <= 23.0 ? 20480.0 : 5466.0 ) ) ) : idx;
    idx = y == 5.0 ? ( x <= 7.0 ? 43604.0 : ( x <= 15.0 ? 21851.0 : ( x <= 23.0 ? 42305.0 : 1386.0 ) ) ) : idx;
    idx = y == 4.0 ? ( x <= 7.0 ? 65168.0 : ( x <= 15.0 ? 21866.0 : ( x <= 23.0 ? 43345.0 : 1387.0 ) ) ) : idx;
    idx = y == 3.0 ? ( x <= 7.0 ? 47680.0 : ( x <= 15.0 ? 21914.0 : ( x <= 23.0 ? 64144.0 : 5547.0 ) ) ) : idx;
    idx = y == 2.0 ? ( x <= 7.0 ? 43269.0 : ( x <= 15.0 ? 5718.0 : ( x <= 23.0 ? 65188.0 : 5526.0 ) ) ) : idx;
    idx = y == 1.0 ? ( x <= 7.0 ? 20584.0 : ( x <= 15.0 ? 1.0 : ( x <= 23.0 ? 60329.0 : 22102.0 ) ) ) : idx;
    idx = y == 0.0 ? ( x <= 7.0 ? 5860.0 : ( x <= 15.0 ? 0.0 : ( x <= 23.0 ? 43769.0 : 22101.0 ) ) ) : idx;
    
    idx = SPRITE_DEC_4( x, idx );
    idx = x >= 0.0 && x < 32.0 ? idx : 0.0;
    
    color = x >= 0.0 && x < 32.0 && y >= 0.0 && y < 8.0 ? RGB( 0, 0, 0 ) : color;
    color = idx == 1.0 ? RGB( 68,  80,  0 ) : color;
    color = idx == 2.0 ? RGB( 126, 126, 0 ) : color;
    color = idx == 3.0 ? RGB( 208, 190, 0 ) : color;
}

void SpriteRock( inout vec3 color, float x, float y )
{
    float idx = 0.0;    
    
    idx = y == 31.0 ? ( x <= 7.0 ? 5860.0 : ( x <= 15.0 ? 0.0 : ( x <= 23.0 ? 43769.0 : 22101.0 ) ) ) : idx;
    idx = y == 30.0 ? ( x <= 7.0 ? 1444.0 : ( x <= 15.0 ? 1365.0 : ( x <= 23.0 ? 45049.0 : 22869.0 ) ) ) : idx;
    idx = y == 29.0 ? ( x <= 7.0 ? 17809.0 : ( x <= 15.0 ? 6826.0 : ( x <= 23.0 ? 32420.0 : 22869.0 ) ) ) : idx;
    idx = y == 28.0 ? ( x <= 7.0 ? 37201.0 : ( x <= 15.0 ? 27311.0 : ( x <= 23.0 ? 27284.0 : 25941.0 ) ) ) : idx;
    idx = y == 27.0 ? ( x <= 7.0 ? 57669.0 : ( x <= 15.0 ? 27327.0 : ( x <= 23.0 ? 43668.0 : 25941.0 ) ) ) : idx;
    idx = y == 26.0 ? ( x <= 7.0 ? 58373.0 : ( x <= 15.0 ? 43695.0 : ( x <= 23.0 ? 43601.0 : 38229.0 ) ) ) : idx;
    idx = y == 25.0 ? ( x <= 7.0 ? 63765.0 : ( x <= 15.0 ? 43695.0 : ( x <= 23.0 ? 43345.0 : 38230.0 ) ) ) : idx;
    idx = y == 24.0 ? ( x <= 7.0 ? 63764.0 : ( x <= 15.0 ? 43695.0 : ( x <= 23.0 ? 42322.0 : 38234.0 ) ) ) : idx;
    idx = y == 23.0 ? ( x <= 7.0 ? 63748.0 : ( x <= 15.0 ? 43695.0 : ( x <= 23.0 ? 42310.0 : 21866.0 ) ) ) : idx;
    idx = y == 22.0 ? ( x <= 7.0 ? 65088.0 : ( x <= 15.0 ? 43711.0 : ( x <= 23.0 ? 42266.0 : 5486.0 ) ) ) : idx;
    idx = y == 21.0 ? ( x <= 7.0 ? 65092.0 : ( x <= 15.0 ? 43711.0 : ( x <= 23.0 ? 37914.0 : 5566.0 ) ) ) : idx;
    idx = y == 20.0 ? ( x <= 7.0 ? 65088.0 : ( x <= 15.0 ? 43775.0 : ( x <= 23.0 ? 20570.0 : 5886.0 ) ) ) : idx;
    idx = y == 19.0 ? ( x <= 7.0 ? 65089.0 : ( x <= 15.0 ? 43775.0 : ( x <= 23.0 ? 20570.0 : 5881.0 ) ) ) : idx;
    idx = y == 18.0 ? ( x <= 7.0 ? 64145.0 : ( x <= 15.0 ? 44031.0 : ( x <= 23.0 ? 20570.0 : 1445.0 ) ) ) : idx;
    idx = y == 17.0 ? ( x <= 7.0 ? 43664.0 : ( x <= 15.0 ? 44031.0 : ( x <= 23.0 ? 16730.0 : 1429.0 ) ) ) : idx;
    idx = y == 16.0 ? ( x <= 7.0 ? 43664.0 : ( x <= 15.0 ? 44798.0 : ( x <= 23.0 ? 16730.0 : 18005.0 ) ) ) : idx;
    idx = y == 15.0 ? ( x <= 7.0 ? 44004.0 : ( x <= 15.0 ? 22266.0 : ( x <= 23.0 ? 16741.0 : 18005.0 ) ) ) : idx;
    idx = y == 14.0 ? ( x <= 7.0 ? 45049.0 : ( x <= 15.0 ? 21930.0 : ( x <= 23.0 ? 1381.0 : 1621.0 ) ) ) : idx;
    idx = y == 13.0 ? ( x <= 7.0 ? 49065.0 : ( x <= 15.0 ? 21930.0 : ( x <= 23.0 ? 1429.0 : 1365.0 ) ) ) : idx;
    idx = y == 12.0 ? ( x <= 7.0 ? 60073.0 : ( x <= 15.0 ? 21867.0 : ( x <= 23.0 ? 1429.0 : 340.0 ) ) ) : idx;
    idx = y == 11.0 ? ( x <= 7.0 ? 43689.0 : ( x <= 15.0 ? 21846.0 : ( x <= 23.0 ? 1109.0 : 340.0 ) ) ) : idx;
    idx = y == 10.0 ? ( x <= 7.0 ? 43690.0 : ( x <= 15.0 ? 21846.0 : ( x <= 23.0 ? 357.0 : 340.0 ) ) ) : idx;
    idx = y == 9.0 ? ( x <= 7.0 ? 38566.0 : ( x <= 15.0 ? 21849.0 : ( x <= 23.0 ? 1049.0 : 336.0 ) ) ) : idx;
    idx = y == 8.0 ? ( x <= 7.0 ? 25941.0 : ( x <= 15.0 ? 21849.0 : ( x <= 23.0 ? 4101.0 : 256.0 ) ) ) : idx;
    idx = y == 7.0 ? ( x <= 7.0 ? 25941.0 : ( x <= 15.0 ? 21861.0 : ( x <= 23.0 ? 1.0 : 21.0 ) ) ) : idx;
    idx = y == 6.0 ? ( x <= 7.0 ? 22868.0 : ( x <= 15.0 ? 23141.0 : ( x <= 23.0 ? 20480.0 : 361.0 ) ) ) : idx;
    idx = y == 5.0 ? ( x <= 7.0 ? 21840.0 : ( x <= 15.0 ? 5525.0 : ( x <= 23.0 ? 42240.0 : 5546.0 ) ) ) : idx;
    idx = y == 4.0 ? ( x <= 7.0 ? 20800.0 : ( x <= 15.0 ? 5377.0 : ( x <= 23.0 ? 64080.0 : 1451.0 ) ) ) : idx;
    idx = y == 3.0 ? ( x <= 7.0 ? 4096.0 : ( x <= 15.0 ? 1024.0 : ( x <= 23.0 ? 65428.0 : 1391.0 ) ) ) : idx;
    idx = y == 2.0 ? ( x <= 7.0 ? 16464.0 : ( x <= 15.0 ? 1024.0 : ( x <= 23.0 ? 65188.0 : 5531.0 ) ) ) : idx;
    idx = y == 1.0 ? ( x <= 7.0 ? 5541.0 : ( x <= 15.0 ? 4097.0 : ( x <= 23.0 ? 60069.0 : 5526.0 ) ) ) : idx;
    idx = y == 0.0 ? ( x <= 7.0 ? 23288.0 : ( x <= 15.0 ? 0.0 : ( x <= 23.0 ? 43705.0 : 22101.0 ) ) ) : idx;

    idx = SPRITE_DEC_4( x, idx );
    idx = x >= 0.0 && x < 32.0 ? idx : 0.0;
    
    color = x >= 0.0 && x < 32.0 && y >= 0.0 && y < 32.0 ? RGB( 0, 0, 0 ) : color;
    color = idx == 1.0 ? RGB( 68,  80,  0 ) : color;
    color = idx == 2.0 ? RGB( 126, 126, 0 ) : color;
    color = idx == 3.0 ? RGB( 208, 190, 0 ) : color;
}

void SpriteTreeTrunk( inout vec3 color, float x, float y )
{
    float idx = 0.0;
    
    idx = y == 1.0 ? 2918701.0 : idx;
    idx = y == 0.0 ? 1263122.0 : idx;
    
    idx = SPRITE_DEC_2( x, idx );
    
    color = idx == 1.0 ? RGB( 64,  44,  0 ) : RGB( 0,  0,  0 );
}

void SpriteTreeStart( inout vec3 color, float x, float y )
{
    float idx = 0.0;
    
	idx = y == 22.0 ? 32768.0 : idx;
	idx = y == 21.0 ? 10240.0 : idx;
	idx = y == 20.0 ? 9088.0 : idx;
	idx = y == 19.0 ? 10976.0 : idx;
	idx = y == 18.0 ? 9016.0 : idx;
	idx = y == 17.0 ? 33580.0 : idx;
	idx = y == 16.0 ? 2874.0 : idx;
	idx = y == 15.0 ? 41644.0 : idx;
	idx = y == 14.0 ? 13240.0 : idx;
	idx = y == 13.0 ? 824.0 : idx;
	idx = y == 12.0 ? 4128.0 : idx;
	idx = y == 11.0 ? 17408.0 : idx;
	idx = y == 10.0 ? 1024.0 : idx;
	idx = y == 9.0 ? 34048.0 : idx;
	idx = y == 8.0 ? 33024.0 : idx;
	idx = y == 7.0 ? 0.0 : idx;
	idx = y == 6.0 ? 51840.0 : idx;
	idx = y == 5.0 ? 44000.0 : idx;
	idx = y == 4.0 ? 1760.0 : idx;
	idx = y == 3.0 ? 17584.0 : idx;
	idx = y == 2.0 ? 17440.0 : idx;
	idx = y == 1.0 ? 17440.0 : idx;
	idx = y == 0.0 ? 16384.0 : idx;
    
    idx = SPRITE_DEC_4( x, idx );
    idx = x >= 0.0 && x < 8.0 ? idx : 0.0;

    color = x >= 0.0 && x < 8.0 && y >= 0.0 && y < 24.0 ? RGB( 0, 0, 0 ) : color;
    color = idx == 1.0 ? RGB( 64, 44, 0 ) : color;
    color = idx == 2.0 ? RGB( 0, 148, 0 ) : color;    
    color = idx == 3.0 ? RGB( 128, 208, 16 ) : color;
}

void SpriteTreeMiddle( inout vec3 color, float x, float y )
{
    float idx = 0.0;
    
    idx = y == 23.0 ? ( x <= 7.0 ? 10240.0 : 0.0 ) : idx;
    idx = y == 22.0 ? ( x <= 7.0 ? 48770.0 : 2688.0 ) : idx;
    idx = y == 21.0 ? ( x <= 7.0 ? 10283.0 : 12266.0 ) : idx;
    idx = y == 20.0 ? ( x <= 7.0 ? 32959.0 : 48059.0 ) : idx;
    idx = y == 19.0 ? ( x <= 7.0 ? 58080.0 : 44782.0 ) : idx;
    idx = y == 18.0 ? ( x <= 7.0 ? 35470.0 : 12012.0 ) : idx;
    idx = y == 17.0 ? ( x <= 7.0 ? 8763.0 : 2248.0 ) : idx;
    idx = y == 16.0 ? ( x <= 7.0 ? 35723.0 : 32898.0 ) : idx;
    idx = y == 15.0 ? ( x <= 7.0 ? 11835.0 : 57866.0 ) : idx;
    idx = y == 14.0 ? ( x <= 7.0 ? 15155.0 : 57896.0 ) : idx;
    idx = y == 13.0 ? ( x <= 7.0 ? 60450.0 : 45240.0 ) : idx;
    idx = y == 12.0 ? ( x <= 7.0 ? 60480.0 : 8930.0 ) : idx;
    idx = y == 11.0 ? ( x <= 7.0 ? 60481.0 : 930.0 ) : idx;
    idx = y == 10.0 ? ( x <= 7.0 ? 51280.0 : 4738.0 ) : idx;
    idx = y == 9.0 ? ( x <= 7.0 ? 49234.0 : 4226.0 ) : idx;
    idx = y == 8.0 ? ( x <= 7.0 ? 32848.0 : 4096.0 ) : idx;
    idx = y == 7.0 ? ( x <= 7.0 ? 32852.0 : 16416.0 ) : idx;
    idx = y == 6.0 ? ( x <= 7.0 ? 23.0 : 18528.0 ) : idx;
    idx = y == 5.0 ? ( x <= 7.0 ? 30.0 : 18536.0 ) : idx;
    idx = y == 4.0 ? ( x <= 7.0 ? 17464.0 : 18536.0 ) : idx;
    idx = y == 3.0 ? ( x <= 7.0 ? 1064.0 : 18504.0 ) : idx;
    idx = y == 2.0 ? ( x <= 7.0 ? 1312.0 : 16448.0 ) : idx;
    idx = y == 1.0 ? ( x <= 7.0 ? 17668.0 : 18496.0 ) : idx;
    idx = y == 0.0 ? ( x <= 7.0 ? 16660.0 : 16448.0 ) : idx;
    
    idx = SPRITE_DEC_4( x, idx );
    idx = x >= 0.0 && x < 16.0 ? idx : 0.0;

    color = x >= 0.0 && x < 16.0 && y >= 0.0 && y < 24.0 ? RGB( 0, 0, 0 ) : color;
    color = idx == 1.0 ? RGB( 64, 44, 0 ) : color;
    color = idx == 2.0 ? RGB( 0, 148, 0 ) : color;    
    color = idx == 3.0 ? RGB( 128, 208, 16 ) : color;
}

void SpriteTreeEnd( inout vec3 color, float x, float y )
{
    float idx = 0.0;
    
	idx = y == 17.0 ? 960.0 : idx;
	idx = y == 16.0 ? 2744.0 : idx;
	idx = y == 15.0 ? 8227.0 : idx;
	idx = y == 14.0 ? 3022.0 : idx;
	idx = y == 13.0 ? 48674.0 : idx;
	idx = y == 12.0 ? 41136.0 : idx;
	idx = y == 11.0 ? 52192.0 : idx;
	idx = y == 10.0 ? 36516.0 : idx;
	idx = y == 9.0 ? 15140.0 : idx;
	idx = y == 8.0 ? 15108.0 : idx;
	idx = y == 7.0 ? 12292.0 : idx;
	idx = y == 6.0 ? 8452.0 : idx;
	idx = y == 5.0 ? 68.0 : idx;
	idx = y == 4.0 ? 68.0 : idx;
	idx = y == 3.0 ? 68.0 : idx;
	idx = y == 2.0 ? 20.0 : idx;
	idx = y == 1.0 ? 20.0 : idx;
	idx = y == 0.0 ? 20.0 : idx;
    
    idx = SPRITE_DEC_4( x, idx );
    idx = x >= 0.0 && x < 8.0 ? idx : 0.0;

    color = x >= 0.0 && x < 8.0 && y >= 0.0 && y < 24.0 ? RGB( 0, 0, 0 ) : color;
    color = idx == 1.0 ? RGB( 64, 44, 0 ) : color;
    color = idx == 2.0 ? RGB( 0, 148, 0 ) : color;    
    color = idx == 3.0 ? RGB( 128, 208, 16 ) : color;
}

void SpriteBridge( inout vec3 color, float x, float y )
{
    float idx = 0.0;
    
	idx = y == 26.0 ? ( x <= 10.0 ? 349509.0 : ( x <= 21.0 ? 1381717.0 : 349269.0 ) ) : idx;
	idx = y == 25.0 ? ( x <= 10.0 ? 349573.0 : ( x <= 21.0 ? 1447254.0 : 350293.0 ) ) : idx;
	idx = y == 24.0 ? ( x <= 10.0 ? 2184545.0 : ( x <= 21.0 ? 1410389.0 : 349717.0 ) ) : idx;
	idx = y == 23.0 ? ( x <= 10.0 ? 2184545.0 : ( x <= 21.0 ? 1410389.0 : 349717.0 ) ) : idx;
	idx = y == 22.0 ? ( x <= 10.0 ? 1594712.0 : ( x <= 21.0 ? 1401173.0 : 349573.0 ) ) : idx;
	idx = y == 21.0 ? ( x <= 10.0 ? 1594712.0 : ( x <= 21.0 ? 1401173.0 : 349573.0 ) ) : idx;
	idx = y == 20.0 ? ( x <= 10.0 ? 2730665.0 : ( x <= 21.0 ? 2795178.0 : 699034.0 ) ) : idx;
	idx = y == 19.0 ? ( x <= 10.0 ? 1594712.0 : ( x <= 21.0 ? 1398101.0 : 349573.0 ) ) : idx;
	idx = y == 18.0 ? ( x <= 10.0 ? 546136.0 : ( x <= 21.0 ? 0.0 : 349576.0 ) ) : idx;
	idx = y == 17.0 ? ( x <= 10.0 ? 524288.0 : ( x <= 21.0 ? 0.0 : 8.0 ) ) : idx;
	idx = y == 16.0 ? ( x <= 10.0 ? 567976.0 : ( x <= 21.0 ? 0.0 : 699016.0 ) ) : idx;
	idx = y == 15.0 ? ( x <= 10.0 ? 2643288.0 : ( x <= 21.0 ? 2796202.0 : 349578.0 ) ) : idx;
	idx = y == 14.0 ? ( x <= 10.0 ? 1594712.0 : ( x <= 21.0 ? 1398101.0 : 349573.0 ) ) : idx;
	idx = y == 11.0 ? ( x <= 10.0 ? 26729.0 : ( x <= 21.0 ? 2204672.0 : 6.0 ) ) : idx;
	idx = y == 10.0 ? ( x <= 10.0 ? 5140.0 : ( x <= 21.0 ? 1069056.0 : 1.0 ) ) : idx;
	idx = y == 9.0 ? ( x <= 10.0 ? 1397865.0 : ( x <= 21.0 ? 1156437.0 : 349525.0 ) ) : idx;
	idx = y == 8.0 ? ( x <= 10.0 ? 2791700.0 : ( x <= 21.0 ? 2380458.0 : 699049.0 ) ) : idx;
	idx = y == 7.0 ? ( x <= 10.0 ? 1393769.0 : ( x <= 21.0 ? 1156437.0 : 349524.0 ) ) : idx;
	idx = y == 6.0 ? ( x <= 10.0 ? 20.0 : ( x <= 21.0 ? 20480.0 : 0.0 ) ) : idx;
	idx = y == 5.0 ? ( x <= 10.0 ? 105.0 : ( x <= 21.0 ? 107520.0 : 0.0 ) ) : idx;
	idx = y == 4.0 ? ( x <= 10.0 ? 20.0 : ( x <= 21.0 ? 20480.0 : 0.0 ) ) : idx;
	idx = y == 3.0 ? ( x <= 10.0 ? 1398149.0 : ( x <= 21.0 ? 1447253.0 : 349525.0 ) ) : idx;
	idx = y == 2.0 ? ( x <= 10.0 ? 2796193.0 : ( x <= 21.0 ? 2786986.0 : 699050.0 ) ) : idx;
	idx = y == 1.0 ? ( x <= 10.0 ? 1398113.0 : ( x <= 21.0 ? 1410389.0 : 349525.0 ) ) : idx;
	idx = y == 0.0 ? ( x <= 10.0 ? 1398085.0 : ( x <= 21.0 ? 1381717.0 : 349525.0 ) ) : idx;  

    idx = SPRITE_DEC_3( x, idx );
    idx = x >= 0.0 && x < 32.0 ? idx : 0.0;
    
    color = x >= 0.0 && x < 32.0 && y >= 0.0 && y < 13.0 ? RGB( 0, 0, 0 ) : color;
    
    float blink = abs( sin( iTime * 3.0 ) ) + 0.5;
    color = x >= 12.0 && x < 24.0 && y >= 17.0 && y < 19.0 ? blink * RGB( 228, 68, 52 ) : color;
    color = idx == 1.0 ? RGB( 179, 179, 179 ) : color;
    color = idx == 2.0 ? RGB( 255, 255, 255 ) : color;    
}

void SpriteGrass( inout vec3 color, float x, float y )
{
    float idx = 0.0;
    
    idx = y == 15.0 ? ( x <= 10.0 ? 1398096.0 : ( x <= 21.0 ? 1398101.0 : 87381.0 ) ) : idx;
    idx = y == 14.0 ? ( x <= 10.0 ? 1398101.0 : ( x <= 21.0 ? 1398101.0 : 349525.0 ) ) : idx;
    idx = y == 13.0 ? ( x <= 10.0 ? 1398101.0 : ( x <= 21.0 ? 1398101.0 : 349525.0 ) ) : idx;
    idx = y == 12.0 ? ( x <= 10.0 ? 1398101.0 : ( x <= 21.0 ? 1398101.0 : 349525.0 ) ) : idx;
    idx = y == 11.0 ? ( x <= 10.0 ? 1398102.0 : ( x <= 21.0 ? 1398101.0 : 349525.0 ) ) : idx;
    idx = y == 10.0 ? ( x <= 10.0 ? 1418921.0 : ( x <= 21.0 ? 1398102.0 : 419158.0 ) ) : idx;
    idx = y == 9.0 ? ( x <= 10.0 ? 2779749.0 : ( x <= 21.0 ? 2796202.0 : 285353.0 ) ) : idx;
    idx = y == 8.0 ? ( x <= 10.0 ? 2796197.0 : ( x <= 21.0 ? 2791078.0 : 345494.0 ) ) : idx;
    idx = y == 7.0 ? ( x <= 10.0 ? 1681049.0 : ( x <= 21.0 ? 1468826.0 : 70997.0 ) ) : idx;
    idx = y == 6.0 ? ( x <= 10.0 ? 2517412.0 : ( x <= 21.0 ? 2463126.0 : 280153.0 ) ) : idx;
    idx = y == 5.0 ? ( x <= 10.0 ? 1681057.0 : ( x <= 21.0 ? 2459241.0 : 71013.0 ) ) : idx;
    idx = y == 4.0 ? ( x <= 10.0 ? 2468240.0 : ( x <= 21.0 ? 1448218.0 : 267413.0 ) ) : idx;
    idx = y == 3.0 ? ( x <= 10.0 ? 1137172.0 : ( x <= 21.0 ? 332905.0 : 20818.0 ) ) : idx;
    idx = y == 2.0 ? ( x <= 10.0 ? 1148161.0 : ( x <= 21.0 ? 332900.0 : 325.0 ) ) : idx;
    idx = y == 1.0 ? ( x <= 10.0 ? 16640.0 : ( x <= 21.0 ? 69648.0 : 68.0 ) ) : idx;
    
    idx = SPRITE_DEC_3( x, idx );
    idx = x >= 0.0 && x < 32.0 ? idx : 0.0;

    color = x >= 0.0 && x < 32.0 && y >= 0.0 && y < 16.0 ? RGB( 0, 0, 0 ) : color;
    color = idx == 1.0 ? RGB( 0,   144, 0 ) : color;
    color = idx == 2.0 ? RGB( 144, 213, 0 ) : color;
}

void SpriteLeaves( inout vec3 color, float x, float y )
{
    float idx = 0.0;
    
    idx = y == 29.0 ? ( x <= 7.0 ? 8224.0 : ( x <= 15.0 ? 514.0 : ( x <= 23.0 ? 10400.0 : 41122.0 ) ) ) : idx;
    idx = y == 28.0 ? ( x <= 7.0 ? 35330.0 : ( x <= 15.0 ? 2110.0 : ( x <= 23.0 ? 14496.0 : 35723.0 ) ) ) : idx;
    idx = y == 27.0 ? ( x <= 7.0 ? 41090.0 : ( x <= 15.0 ? 995.0 : ( x <= 23.0 ? 12996.0 : 11788.0 ) ) ) : idx;
    idx = y == 26.0 ? ( x <= 7.0 ? 14466.0 : ( x <= 15.0 ? 3595.0 : ( x <= 23.0 ? 58256.0 : 14380.0 ) ) ) : idx;
    idx = y == 25.0 ? ( x <= 7.0 ? 36352.0 : ( x <= 15.0 ? 2223.0 : ( x <= 23.0 ? 57860.0 : 47928.0 ) ) ) : idx;
    idx = y == 24.0 ? ( x <= 7.0 ? 58240.0 : ( x <= 15.0 ? 8958.0 : ( x <= 23.0 ? 57424.0 : 64312.0 ) ) ) : idx;
    idx = y == 23.0 ? ( x <= 7.0 ? 47810.0 : ( x <= 15.0 ? 2956.0 : ( x <= 23.0 ? 12288.0 : 51772.0 ) ) ) : idx;
    idx = y == 22.0 ? ( x <= 7.0 ? 14338.0 : ( x <= 15.0 ? 3631.0 : ( x <= 23.0 ? 0.0 : 52012.0 ) ) ) : idx;
    idx = y == 21.0 ? ( x <= 7.0 ? 35842.0 : ( x <= 15.0 ? 2091.0 : ( x <= 23.0 ? 10250.0 : 776.0 ) ) ) : idx;
    idx = y == 20.0 ? ( x <= 7.0 ? 51200.0 : ( x <= 15.0 ? 50.0 : ( x <= 23.0 ? 8352.0 : 712.0 ) ) ) : idx;
    idx = y == 19.0 ? ( x <= 7.0 ? 34818.0 : ( x <= 15.0 ? 40992.0 : ( x <= 23.0 ? 43650.0 : 32896.0 ) ) ) : idx;
    idx = y == 18.0 ? ( x <= 7.0 ? 40.0 : ( x <= 15.0 ? 2048.0 : ( x <= 23.0 ? 552.0 : 2570.0 ) ) ) : idx;
    idx = y == 17.0 ? ( x <= 7.0 ? 128.0 : ( x <= 15.0 ? 11256.0 : ( x <= 23.0 ? 8367.0 : 8232.0 ) ) ) : idx;
    idx = y == 16.0 ? ( x <= 7.0 ? 42.0 : ( x <= 15.0 ? 64010.0 : ( x <= 23.0 ? 35458.0 : 35328.0 ) ) ) : idx;
    idx = y == 15.0 ? ( x <= 7.0 ? 128.0 : ( x <= 15.0 ? 44960.0 : ( x <= 23.0 ? 34863.0 : 49282.0 ) ) ) : idx;
    idx = y == 14.0 ? ( x <= 7.0 ? 32783.0 : ( x <= 15.0 ? 3055.0 : ( x <= 23.0 ? 12472.0 : 63522.0 ) ) ) : idx;
    idx = y == 13.0 ? ( x <= 7.0 ? 63544.0 : ( x <= 15.0 ? 63738.0 : ( x <= 23.0 ? 58080.0 : 52736.0 ) ) ) : idx;
    idx = y == 12.0 ? ( x <= 7.0 ? 11778.0 : ( x <= 15.0 ? 33772.0 : ( x <= 23.0 ? 52111.0 : 50050.0 ) ) ) : idx;
    idx = y == 11.0 ? ( x <= 7.0 ? 49195.0 : ( x <= 15.0 ? 16014.0 : ( x <= 23.0 ? 2606.0 : 45187.0 ) ) ) : idx;
    idx = y == 10.0 ? ( x <= 7.0 ? 64686.0 : ( x <= 15.0 ? 14383.0 : ( x <= 23.0 ? 3128.0 : 60419.0 ) ) ) : idx;
    idx = y == 9.0 ? ( x <= 7.0 ? 11020.0 : ( x <= 15.0 ? 57599.0 : ( x <= 23.0 ? 3248.0 : 58114.0 ) ) ) : idx;
    idx = y == 8.0 ? ( x <= 7.0 ? 35532.0 : ( x <= 15.0 ? 50419.0 : ( x <= 23.0 ? 35040.0 : 12800.0 ) ) ) : idx;
    idx = y == 7.0 ? ( x <= 7.0 ? 57480.0 : ( x <= 15.0 ? 50050.0 : ( x <= 23.0 ? 227.0 : 12304.0 ) ) ) : idx;
    idx = y == 6.0 ? ( x <= 7.0 ? 45232.0 : ( x <= 15.0 ? 35595.0 : ( x <= 23.0 ? 131.0 : 8257.0 ) ) ) : idx;
    idx = y == 5.0 ? ( x <= 7.0 ? 59428.0 : ( x <= 15.0 ? 3640.0 : ( x <= 23.0 ? 258.0 : 20.0 ) ) ) : idx;
    idx = y == 4.0 ? ( x <= 7.0 ? 35361.0 : ( x <= 15.0 ? 10272.0 : ( x <= 23.0 ? 1104.0 : 32833.0 ) ) ) : idx;
    idx = y == 3.0 ? ( x <= 7.0 ? 33284.0 : ( x <= 15.0 ? 8354.0 : ( x <= 23.0 ? 261.0 : 8212.0 ) ) ) : idx;
    idx = y == 2.0 ? ( x <= 7.0 ? 1105.0 : ( x <= 15.0 ? 8706.0 : ( x <= 23.0 ? 1104.0 : 10305.0 ) ) ) : idx;
    idx = y == 1.0 ? ( x <= 7.0 ? 260.0 : ( x <= 15.0 ? 532.0 : ( x <= 23.0 ? 261.0 : 8212.0 ) ) ) : idx;
    idx = y == 0.0 ? ( x <= 7.0 ? 1105.0 : ( x <= 15.0 ? 16449.0 : ( x <= 23.0 ? 1104.0 : 2113.0 ) ) ) : idx;
    
    idx = SPRITE_DEC_4( x, idx );

    color = RGB( 0, 0, 0 );
    color = idx == 1.0 ? RGB( 64,  44,  0  ) : color;
    color = idx == 2.0 ? RGB( 0,   148, 0  ) : color;    
    color = idx == 3.0 ? RGB( 128, 208, 16 ) : color;
}

void SpriteShoreSide( inout vec3 color, float x, float y )
{
    float idx = 0.0;    
    
	idx = y == 19.0 ? 43.0 : idx;
	idx = y == 18.0 ? 190.0 : idx;
	idx = y == 17.0 ? 2025.0 : idx;
	idx = y == 16.0 ? 3773.0 : idx;
	idx = y == 15.0 ? 3050.0 : idx;
	idx = y == 14.0 ? 445.0 : idx;
	idx = y == 13.0 ? 2981.0 : idx;
	idx = y == 12.0 ? 765.0 : idx;
	idx = y == 11.0 ? 4005.0 : idx;
	idx = y == 10.0 ? 6869.0 : idx;
	idx = y == 9.0 ? 3669.0 : idx;
	idx = y == 8.0 ? 15189.0 : idx;
	idx = y == 7.0 ? 3029.0 : idx;
	idx = y == 6.0 ? 16037.0 : idx;
	idx = y == 5.0 ? 11221.0 : idx;
	idx = y == 4.0 ? 32341.0 : idx;
	idx = y == 3.0 ? 43989.0 : idx;
	idx = y == 2.0 ? 64853.0 : idx;
	idx = y == 1.0 ? 22869.0 : idx;
	idx = y == 0.0 ? 21850.0 : idx;
    
    idx = SPRITE_DEC_4( x, idx );
    
    float blink = fract( iTime * 3.0 );
    idx = blink > 0.5 && ( idx == 2.0 || idx == 3.0 ) ? 5.0 - idx : idx;
    
    color = y >= 0.0 && y < 20.0 ? RGB( 0, 0, 0 ) : color;
    color = idx == 1.0 ? RGB( 0,   112, 236 ) : color;
    color = idx == 2.0 ? RGB( 60,  188, 252 ) : color;
    color = idx == 3.0 ? RGB( 255, 255, 255 ) : color;
}

void SpriteShore( inout vec3 color, float x, float y )
{
    float idx = 0.0;    
    
    idx = y == 6.0 ? 0.0 : idx;
    idx = y == 5.0 ? ( x <= 7.0 ? 65024.0 : ( x <= 15.0 ? 2.0 : ( x <= 23.0 ? 760.0 : 188.0 ) ) ) : idx;
    idx = y == 4.0 ? ( x <= 7.0 ? 43904.0 : ( x <= 15.0 ? 60143.0 : ( x <= 23.0 ? 2990.0 : 3051.0 ) ) ) : idx;
    idx = y == 3.0 ? ( x <= 7.0 ? 24303.0 : ( x <= 15.0 ? 49061.0 : ( x <= 23.0 ? 48789.0 : 61095.0 ) ) ) : idx;
    idx = y == 2.0 ? ( x <= 7.0 ? 21926.0 : ( x <= 15.0 ? 21909.0 : ( x <= 23.0 ? 58709.0 : 42902.0 ) ) ) : idx;
    idx = y == 1.0 ? ( x <= 7.0 ? 38229.0 : ( x <= 15.0 ? 22869.0 : ( x <= 23.0 ? 21845.0 : 21925.0 ) ) ) : idx;
    idx = y == 0.0 ? ( x <= 7.0 ? 21865.0 : ( x <= 15.0 ? 22137.0 : 21845.0 ) ) : idx;
    
    idx = SPRITE_DEC_4( x, idx );
    
    float blink = fract( iTime * 3.0 );
    idx = blink > 0.5 && ( idx == 2.0 || idx == 3.0 ) ? 5.0 - idx : idx;
    
    color = RGB( 0, 0, 0 );
    color = idx == 1.0 ? RGB( 0,   112, 236 ) : color;
    color = idx == 2.0 ? RGB( 60,  188, 252 ) : color;
    color = idx == 3.0 ? RGB( 255, 255, 255 ) : color;
}

void SpriteBossCore( inout vec3 color, float x, float y )
{
    float idx = 0.0;
    
    idx = y == 30.0 ? ( x <= 7.0 ? 21844.0 : ( x <= 15.0 ? 85.0 : 0.0 ) ) : idx;
    idx = y == 29.0 ? ( x <= 7.0 ? 65533.0 : ( x <= 15.0 ? 21845.0 : 5461.0 ) ) : idx;
    idx = y == 28.0 ? ( x <= 7.0 ? 43689.0 : ( x <= 15.0 ? 65345.0 : 28671.0 ) ) : idx;
    idx = y == 27.0 ? ( x <= 7.0 ? 43689.0 : ( x <= 15.0 ? 43861.0 : 21930.0 ) ) : idx;
    idx = y == 26.0 ? ( x <= 7.0 ? 43685.0 : ( x <= 15.0 ? 43841.0 : 21610.0 ) ) : idx;
    idx = y == 25.0 ? ( x <= 7.0 ? 43665.0 : ( x <= 15.0 ? 43861.0 : 21850.0 ) ) : idx;
    idx = y == 24.0 ? ( x <= 7.0 ? 43605.0 : ( x <= 15.0 ? 43841.0 : 27462.0 ) ) : idx;
    idx = y == 23.0 ? ( x <= 7.0 ? 43293.0 : ( x <= 15.0 ? 43861.0 : 27605.0 ) ) : idx;
    idx = y == 22.0 ? ( x <= 7.0 ? 42361.0 : ( x <= 15.0 ? 27457.0 : 23476.0 ) ) : idx;
    idx = y == 21.0 ? ( x <= 7.0 ? 20969.0 : ( x <= 15.0 ? 23381.0 : 27565.0 ) ) : idx;
    idx = y == 20.0 ? ( x <= 7.0 ? 38825.0 : ( x <= 15.0 ? 17855.0 : 23467.0 ) ) : idx;
    idx = y == 19.0 ? ( x <= 7.0 ? 26281.0 : ( x <= 15.0 ? 55009.0 : 27562.0 ) ) : idx;
    idx = y == 18.0 ? ( x <= 7.0 ? 26276.0 : ( x <= 15.0 ? 38592.0 : 32746.0 ) ) : idx;
    idx = y == 17.0 ? ( x <= 7.0 ? 22928.0 : ( x <= 15.0 ? 39808.0 : 23162.0 ) ) : idx;
    idx = y == 16.0 ? ( x <= 7.0 ? 6544.0 : ( x <= 15.0 ? 39808.0 : 23390.0 ) ) : idx;
    idx = y == 15.0 ? ( x <= 7.0 ? 6544.0 : ( x <= 15.0 ? 39808.0 : 23390.0 ) ) : idx;
    idx = y == 14.0 ? ( x <= 7.0 ? 6544.0 : ( x <= 15.0 ? 39808.0 : 23390.0 ) ) : idx;
    idx = y == 13.0 ? ( x <= 7.0 ? 6564.0 : ( x <= 15.0 ? 39808.0 : 23390.0 ) ) : idx;
    idx = y == 12.0 ? ( x <= 7.0 ? 22953.0 : ( x <= 15.0 ? 39808.0 : 23162.0 ) ) : idx;
    idx = y == 11.0 ? ( x <= 7.0 ? 26281.0 : ( x <= 15.0 ? 38592.0 : 32746.0 ) ) : idx;
    idx = y == 10.0 ? ( x <= 7.0 ? 26281.0 : ( x <= 15.0 ? 38625.0 : 27562.0 ) ) : idx;
    idx = y == 9.0 ? ( x <= 7.0 ? 38569.0 : ( x <= 15.0 ? 17850.0 : 23466.0 ) ) : idx;
    idx = y == 8.0 ? ( x <= 7.0 ? 20905.0 : ( x <= 15.0 ? 24405.0 : 27561.0 ) ) : idx;
    idx = y == 7.0 ? ( x <= 7.0 ? 46441.0 : ( x <= 15.0 ? 27457.0 : 23460.0 ) ) : idx;
    idx = y == 6.0 ? ( x <= 7.0 ? 44313.0 : ( x <= 15.0 ? 43861.0 : 27541.0 ) ) : idx;
    idx = y == 5.0 ? ( x <= 7.0 ? 43861.0 : ( x <= 15.0 ? 43841.0 : 27462.0 ) ) : idx;
    idx = y == 4.0 ? ( x <= 7.0 ? 43729.0 : ( x <= 15.0 ? 43861.0 : 21850.0 ) ) : idx;
    idx = y == 3.0 ? ( x <= 7.0 ? 45045.0 : ( x <= 15.0 ? 43841.0 : 21610.0 ) ) : idx;
    idx = y == 2.0 ? ( x <= 7.0 ? 62804.0 : ( x <= 15.0 ? 65365.0 : 21930.0 ) ) : idx;
    idx = y == 1.0 ? ( x <= 7.0 ? 21504.0 : ( x <= 15.0 ? 21845.0 : 27391.0 ) ) : idx;
    idx = y == 0.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 20480.0 : 5461.0 ) ) : idx;
    
    idx = SPRITE_DEC_4( x, idx );
    idx = x >= 0.0 && x < 24.0 ? idx : 0.0;

    float blink = abs( sin( iTime * 3.0 ) ) + 0.5;
    color = idx == 1.0 ? RGB( 0,   0,   0   ) : color;
    color = idx == 2.0 ? RGB( 192, 192, 192 ) : color;
    color = idx == 3.0 ? RGB( 255, 255, 255 ) : color;
    color = idx == 0.0 && x >= 1.0 && x < 21.0 && y >= 3.0 && y < 30.0 ? blink * RGB( 228, 68, 52 ) : color;
}

void SpriteBossCannonBase( inout vec3 color, float x, float y )
{
	float idx = 0.0;
    
	idx = y == 41.0 ? ( x <= 7.0 ? 11606.0 : ( x <= 15.0 ? 395.0 : ( x <= 23.0 ? 43584.0 : 21946.0 ) ) ) : idx;
	idx = y == 40.0 ? ( x <= 7.0 ? 11611.0 : ( x <= 15.0 ? 32774.0 : ( x <= 23.0 ? 43595.0 : 22250.0 ) ) ) : idx;
	idx = y == 39.0 ? ( x <= 7.0 ? 6491.0 : ( x <= 15.0 ? 11520.0 : ( x <= 23.0 ? 43298.0 : 22250.0 ) ) ) : idx;
	idx = y == 38.0 ? ( x <= 7.0 ? 366.0 : ( x <= 15.0 ? 35042.0 : ( x <= 23.0 ? 43275.0 : 23466.0 ) ) ) : idx;
	idx = y == 37.0 ? ( x <= 7.0 ? 5486.0 : ( x <= 15.0 ? 11532.0 : ( x <= 23.0 ? 42082.0 : 43946.0 ) ) ) : idx;
	idx = y == 36.0 ? ( x <= 7.0 ? 5562.0 : ( x <= 15.0 ? 35042.0 : ( x <= 23.0 ? 41995.0 : 21850.0 ) ) ) : idx;
	idx = y == 35.0 ? ( x <= 7.0 ? 5866.0 : ( x <= 15.0 ? 11532.0 : ( x <= 23.0 ? 20578.0 : 5.0 ) ) ) : idx;
	idx = y == 34.0 ? ( x <= 7.0 ? 5866.0 : ( x <= 15.0 ? 35042.0 : ( x <= 23.0 ? 11.0 : 27744.0 ) ) ) : idx;
	idx = y == 33.0 ? ( x <= 7.0 ? 11178.0 : ( x <= 15.0 ? 11532.0 : ( x <= 23.0 ? 24674.0 : 27756.0 ) ) ) : idx;
	idx = y == 32.0 ? ( x <= 7.0 ? 5466.0 : ( x <= 15.0 ? 35042.0 : ( x <= 23.0 ? 24587.0 : 27756.0 ) ) ) : idx;
	idx = y == 31.0 ? ( x <= 7.0 ? 21.0 : ( x <= 15.0 ? 11532.0 : ( x <= 23.0 ? 24674.0 : 27756.0 ) ) ) : idx;
	idx = y == 30.0 ? ( x <= 7.0 ? 11264.0 : ( x <= 15.0 ? 35042.0 : ( x <= 23.0 ? 24587.0 : 27756.0 ) ) ) : idx;
	idx = y == 29.0 ? ( x <= 7.0 ? 11372.0 : ( x <= 15.0 ? 11532.0 : ( x <= 23.0 ? 24674.0 : 27756.0 ) ) ) : idx;
	idx = y == 28.0 ? ( x <= 7.0 ? 11372.0 : ( x <= 15.0 ? 35042.0 : ( x <= 23.0 ? 24587.0 : 27756.0 ) ) ) : idx;
	idx = y == 27.0 ? ( x <= 7.0 ? 11372.0 : ( x <= 15.0 ? 11532.0 : ( x <= 23.0 ? 24674.0 : 21612.0 ) ) ) : idx;
	idx = y == 26.0 ? ( x <= 7.0 ? 11372.0 : ( x <= 15.0 ? 35042.0 : ( x <= 23.0 ? 20491.0 : 84.0 ) ) ) : idx;
	idx = y == 25.0 ? ( x <= 7.0 ? 11372.0 : ( x <= 15.0 ? 11532.0 : ( x <= 23.0 ? 98.0 : 27648.0 ) ) ) : idx;
	idx = y == 24.0 ? ( x <= 7.0 ? 5228.0 : ( x <= 15.0 ? 35042.0 : ( x <= 23.0 ? 24587.0 : 27756.0 ) ) ) : idx;
	idx = y == 23.0 ? ( x <= 7.0 ? 84.0 : ( x <= 15.0 ? 11532.0 : ( x <= 23.0 ? 24674.0 : 27756.0 ) ) ) : idx;
	idx = y == 22.0 ? ( x <= 7.0 ? 11264.0 : ( x <= 15.0 ? 35042.0 : ( x <= 23.0 ? 24587.0 : 27756.0 ) ) ) : idx;
	idx = y == 21.0 ? ( x <= 7.0 ? 11372.0 : ( x <= 15.0 ? 11532.0 : ( x <= 23.0 ? 24674.0 : 27756.0 ) ) ) : idx;
	idx = y == 20.0 ? ( x <= 7.0 ? 11372.0 : ( x <= 15.0 ? 35042.0 : ( x <= 23.0 ? 24587.0 : 27756.0 ) ) ) : idx;
	idx = y == 19.0 ? ( x <= 7.0 ? 11372.0 : ( x <= 15.0 ? 11532.0 : ( x <= 23.0 ? 24674.0 : 21612.0 ) ) ) : idx;
	idx = y == 18.0 ? ( x <= 7.0 ? 11372.0 : ( x <= 15.0 ? 35042.0 : ( x <= 23.0 ? 20491.0 : 84.0 ) ) ) : idx;
	idx = y == 17.0 ? ( x <= 7.0 ? 11372.0 : ( x <= 15.0 ? 11532.0 : ( x <= 23.0 ? 98.0 : 27648.0 ) ) ) : idx;
	idx = y == 16.0 ? ( x <= 7.0 ? 5228.0 : ( x <= 15.0 ? 35042.0 : ( x <= 23.0 ? 24587.0 : 27756.0 ) ) ) : idx;
	idx = y == 15.0 ? ( x <= 7.0 ? 11348.0 : ( x <= 15.0 ? 11532.0 : ( x <= 23.0 ? 24674.0 : 27756.0 ) ) ) : idx;
	idx = y == 14.0 ? ( x <= 7.0 ? 11264.0 : ( x <= 15.0 ? 35042.0 : ( x <= 23.0 ? 24587.0 : 11372.0 ) ) ) : idx;
	idx = y == 13.0 ? ( x <= 7.0 ? 11372.0 : ( x <= 15.0 ? 11532.0 : ( x <= 23.0 ? 24674.0 : 35948.0 ) ) ) : idx;
	idx = y == 12.0 ? ( x <= 7.0 ? 11372.0 : ( x <= 15.0 ? 35042.0 : ( x <= 23.0 ? 24587.0 : 34924.0 ) ) ) : idx;
	idx = y == 11.0 ? ( x <= 7.0 ? 11372.0 : ( x <= 15.0 ? 11532.0 : ( x <= 23.0 ? 24674.0 : 57452.0 ) ) ) : idx;
	idx = y == 10.0 ? ( x <= 7.0 ? 11372.0 : ( x <= 15.0 ? 35042.0 : ( x <= 23.0 ? 20491.0 : 57428.0 ) ) ) : idx;
	idx = y == 9.0 ? ( x <= 7.0 ? 5228.0 : ( x <= 15.0 ? 11532.0 : ( x <= 23.0 ? 98.0 : 47104.0 ) ) ) : idx;
	idx = y == 8.0 ? ( x <= 7.0 ? 108.0 : ( x <= 15.0 ? 35042.0 : ( x <= 23.0 ? 4107.0 : 47125.0 ) ) ) : idx;
	idx = y == 7.0 ? ( x <= 7.0 ? 84.0 : ( x <= 15.0 ? 11532.0 : ( x <= 23.0 ? 98.0 : 44544.0 ) ) ) : idx;
	idx = y == 6.0 ? ( x <= 7.0 ? 16128.0 : ( x <= 15.0 ? 0.0 : ( x <= 23.0 ? 0.0 : 45044.0 ) ) ) : idx;
	idx = y == 5.0 ? ( x <= 7.0 ? 10752.0 : ( x <= 15.0 ? 43689.0 : ( x <= 23.0 ? 5467.0 : 47780.0 ) ) ) : idx;
	idx = y == 4.0 ? ( x <= 7.0 ? 0.0 : ( x <= 15.0 ? 43689.0 : ( x <= 23.0 ? 5467.0 : 0.0 ) ) ) : idx;
	idx = y == 3.0 ? ( x <= 7.0 ? 10896.0 : ( x <= 15.0 ? 43689.0 : ( x <= 23.0 ? 5467.0 : 64169.0 ) ) ) : idx;
	idx = y == 2.0 ? ( x <= 7.0 ? 10916.0 : ( x <= 15.0 ? 43689.0 : ( x <= 23.0 ? 17755.0 : 44714.0 ) ) ) : idx;
	idx = y == 1.0 ? ( x <= 7.0 ? 15017.0 : ( x <= 15.0 ? 43689.0 : ( x <= 23.0 ? 37211.0 : 43946.0 ) ) ) : idx;
	idx = y == 0.0 ? ( x <= 7.0 ? 15017.0 : ( x <= 15.0 ? 43689.0 : ( x <= 23.0 ? 37211.0 : 43946.0 ) ) ) : idx;

    idx = SPRITE_DEC_4( x, idx );
    idx = x >= 0.0 && x < 32.0 ? idx : 0.0;    
    
    color = idx == 0.0 && x >= 0.0 && x < 32.0 && y >= 0.0 && y < 42.0 ? RGB( 0, 0, 0 ) : color;
    color = idx == 1.0 ? RGB( 4,   88,  180 ) : color;
    color = idx == 2.0 ? RGB( 192, 192, 192 ) : color;
    color = idx == 3.0 ? RGB( 255, 255, 255 ) : color;    
}

void SpriteBossTopPanel( inout vec3 color, float x, float y )
{
	float idx = 0.0;    

	idx = y == 51.0 ? ( x <= 7.0 ? 16384.0 : 10922.0 ) : idx;
	idx = y == 50.0 ? ( x <= 7.0 ? 62464.0 : 9558.0 ) : idx;
	idx = y == 49.0 ? ( x <= 7.0 ? 61248.0 : 9558.0 ) : idx;
	idx = y == 48.0 ? ( x <= 7.0 ? 60148.0 : 9558.0 ) : idx;
	idx = y == 47.0 ? ( x <= 7.0 ? 60078.0 : 9558.0 ) : idx;
	idx = y == 46.0 ? ( x <= 7.0 ? 58793.0 : 9558.0 ) : idx;
	idx = y == 45.0 ? ( x <= 7.0 ? 57433.0 : 9558.0 ) : idx;
	idx = y == 44.0 ? ( x <= 7.0 ? 57353.0 : 9558.0 ) : idx;
	idx = y == 43.0 ? ( x <= 7.0 ? 61193.0 : 9558.0 ) : idx;
	idx = y == 42.0 ? ( x <= 7.0 ? 60153.0 : 9558.0 ) : idx;
	idx = y == 41.0 ? ( x <= 7.0 ? 58761.0 : 9558.0 ) : idx;
	idx = y == 40.0 ? ( x <= 7.0 ? 57609.0 : 9558.0 ) : idx;
	idx = y == 39.0 ? ( x <= 7.0 ? 61193.0 : 9558.0 ) : idx;
	idx = y == 38.0 ? ( x <= 7.0 ? 60153.0 : 9558.0 ) : idx;
	idx = y == 37.0 ? ( x <= 7.0 ? 58761.0 : 9558.0 ) : idx;
	idx = y == 36.0 ? ( x <= 7.0 ? 57609.0 : 9558.0 ) : idx;
	idx = y == 35.0 ? ( x <= 7.0 ? 61193.0 : 9558.0 ) : idx;
	idx = y == 34.0 ? ( x <= 7.0 ? 60153.0 : 9558.0 ) : idx;
	idx = y == 33.0 ? ( x <= 7.0 ? 58761.0 : 9558.0 ) : idx;
	idx = y == 32.0 ? ( x <= 7.0 ? 57609.0 : 9558.0 ) : idx;
	idx = y == 31.0 ? ( x <= 7.0 ? 61193.0 : 9558.0 ) : idx;
	idx = y == 30.0 ? ( x <= 7.0 ? 60153.0 : 9558.0 ) : idx;
	idx = y == 29.0 ? ( x <= 7.0 ? 58761.0 : 9558.0 ) : idx;
	idx = y == 28.0 ? ( x <= 7.0 ? 57609.0 : 9558.0 ) : idx;
	idx = y == 27.0 ? ( x <= 7.0 ? 61193.0 : 9558.0 ) : idx;
	idx = y == 26.0 ? ( x <= 7.0 ? 60153.0 : 9558.0 ) : idx;
	idx = y == 25.0 ? ( x <= 7.0 ? 58761.0 : 9558.0 ) : idx;
	idx = y == 24.0 ? ( x <= 7.0 ? 57609.0 : 9558.0 ) : idx;
	idx = y == 23.0 ? ( x <= 7.0 ? 61193.0 : 10582.0 ) : idx;
	idx = y == 22.0 ? ( x <= 7.0 ? 60153.0 : 11606.0 ) : idx;
	idx = y == 21.0 ? ( x <= 7.0 ? 58761.0 : 11606.0 ) : idx;
	idx = y == 20.0 ? ( x <= 7.0 ? 57609.0 : 11606.0 ) : idx;
	idx = y == 19.0 ? ( x <= 7.0 ? 61193.0 : 11606.0 ) : idx;
	idx = y == 18.0 ? ( x <= 7.0 ? 60153.0 : 11606.0 ) : idx;
	idx = y == 17.0 ? ( x <= 7.0 ? 58761.0 : 11606.0 ) : idx;
	idx = y == 16.0 ? ( x <= 7.0 ? 57609.0 : 11606.0 ) : idx;
	idx = y == 15.0 ? ( x <= 7.0 ? 61193.0 : 11606.0 ) : idx;
	idx = y == 14.0 ? ( x <= 7.0 ? 60153.0 : 11606.0 ) : idx;
	idx = y == 13.0 ? ( x <= 7.0 ? 58761.0 : 11606.0 ) : idx;
	idx = y == 12.0 ? ( x <= 7.0 ? 57609.0 : 11606.0 ) : idx;
	idx = y == 11.0 ? ( x <= 7.0 ? 59913.0 : 11606.0 ) : idx;
	idx = y == 10.0 ? ( x <= 7.0 ? 60073.0 : 11606.0 ) : idx;
	idx = y == 9.0 ? ( x <= 7.0 ? 65449.0 : 11611.0 ) : idx;
	idx = y == 8.0 ? ( x <= 7.0 ? 60158.0 : 6491.0 ) : idx;
	idx = y == 7.0 ? ( x <= 7.0 ? 43684.0 : 366.0 ) : idx;
	idx = y == 6.0 ? ( x <= 7.0 ? 43684.0 : 5486.0 ) : idx;
	idx = y == 5.0 ? ( x <= 7.0 ? 43664.0 : 5562.0 ) : idx;
	idx = y == 4.0 ? ( x <= 7.0 ? 43664.0 : 5866.0 ) : idx;
	idx = y == 3.0 ? ( x <= 7.0 ? 43584.0 : 5866.0 ) : idx;
	idx = y == 2.0 ? ( x <= 7.0 ? 43264.0 : 11178.0 ) : idx;
	idx = y == 1.0 ? ( x <= 7.0 ? 43264.0 : 5466.0 ) : idx;
	idx = y == 0.0 ? ( x <= 7.0 ? 21504.0 : 21.0 ) : idx;
    
    idx = SPRITE_DEC_4( x, idx );
    idx = x >= 0.0 && x < 15.0 ? idx : 0.0;    
    
    color = idx == 0.0 && x >= 0.0 && x < 15.0 && y >= 8.0 && y < 48.0 ? RGB( 0, 0, 0 ) : color;
    color = idx == 1.0 ? RGB( 4,   88,  180 ) : color;
    color = idx == 2.0 ? RGB( 192, 192, 192 ) : color;
    color = idx == 3.0 ? RGB( 255, 255, 255 ) : color;        
}

void SpriteBossCannon0( inout vec3 color, float x, float y )
{
    float idx = 0.0;
    
	idx = y == 5.0 ? ( x <= 7.0 ? 39340.0 : 1706.0 ) : idx;
	idx = y == 4.0 ? ( x <= 7.0 ? 30663.0 : 2044.0 ) : idx;
	idx = y == 3.0 ? ( x <= 7.0 ? 17415.0 : 1024.0 ) : idx;
	idx = y == 2.0 ? ( x <= 7.0 ? 30663.0 : 2044.0 ) : idx;
	idx = y == 1.0 ? ( x <= 7.0 ? 26615.0 : 2047.0 ) : idx;
	idx = y == 0.0 ? ( x <= 7.0 ? 39340.0 : 682.0 ) : idx;

    idx = SPRITE_DEC_4( x, idx );
    idx = x >= 0.0 && x < 14.0 ? idx : 0.0;

    color = idx == 0.0 && x >= 1.0 && x < 11.0 && y >= 0.0 && y < 6.0 ? RGB( 255, 255, 255 ) : color;    
    color = idx == 1.0 ? RGB( 0,   0,   0 )   : color;
    color = idx == 2.0 ? RGB( 4,   88,  180 ) : color;
    color = idx == 3.0 ? RGB( 192, 192, 192 ) : color;
}

void SpriteBossCannon1( inout vec3 color, float x, float y )
{
    float idx = 0.0;
    
	idx = y == 5.0 ? ( x <= 7.0 ? 39340.0 : 1706.0 ) : idx;
	idx = y == 4.0 ? ( x <= 7.0 ? 30663.0 : 2044.0 ) : idx;
	idx = y == 3.0 ? ( x <= 7.0 ? 17415.0 : 256.0 ) : idx;
	idx = y == 2.0 ? ( x <= 7.0 ? 30663.0 : 508.0 ) : idx;
	idx = y == 1.0 ? ( x <= 7.0 ? 26615.0 : 127.0 ) : idx;
	idx = y == 0.0 ? ( x <= 7.0 ? 39340.0 : 106.0 ) : idx;

    idx = SPRITE_DEC_4( x, idx );
    idx = x >= 0.0 && x < 14.0 ? idx : 0.0;

    color = idx == 0.0 && x >= 1.0 && x < 12.0 && y >= 0.0 && y < 6.0 ? RGB( 255, 255, 255 ) : color;    
    color = idx == 1.0 ? RGB( 0,   0,   0 )   : color;
    color = idx == 2.0 ? RGB( 4,   88,  180 ) : color;
    color = idx == 3.0 ? RGB( 192, 192, 192 ) : color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float resMultX      = floor( iResolution.x / NES_RES_X );
    float resMultY      = floor( iResolution.y / NES_RES_Y );
    float resRcp        = 1.0 / max( min( resMultX, resMultY ), 1.0 );
    float screenWidth   = floor( iResolution.x * resRcp );
    float screenHeight  = floor( iResolution.y * resRcp );
    float pixelX        = floor( fragCoord.x * resRcp );
    float pixelY        = floor( fragCoord.y * resRcp );
    
    vec4 camera         = LoadValue( txCamera );
    vec4 bridge         = LoadValue( txBridge );
    vec4 bossCore       = LoadValue( txBossCore );
    vec4 bossCannon0    = LoadValue( txBossCannon0 );
    vec4 bossCannon1    = LoadValue( txBossCannon1 );
    
    float worldX        = pixelX + camera.x;
    float worldY        = pixelY - 8.0;
    float tileX         = floor( worldX / 32.0 );
    float tile8X        = floor( worldX / 8.0 );
    float tile32Y       = floor( worldY / 32.0 );
    float tile16Y       = floor( worldY / 16.0 );
    float tile8Y        = floor( worldY / 8.0 );
    float worldXMod16   = mod( worldX, 16.0 );
    float worldYMod16   = mod( worldY, 16.0 );    
    float worldYMod8    = mod( worldY,  8.0 );
    float worldXMod32   = mod( worldX, 32.0 );
    float worldYMod32   = mod( worldY, 32.0 );
    

    vec3 color = RGB( 0, 0, 0 );
    
    // stars
    float starRand = Rand( vec2( worldX * 0.01, worldY * 0.01 ) );
    if ( starRand > 0.998 && worldY > 160.0 )
    {
        color = fract( iTime + starRand * 113.17 + worldX * 3.14 ) < 0.5 ? RGB( 255, 255, 255 ) : RGB( 0, 112, 236 );
    }
    
    // background water
    if ( worldY < 80.0 && worldX < WATER_END )
    {
        color = RGB( 0, 112, 236 );
    }
   
    if ( worldX >= JUNGLE_START + 3.0 && worldX < JUNGLE_END )
    {
        SpriteTreeTrunk( color, mod( worldX - 3.0, 16.0 ), mod( worldY, 2.0 ) );    
        
    }

    if ( worldX >= JUNGLE_START + 3.0 && worldX < JUNGLE_END && floor( ( worldY + 5.0 ) / 32.0 ) == 6.0 )
    {
        SpriteLeaves( color, mod( worldX - 3.0, 32.0 ), mod( worldY + 5.0, 32.0 ) );
    }
    
    bool grass0 = false;
    bool grass2 = false;
    bool grass3 = false;
    bool grass4 = false;
    bool grass6 = false;
    bool grass8 = false;
    
    if (        ( tileX >= 52.0 && tileX < 67.0 ) 
            ||  ( tileX >= 72.0 && tileX < 77.0 )   
            ||  ( tileX >= 86.0 && tileX < 88.0 ) )
    {
        grass8 = true;
    }
    
    if (        ( tileX >= 3.0   && tileX < 30.0 ) 
            ||  ( tileX >= 35.0  && tileX < 40.0 ) 
            ||  ( tileX >= 45.0  && tileX < 53.0 ) 
            ||  ( tileX >= 66.0  && tileX < 73.0 )
            ||  ( tileX >= 78.0  && tileX < 80.0 )
            ||  ( tileX >= 85.0  && tileX < 87.0 )
            ||  ( tileX >= 89.0  && tileX < 91.0 )
            ||  ( tileX >= 102.0 && tileX < 106.0 ) )
    {
        grass6 = true;
    }
    
    if (        ( tileX >= 10.0 && tileX < 13.0 )
            ||  ( tileX >= 18.0 && tileX < 20.0 )
            ||  ( tileX >= 58.0 && tileX < 65.0 )
            ||  ( tileX >= 76.0 && tileX < 79.0 )
            ||  ( tileX >= 81.0 && tileX < 83.0 )
            ||  ( tileX >= 90.0 && tileX < 95.0 )
            ||  ( tileX >= 100.0 && tileX < 102.0 )
            ||  ( tileX == 106.0 ) )
    {
        grass4 = true;
    }
    
    if (        ( tileX >= 26.0 && tileX < 29.0 )
            ||  ( tileX >= 55.0 && tileX < 57.0 )
            ||  ( tileX == 74.0 )
            ||  ( tileX == 87.0 )
            ||  ( tileX >= 103.0 && tileX < 106.0 ) )
    {
        grass3 = true;
    }
        
    if (        ( tileX == 13.0 || tileX == 16.0 )
            ||  ( tileX >= 68.0 && tileX < 70.0 )
            ||  ( tileX >= 71.0 && tileX < 73.0 )
            ||  ( tileX >= 82.0 && tileX < 85.0 )
            ||  ( tileX >= 97.0 && tileX < 99.0 )
            ||  ( tileX == 107.0 ) )
    {
        grass2 = true;
    }
        
    if (        ( tileX >= 14.0 && tileX < 16.0 ) 
            ||  ( tileX >= 24.0 && tileX < 26.0 ) 
            ||  ( tileX >= 52.0 && tileX < 55.0 ) 
            ||  ( tileX >= 62.0 && tileX < 68.0 )
            ||  ( tileX == 81.0 )
            ||  ( tileX == 86.0 )
            ||  ( tileX >= 93.0 && tileX < 96.0 )
            ||  ( tileX >= 102.0 ) )      
    {
        grass0 = true;
    }
    
    float rockTile32Y = -1.0;
    if ( grass2 )
    {
        rockTile32Y = 1.0;
    }       
    if ( grass4 )
    {
        rockTile32Y = 2.0;
    }        
    if ( grass6 )
    {
        rockTile32Y = 3.0;
    }
    if ( grass8 )
    {
        rockTile32Y = 4.0;
    }    
    
    if ( tile32Y < rockTile32Y )
    {
        SpriteRock( color, worldXMod32, mod( worldY + 8.0, 32.0 ) );    
    }
    
    if (        ( tile8Y == -1.0 && grass0 ) 
            ||  ( tile8Y == 3.0 && grass2 )
            ||  ( tile8Y == 5.0 && grass3 )
            ||  ( tile8Y == 7.0 && grass4 )
            ||  ( tile8Y == 11.0 && grass6 )
            ||  ( tile8Y == 15.0 && grass8 ) )
    {
        SpriteRockTop( color, worldXMod32, worldYMod8 );
    }    
    
    // foreground water
    if ( ( worldY < 16.0 && worldX < WATER_END ) 
        || ( tile16Y < 2.0 && (
                    ( tileX < 10.0 ) 
                ||  ( tileX == 17.0 )
                ||  ( tileX >= 20.0 && tileX < 23.0 )
                ||  ( tileX >= 33.0 && tileX < 47.0 )
                ||  ( tileX == 57.0 ) 
           ) )
       )
    {
        color = RGB( 0, 112, 236 );
    }    
    
    if (    ( floor( ( worldY - 1.0 ) / 8.0 ) == 3.0 && ( ( tileX >= 3.0 && tileX < 10.0 ) || ( tileX == 17.0 ) || ( tileX >= 20.0 && tileX < 23.0 ) || ( tileX >= 35.0 && tileX < 40.0 ) || ( tileX >= 45.0 && tileX < 47.0 ) || ( tileX == 57.0 ) ) )
         || ( floor( ( worldY - 1.0 ) / 8.0 ) == 1.0 && ( ( tileX >= 10.0 && tileX < 17.0 ) || ( tileX >= 18.0 && tileX < 20.0 ) || ( tileX >= 23.0 && tileX < 30.0 ) || ( tileX >= 47.0 && tileX < 57.0 ) || ( tileX >= 58.0 && tileX < 63.0 ) ) )
         || ( floor( ( worldY - 1.0 ) / 8.0 ) == -1.0 && ( ( tileX >= 14.0 && tileX < 16.0 ) || ( tileX >= 24.0 && tileX < 26.0 ) || ( tileX >= 52.0 && tileX < 55.0 ) || ( tileX == 62.0 ) ) )
       )
    {
        SpriteShore( color, mod( worldX, 32.0 ), mod( worldY - 1.0, 8.0 ) );  
    }    
    
    if ( floor( ( worldY ) / 24.0 ) == 1.0 && ( tile8X == 11.0 || tile8X == 139.0 || tile8X == 160.0 || tile8X == 179.0 ) )
    {
        float shoreX = ( tile8X == 160.0 ) ? 7.0 - worldX : worldX;
        SpriteShoreSide( color, mod( shoreX, 8.0 ), mod( worldY, 24.0 ) );
    }        
    
	if ( floor( ( worldY + 14.0 ) / 24.0 ) == 1.0 && ( tile8X == 39.0 || tile8X == 68.0 || tile8X == 72.0 || tile8X == 80.0 || tile8X == 91.0 || tile8X == 120.0 || tile8X == 187.0 || tile8X == 228.0 || tile8X == 231.0 ) )
    {
        float shoreX = ( tile8X == 68.0 || tile8X == 80.0 || tile8X == 120.0 || tile8X == 228.0 ) ? 7.0 - worldX : worldX;
        SpriteShoreSide( color, mod( shoreX, 8.0 ), mod( worldY + 14.0, 24.0 ) );
    }    
    
    if ( floor( ( worldY + 6.0 ) / 24.0 ) == 0.0 && ( tile8X == 55.0 || tile8X == 64.0 || tile8X == 95.0 || tile8X == 104.0 || tile8X == 207.0 || tile8X == 220.0 || tile8X == 247.0 ) )
    {
        float shoreX = ( tile8X == 64.0 || tile8X == 104.0 || tile8X == 220.0 ) ? 7.0 - worldX : worldX;
    	SpriteShoreSide( color, mod( shoreX, 8.0 ), mod( worldY + 6.0, 24.0 ) );
    }
    
    if (        ( tile16Y == 0.0 && grass0 ) 
            ||  ( tile16Y == 2.0 && grass2 )
            ||  ( tile16Y == 3.0 && grass3 )
            ||  ( tile16Y == 4.0 && grass4 )
            ||  ( tile16Y == 6.0 && grass6 )
            ||  ( tile16Y == 8.0 && grass8 ) )
    {
        SpriteGrass( color, worldXMod32, worldYMod16 );
    }
    
    if (        ( grass8 && tile16Y == 9.0 )
            ||  ( !grass8 && grass6 && tile16Y == 7.0 )
            ||  ( !grass8 && !grass6 && grass4 && tile16Y == 5.0 )
            ||  ( !grass8 && !grass6 && !grass4 && grass2 && tile16Y == 3.0 )
            ||  ( !grass8 && !grass6 && !grass4 && !grass2 && grass0 && tile16Y == 1.0 ) )
    {
        SpriteBush( color, worldXMod32, worldYMod16 );
    }
    
    if ( floor( ( worldY - 1.0 ) / 24.0 ) == 5.0 && ( 
                ( tileX >= 3.0 && tileX < 30.0 ) 
            ||  ( tileX >= 35.0 && tileX < 40.0 )
            ||  ( tileX >= 45.0 && tileX < 52.0 )) )
    {
		SpriteTreeMiddle( color, mod( worldX + 8.0, 16.0 ), mod( worldY - 1.0, 24.0 ) );
    }
    
    if ( floor( ( worldY - 1.0 ) / 24.0 ) == 5.0 && 
        ( ( tile8X == 12.0 || tile8X == 34.0 || tile8X == 140.0 || tile8X == 180.0 )
        || ( mod( tile8X, 16.0 ) == 0.0 ) && tile8X < 119.0 ) )
    {
    	SpriteTreeStart( color, mod( worldX, 8.0 ), mod( worldY - 1.0, 24.0 ) );
    }
    
    if ( floor( ( worldY - 1.0 ) / 24.0 ) == 5.0 && 
        ( ( tile8X == 119.0 || tile8X == 159.0 || tile8X == 207.0 )
        || ( mod( tile8X + 1.0, 16.0 ) == 0.0 ) && tile8X < 119.0 ) )
    {
    	SpriteTreeEnd( color, mod( worldX, 8.0 ), mod( worldY - 1.0, 24.0 ) );
    }    
    
    if ( floor( ( worldY + 12.0 ) / 32.0 ) == 3.0 && bridge.x < tileX && (
            ( tileX >= BRIDGE_0_START_TILE && tileX < BRIDGE_0_END_TILE )
        ||  ( tileX >= BRIDGE_1_START_TILE && tileX < BRIDGE_1_END_TILE )
       ) )
    {
        SpriteBridge( color, worldXMod32, mod( worldY + 12.0, 32.0 ) );
    }  
    
    // boss back
    if ( worldX > 3506.0 && worldY < 168.0 )
    {
        float idx = 2.0;
                
        // horizontal bars
        idx = mod( worldX, 16.0 ) == 0.0 && mod( worldY + 8.0, 88.0 ) < 76.0 ? 3.0 : idx;
        idx = mod( worldX + 8.0, 16.0 ) == 0.0 && mod( worldY + 8.0, 88.0 ) < 76.0 ? 1.0 : idx;
        idx = mod( worldX, 16.0 ) > 8.0 && mod( worldY + 8.0, 88.0 ) == 76.0 ? 1.0 : idx;
        
        // vertical bars
        idx = mod( worldY + 8.0, 88.0 ) == 0.0 ? 1.0 : idx;
        idx = mod( worldY + 9.0, 88.0 ) == 0.0 ? 3.0 : idx;
        idx = mod( worldY + 10.0, 88.0 ) == 0.0 ? 4.0 : idx;
        idx = mod( worldY + 11.0, 88.0 ) == 0.0 ? 3.0 : idx;
        idx = mod( worldY + 12.0, 88.0 ) == 0.0 ? 3.0 : idx;
        idx = mod( worldY + 13.0, 88.0 ) == 0.0 ? 1.0 : idx;
        idx = worldX == 3506.0 + 1.0 ? 3.0 : idx;
        idx = worldX == 3506.0 + 2.0 ? 4.0 : idx;
        
        color = idx == 1.0 ? RGB( 0,   0,   0   ) : color;
        color = idx == 2.0 ? RGB( 4,   88,  180 ) : color;
        color = idx == 3.0 ? RGB( 192, 192, 192 ) : color;
        color = idx == 4.0 ? RGB( 255, 255, 255 ) : color;
    }
    
    // boss front
    if ( worldX >= 3476.0 && worldX <= 3506.0 && worldY >= 16.0 && worldY <= 152.0 + floor( 0.5 * ( worldX - 3476.0 ) ) )
    {
        float idx = 3.0;
        
        // vertical bars
        idx = mod( worldX, 4.0 ) == 0.0       ? 1.0 : idx;
        idx = mod( worldX - 1.0, 8.0 ) == 0.0 ? 4.0 : idx;
        idx = mod( worldX - 3.0, 8.0 ) == 0.0 ? 2.0 : idx;
        
        // top
        idx = worldY == 152.0 + floor( 0.5 * ( worldX - 3476.0 ) ) ? 2.0 : idx;
        
        // middle
        idx = worldY == 83.0 && worldX < 3504.0 ? 1.0 : idx;
        idx = worldY == 82.0 && worldX >= 3477.0 && worldX < 3504.0 ? 3.0 : idx;
        idx = worldY == 81.0 && worldX >= 3477.0 && worldX < 3504.0 ? 3.0 : idx;
        idx = worldY == 81.0 && mod( worldX + 4.0, 8.0 ) > 4.0 && worldX < 3504.0 ? 1.0 : idx;
        
        // bottom
        idx = worldY < 20.0 - floor( 0.2 * ( worldX - 3476.0 ) ) ? 1.0 : idx;
        idx = worldY == 20.0 - floor( 0.2 * ( worldX - 3476.0 ) ) ? 2.0 : idx;
        
        
        color = idx == 1.0 ? RGB( 0,   0,   0   ) : color;
        color = idx == 2.0 ? RGB( 4,   88,  180 ) : color;
        color = idx == 3.0 ? RGB( 192, 192, 192 ) : color;
        color = idx == 4.0 ? RGB( 255, 255, 255 ) : color;        
    }
    
    SpriteBossCore( color, worldX - bossCore.x + BOSS_CORE_SIZE.x * 0.5, worldY - bossCore.y );
    SpriteBossCannonBase( color, worldX - 3477.0, worldY - 84.0 );
    SpriteBossTopPanel( color, worldX - 3469.0, worldY - 116.0 );
    SpriteBossTopPanel( color, worldX - 3493.0, worldY - 120.0 );
    SpriteBossCannon0( color, worldX - bossCannon0.x + BOSS_CANNON_SIZE.x * 0.5, worldY - bossCannon0.y );
    SpriteBossCannon1( color, worldX - bossCannon1.x + BOSS_CANNON_SIZE.x * 0.5, worldY - bossCannon1.y );
    
    fragColor = vec4( color, 1.0 );
}