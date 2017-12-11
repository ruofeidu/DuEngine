
// Gameplay

// debug cheats
//#define KONAMI_CODE
//#define SPEED_RUN
//#define GOD_MODE

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

#ifdef KONAMI_CODE
	const float PLAYER_LIFE_NUM		= 10.0;
#else
	const float PLAYER_LIFE_NUM		= 3.0;
#endif

#ifdef SPEED_RUN
	const float PLAYER_RUN_SPEED 	= 5.0;
#else
	const float PLAYER_RUN_SPEED 	= 1.0;
#endif

const float MATH_PI 				= 3.14159265359;
const float NES_RES_X				= 224.0;
const float NES_RES_Y 				= 192.0;
const float KEY_A    				= 65.5 / 256.0;
const float KEY_Q    				= 81.5 / 256.0;
const float KEY_S    				= 83.5 / 256.0;
const float KEY_W    				= 87.5 / 256.0;
const float KEY_LEFT  				= 37.5 / 256.0;
const float KEY_UP    				= 38.5 / 256.0;
const float KEY_RIGHT 				= 39.5 / 256.0;
const float KEY_DOWN  				= 40.5 / 256.0;
const float STATE_RUN				= 0.0;
const float STATE_PRONE 			= 1.0;
const float STATE_JUMP 				= 2.0;
const float STATE_FALL 				= 3.0;
const float STATE_WATER 			= 4.0;
const float STATE_UNDER_WATER 		= 5.0;
const float WEAPON_RIFLE			= 0.0;
const float WEAPON_MACHINE_GUN		= 1.0;
const float RIFLE_FIRE_RATE			= 20.0;
const float RIFLE_BULLET_NUM		= 4.0;
const float MACHINE_GUN_FIRE_RATE	= 10.0;
const float MACHINE_GUN_BULLET_NUM	= 6.0;
const float SNIPER_FIRE_RATE		= 160.0;
const float TURRET_FIRE_RATE		= 100.0;
const float PLAYER_SPAWN_HEIGHT		= 200.0;
const float PLAYER_JUMP_HEIGHT		= 16.0 * 3.0;
const float PLAYER_IMMORTALITY_LEN	= 60.0 * 3.0;
const float PLAYER_RUN_ANIM_SPEED 	= 0.13;
const float PLAYER_JUMP_ANIM_SPEED	= 0.13;
const float PLAYER_FALL_SPEED 		= 3.0;
const float PLAYER_BULLET_SPEED		= 3.0;
const float PLAYER_HIT_BOX_SIZE_MUL	= 0.7;
const float ENEMY_RUN_SPEED 		= 1.0;
const float ENEMY_BULLET_SPEED 		= 1.0;
const float ENEMY_ANIM_SPEED		= 0.13;
const float SOLDIER_SPAWN_RATE		= 180.0;
const float BOSS_CORE_HP			= 32.0;
const float BOSS_CANNON_HP			= 8.0;
const float BOSS_CANNON_FIRE_RATE	= 120.0;
const float WATER_HEIGHT			= 8.0;
const float WATER_END				= 32.0 * 63.0;
const float BRIDGE_0_START_TILE		= 30.0;
const float BRIDGE_0_END_TILE		= 35.0;
const float BRIDGE_1_START_TILE		= 40.0;
const float BRIDGE_1_END_TILE		= 45.0;
const float BRIGDE_EXPLODE_TIME		= 70.0;
const float CAMERA_END				= 32.0 * 102.0;
const float PLAYER_END				= 32.0 * 108.0 + 16.0;
const float SOLDIER_SPAWN_END		= 32.0 * 99.0 - 32.0 * 2.0;
const vec2 	BILL_PRONE_SIZE			= vec2( 32.0, 18.0 );
const vec2 	BILL_RUN_SIZE			= vec2( 24.0, 34.0 );
const vec2 	BILL_JUMP_SIZE			= vec2( 20.0, 20.0 );
const vec2 	SOLDIER_SIZE 			= vec2( 16.0, 32.0 );
const vec2 	SNIPER_SIZE				= vec2( 24.0, 32.0 );
const vec2 	BULLET_SIZE				= vec2( 3.0,  3.0  );
const vec2 	POWER_BULLET_SIZE		= vec2( 5.0,  5.0  );
const vec2 	TURRET_SIZE				= vec2( 32.0, 32.0 );
const vec2 	POWER_UP_SIZE			= vec2( 24.0, 14.0 );
const vec2 	BOSS_CORE_SIZE			= vec2( 24.0, 31.0 );
const vec2 	BOSS_CANNON_SIZE		= vec2( 14.0, 6.0 );
const float TURRET_HP				= 8.0;
const float GAME_STATE_TITLE		= 0.0;
const float GAME_STATE_LEVEL		= 1.0;
const float GAME_STATE_LEVEL_DIE	= 2.0;
const float GAME_STATE_LEVEL_WIN	= 3.0;
const float GAME_STATE_GAME_OVER	= 4.0;
const float GAME_STATE_VICTORY		= 5.0;
const float UI_TITLE_TIME			= 120.0;
const float UI_GAME_START_TIME		= 60.0;
const float UI_VICTORY_TIME			= 300.0;

vec4 gPlayer;
vec4 gPlayerState;
vec4 gPlayerDir;
vec4 gPlayerWeapon;
vec4 gCamera;
vec4 gSoldier0;
vec4 gSoldier1;
vec4 gSoldier2;
vec4 gSoldier0State;
vec4 gSoldier1State;
vec4 gSoldier2State;
vec4 gSniper;
vec4 gPlayerBullet0;
vec4 gPlayerBullet1;
vec4 gPlayerBullet2;
vec4 gPlayerBullet3;
vec4 gPlayerBullet4;
vec4 gPlayerBullet5;
vec4 gEnemyBullet0;
vec4 gEnemyBullet1;
vec4 gEnemyBullet2;
vec4 gEnemyBullet3;
vec4 gExplosion;
vec4 gHit;
vec4 gTurret0;
vec4 gTurret1;
vec4 gTurret0State;
vec4 gTurret1State;
vec4 gPowerUp;
vec4 gPowerUpState;
vec4 gBossCore;
vec4 gBossCannon0;
vec4 gBossCannon1;
vec4 gBossBullet0;
vec4 gBossBullet1;
vec4 gGameState;
vec4 gBridge;

float IsInside( vec2 p, vec2 c ) { vec2 d = abs(p-0.5-c) - 0.5; return -max(d.x,d.y); }

float Rand()
{
    vec2 co = vec2( iTime, iTime );
    return fract( sin( dot( co.xy, vec2( 12.9898, 78.233 ) ) ) * 43758.5453 );
}

vec4 LoadValue( vec2 tx )
{
    return texture( iChannel0, ( tx + 0.5 ) / iChannelResolution[ 0 ].xy );
}

void StoreValue( vec2 re, vec4 va, inout vec4 fragColor, vec2 fragCoord )
{
    fragCoord = floor( fragCoord );
    fragColor = ( fragCoord.x == re.x && fragCoord.y == re.y ) ? va : fragColor;
}

bool Collide( vec2 p0, vec2 s0, vec2 p1, vec2 s1 )
{
    // pivot x in the middle, and y in the bottom
    p0.x -= s0.x * 0.5;
    p1.x -= s1.x * 0.5;
    
    return 		p0.x <= p1.x + s1.x
        	&& 	p0.y <= p1.y + s1.y
        	&& 	p1.x <= p0.x + s0.x
        	&& 	p1.y <= p0.y + s0.y;
}

float GetSupport( vec2 p )
{
    float tileX	= floor( p.x / 32.0 );
    float tileY	= floor( p.y / 16.0 );
    
    bool grass0 = false;
    bool grass2 = false;
    bool grass3 = false;
    bool grass4 = false;
    bool grass6 = false;
    bool grass8 = false;
    
	if ( 		( tileX >= 52.0 && tileX < 67.0 ) 
			|| 	( tileX >= 72.0 && tileX < 77.0 )   
			|| 	( tileX >= 86.0 && tileX < 88.0 ) )
    {
        grass8 = true;
    }
    
	if ( 		( tileX >= 3.0   && tileX < 30.0 ) 
        	|| 	( tileX >= 35.0  && tileX < 40.0 ) 
        	|| 	( tileX >= 45.0  && tileX < 53.0 ) 
        	|| 	( tileX >= 66.0  && tileX < 73.0 )
            || 	( tileX >= 78.0  && tileX < 80.0 )
            || 	( tileX >= 85.0  && tileX < 87.0 )
            || 	( tileX >= 89.0  && tileX < 91.0 )
            ||  ( tileX >= 102.0 && tileX < 106.0 ) )
    {
        grass6 = true;
    }
    
	if ( 		( tileX >= 10.0 && tileX < 13.0 )
			||	( tileX >= 18.0 && tileX < 20.0 )
        	|| 	( tileX >= 58.0 && tileX < 65.0 )
			|| 	( tileX >= 76.0 && tileX < 79.0 )
            || 	( tileX >= 81.0 && tileX < 83.0 )
            || 	( tileX >= 90.0 && tileX < 95.0 )
            ||  ( tileX >= 100.0 && tileX < 102.0 )
            || 	( tileX == 106.0 ) )
    {
        grass4 = true;
    }
    
    if ( 		( tileX >= 26.0 && tileX < 29.0 )
            ||  ( tileX >= 55.0 && tileX < 57.0 )
            || 	( tileX == 74.0 )
			||  ( tileX == 87.0 )
			|| 	( tileX >= 103.0 && tileX < 106.0 ) )
    {
        grass3 = true;
    }
        
	if ( 		( tileX == 13.0 || tileX == 16.0 )
            ||  ( tileX >= 68.0 && tileX < 70.0 )
            ||  ( tileX >= 71.0 && tileX < 73.0 )
            || 	( tileX >= 82.0 && tileX < 85.0 )
            ||  ( tileX >= 97.0 && tileX < 99.0 )
            || 	( tileX == 107.0 ) )
    {
        grass2 = true;
    }
        
	if ( 		( tileX >= 14.0 && tileX < 16.0 ) 
            || 	( tileX >= 24.0 && tileX < 26.0 ) 
            || 	( tileX >= 52.0 && tileX < 55.0 ) 
            || 	( tileX >= 62.0 && tileX < 68.0 )
            || 	( tileX == 81.0 )
			||  ( tileX == 86.0 )
            || 	( tileX >= 93.0 && tileX < 96.0 )
            ||  ( tileX >= 102.0 ) )      
	{
        grass0 = true;
    }
    
	if ( tileX >= BRIDGE_0_START_TILE && tileX < BRIDGE_0_END_TILE && gBridge.x < tileX )
    {
        grass6 = true;
    }

	if ( tileX >= BRIDGE_1_START_TILE && tileX < BRIDGE_1_END_TILE && gBridge.x < tileX )
    {
        grass6 = true;
    } 
    
    float height = 8.0;
    if ( grass0 )
    {
        height = 1.0 * 16.0;
    }    
    if ( grass2 && tileY >= 2.0 )
    {
        height = 3.0 * 16.0;
    }
    if ( grass3 && tileY >= 3.0 )
    {
        height = 4.0 * 16.0;
    }    
    if ( grass4 && tileY >= 4.0 )
    {
        height = 5.0 * 16.0;
    }
    if ( grass6 && tileY >= 6.0 )
    {
        height = 7.0 * 16.0;
    } 
   	if ( grass8 && tileY >= 8.0 )
    {
        height = 9.0 * 16.0;
    }     
    
    return height - 4.0;
}

void SpawnSniper( float tileX, float tileY, float screenWidth )
{
    float spawnX = tileX * 32.0 - screenWidth;
    if ( gCamera.x > spawnX && gCamera.y < spawnX )
    {
		gSniper = vec4( tileX * 32.0, tileY * 32.0 + 12.0, 0.0, 0.0 );
        gCamera.y = spawnX;
    }
}

void SpawnTurret( float tileX, float tileY, float screenWidth )
{
    float spawnX = tileX * 32.0 - screenWidth;
    if ( gCamera.x >= spawnX && gCamera.y < spawnX )
    {
        if ( gTurret0.x == 0.0 || ( gTurret1.x > 0.0 && gTurret0.x < gTurret1.x ) )
        {
			gTurret0 		= vec4( tileX * 32.0 + 16.0, tileY * 32.0, 0.0, 0.0 );
        	gTurret0State	= vec4( TURRET_HP, 0.0, 0.0, 0.0 );
        }
        else
        {
			gTurret1 		= vec4( tileX * 32.0 + 16.0, tileY * 32.0, 0.0, 0.0 );
        	gTurret1State	= vec4( TURRET_HP, 0.0, 0.0, 0.0 );
        }

        gCamera.y = spawnX;
    }
}

void SpawnPowerUp( float tileX, float screenWidth )
{
    float spawnX = tileX * 32.0 - screenWidth;
    if ( gCamera.x > spawnX && gCamera.y < spawnX )
    {
    	gPowerUp 		= vec4( spawnX, 150.0, 0.0, 0.0 );
        gPowerUpState	= vec4( STATE_RUN, 150.0, 0.0, 0.0 );  
        gCamera.y = spawnX;
    }
}

void UpdateSpawner( float screenWidth )
{
    SpawnSniper( 15.0, 0.0, screenWidth );
    SpawnPowerUp( 23.0, screenWidth );    
    SpawnSniper( 25.0, 0.0, screenWidth );
    SpawnTurret( 47.0, 2.0, screenWidth );
    SpawnSniper( 48.0, 3.0, screenWidth );
    SpawnSniper( 56.0, 4.0, screenWidth );
    SpawnPowerUp( 55.0, screenWidth ); 
    SpawnTurret( 59.0, 3.0, screenWidth );
    SpawnTurret( 65.0, 3.0, screenWidth );
    SpawnTurret( 72.0, 2.0, screenWidth );
    SpawnTurret( 76.0, 5.0, screenWidth );
    SpawnSniper( 82.0, 2.0, screenWidth );
    SpawnPowerUp( 89.0, screenWidth );    
    SpawnTurret( 94.0, 3.0, screenWidth );
    SpawnTurret( 101.0, 1.0, screenWidth );
    SpawnTurret( 105.0, 1.0, screenWidth );
    SpawnSniper( 109.8, 4.875, screenWidth );

    if ( gCamera.z == 0.0 && Rand() > 0.5 )
    {
        gCamera.z = SOLDIER_SPAWN_RATE - 20.0;
    }

    ++gCamera.z;
    vec4 newSoldier 		= vec4( gCamera.x + screenWidth, 300.0, -1.0, 0.0 );
    vec4 newSoldierState 	= vec4( 0.0, 0.0, 0.0, 0.0 );
	newSoldier.y = GetSupport( newSoldier.xy );    
    if ( gCamera.x < SOLDIER_SPAWN_END && gCamera.z > SOLDIER_SPAWN_RATE && newSoldier.y > WATER_HEIGHT )
    {
        gCamera.z = 0.0;
        
        if ( gSoldier0.x <= 0.0 )
        {
            gSoldier0 		= newSoldier;
            gSoldier0State 	= newSoldierState;
        }
		else if ( gSoldier1.x <= 0.0 )
        {
            gSoldier1 		= newSoldier;
            gSoldier1State 	= newSoldierState;
        }
		else if ( gSoldier2.x <= 0.0 )
        {
            gSoldier2 		= newSoldier;
            gSoldier2State 	= newSoldierState;
        }        
    }
}

void SpawnEnemyBullet( vec2 pos, vec2 dir )
{
    if ( gEnemyBullet0.x <= 0.0 )
    {
		gEnemyBullet0 = vec4( pos, dir );
    }
    else if ( gEnemyBullet1.x <= 0.0 )
    {
        gEnemyBullet1 = vec4( pos, dir );
    }
    else if ( gEnemyBullet2.x <= 0.0 )
    {
        gEnemyBullet2 = vec4( pos, dir );
    }
    else if ( gEnemyBullet3.x <= 0.0 )
    {
        gEnemyBullet3 = vec4( pos, dir );
    }    
}

void UpdateSniper( inout vec4 sniper, vec2 playerTarget )
{
    if ( sniper.x + SNIPER_SIZE.x * 0.5 < gCamera.x )
    {
        sniper.x = 0.0;
    }  
    
    ++sniper.w;
	if ( sniper.x > 0.0 && sniper.w > SNIPER_FIRE_RATE )
    {
        sniper.w = 0.0;
        vec2 pos = sniper.xy + vec2( 0.0, 24.0 );
        SpawnEnemyBullet( pos, normalize( playerTarget - pos ) );
    }
    sniper.z = playerTarget.x > sniper.x ? 1.0 : -1.0;    
}

void UpdateTurret( inout vec4 turret, inout vec4 turretState, vec2 playerTarget )
{
    if ( turret.x + TURRET_SIZE.x * 0.5 < gCamera.x )
    {
        turret.x = 0.0;
    }    
    
	vec2 turretAim = normalize( playerTarget - turret.xy );

    // constrain barrel to one of the 12 possible rotations
    float turretAimAngle = atan( -turretAim.y, turretAim.x );    
    turretAimAngle = turretAimAngle / ( 2.0 * MATH_PI );
    turretAimAngle = floor( turretAimAngle * 12.0 + 0.5 );
    turret.z = mod( turretAimAngle + 6.0, 12.0 );
    turretAimAngle = turretAimAngle * 2.0 * MATH_PI / 12.0;
    turretAim = vec2( cos( turretAimAngle ), -sin( turretAimAngle ) );
    
    ++turretState.y;
	if ( turret.x > 0.0 && turretState.y > TURRET_FIRE_RATE )
    {
        turretState.y = 0.0;
		SpawnEnemyBullet( turret.xy, turretAim );
    }
}

void UpdateBossCannon( inout vec4 bossCannon )
{
    float accX 		= -fract( iTime * 1.069 + bossCannon.x * 7.919 ) * 5.0;
    vec4 newBullet	= vec4( bossCannon.xy - vec2( BOSS_CANNON_SIZE.x * 0.5, 0.0), accX, 0.0 );
    
    ++bossCannon.z;
    if ( bossCannon.z > BOSS_CANNON_FIRE_RATE )
    {
        bossCannon.z = 0.0;
        if ( gBossBullet0.x <= 0.0 )
        {
            gBossBullet0 = newBullet;
        }
        else if ( gBossBullet1.x <= 0.0 )
        {
            gBossBullet1 = newBullet;
        }
    }
}

void PlayerBulletSoldierTest( inout vec4 playerBullet, inout vec4 soldier )
{
    if ( playerBullet.x > 0.0 && Collide( playerBullet.xy, BULLET_SIZE, soldier.xy, SOLDIER_SIZE ) )
    {
        gExplosion 		= vec4( soldier.xy + vec2( 0.0, SOLDIER_SIZE.y * 0.5 ), 0.0, 0.0 );
        gHit		 	= vec4( playerBullet.xy, 0.0, 0.0 );
		soldier.x 		= 0.0;
        playerBullet.x 	= 0.0;
    }
}

void PlayerBulletSniperTest( inout vec4 playerBullet, inout vec4 sniper )
{
	if ( playerBullet.x > 0.0 && Collide( playerBullet.xy, BULLET_SIZE, sniper.xy, SNIPER_SIZE ) )
    {
        gExplosion		= vec4( sniper.xy + vec2( 0.0, SNIPER_SIZE.y * 0.5 ), 0.0, 0.0 );
        gHit		  	= vec4( playerBullet.xy, 0.0, 0.0 );
		sniper.x		= 0.0;
        playerBullet.x 	= 0.0;
    }
}

void PlayerBulletTurretTest( inout vec4 playerBullet, inout vec4 turret, inout vec4 turretState )
{
	if ( playerBullet.x > 0.0 && Collide( playerBullet.xy, BULLET_SIZE, turret.xy + vec2( 0.0, -TURRET_SIZE.y * 0.5 ), TURRET_SIZE ) )
    {
        gHit			= vec4( playerBullet.xy, 0.0, 0.0 );
        playerBullet.x 	= 0.0;
        
        --turretState.x;        
        if ( turretState.x <= 0.0 )
        {
			gExplosion = vec4( turret.xy, 0.0, 0.0 );
        	turret.x = 0.0;
        }
    }
}

void PlayerBulletPowerUpTest( inout vec4 playerBullet )
{
	if ( playerBullet.x > 0.0 && gPowerUpState.x == STATE_RUN && Collide( playerBullet.xy, BULLET_SIZE, gPowerUp.xy, POWER_UP_SIZE ) )
    {
		gHit			= vec4( playerBullet.xy, 0.0, 0.0 );
        gExplosion 		= vec4( gPowerUp.xy + vec2( 0.0, POWER_UP_SIZE.y * 0.5 ), 0.0, 0.0 );        
        playerBullet.x 	= 0.0;
        gPowerUpState.x = STATE_JUMP;
        gPowerUp.z		= 1.0;
    }
}

void PlayerBulletBossCoreTest( inout vec4 playerBullet )
{
	if ( playerBullet.x > 0.0 && Collide( playerBullet.xy, BULLET_SIZE, gBossCore.xy + vec2( 0.0, BOSS_CORE_SIZE.y * 0.25 ), BOSS_CORE_SIZE * 0.5 ) )
    {
		gHit			= vec4( playerBullet.xy, 0.0, 0.0 );
        playerBullet.x 	= 0.0;
		--gBossCore.z;
        if ( gBossCore.z < 0.0 )
        {
            gExplosion 		= vec4( gBossCore.xy + vec2( 0.0, BOSS_CORE_SIZE.y * 0.5 ), 0.0, 0.0 );
            gBossCore.x 	= 0.0;
            gGameState.x 	= GAME_STATE_LEVEL_WIN;
			gGameState.y 	= 0.0;
        }
    }
}

void PlayerBulletBossCannonTest( inout vec4 playerBullet, inout vec4 bossCannon )
{
	if ( playerBullet.x > 0.0 && Collide( playerBullet.xy, BULLET_SIZE, bossCannon.xy, BOSS_CANNON_SIZE ) )
    {
		gHit			= vec4( playerBullet.xy, 0.0, 0.0 );
        playerBullet.x 	= 0.0;
		--bossCannon.w;
        if ( bossCannon.w < 0.0 )
        {
            gExplosion 		= vec4( bossCannon.xy + vec2( 0.0, BOSS_CANNON_SIZE.y * 0.5 ), 0.0, 0.0 );
            bossCannon.x 	= 0.0;
        }
    }
}

void UpdatePlayerBullet( inout vec4 playerBullet, float screenWidth, float screenHeight )
{
    if ( !Collide( playerBullet.xy, BULLET_SIZE, vec2( gCamera.x + screenWidth * 0.5, 0.0 ), vec2( screenWidth, screenHeight ) ) )
    {
        playerBullet.x = 0.0;
    }
    if ( playerBullet.x > 0.0 )
    {
    	playerBullet.xy += playerBullet.zw * PLAYER_BULLET_SPEED;
    }
}

void PlayerHit( vec4 playerHitBox )
{
#ifndef GOD_MODE
    if ( gGameState.x == GAME_STATE_LEVEL && gGameState.y > UI_GAME_START_TIME )
    {
        gPlayerState.x 	= STATE_JUMP;
        gPlayerState.y 	= 0.0;        
        gPlayerState.z 	= 1.0;
        gPlayerState.w -= 1.0;    
        gExplosion 		= vec4( gPlayer.xy + vec2( 0.0, playerHitBox.z * 0.5 ), 0.0, 0.0 );
        gPlayer 		= vec4( gCamera.x + 32.0 * 2.0 + 24.0, PLAYER_SPAWN_HEIGHT, PLAYER_SPAWN_HEIGHT, 0.0 );
        gPlayerDir		= vec4( 1.0, 0.0, 0.0, PLAYER_IMMORTALITY_LEN );
        gPlayerWeapon 	= vec4( WEAPON_RIFLE, 0.0, RIFLE_FIRE_RATE, RIFLE_BULLET_NUM );

        if ( gPlayerState.w <= 0.0 )
        {
            gGameState.x 	= GAME_STATE_LEVEL_DIE;
            gGameState.y 	= 0.0;
            gPlayer			= vec4( 0.0, 1000000.0, 0.0, 0.0 );
            gPlayerState.x 	= STATE_FALL;
        }
    }
#endif
}

void UpdateEnemyBullet( inout vec4 enemyBullet, vec4 playerHitBox, float screenWidth, float screenHeight )
{
    if ( !Collide( enemyBullet.xy, BULLET_SIZE, vec2( gCamera.x + screenWidth * 0.5, 0.0 ), vec2( screenWidth, screenHeight ) ) )
    {
        enemyBullet.x = 0.0;
    }
    
	if ( enemyBullet.x > 0.0 )
    {
    	enemyBullet.xy += enemyBullet.zw * ENEMY_BULLET_SPEED;
    }
   
	if ( Collide( playerHitBox.xy, playerHitBox.zw, enemyBullet.xy, BULLET_SIZE ) )
    {
        PlayerHit( playerHitBox );
        enemyBullet.x = 0.0;
    }        
}

void UpdateBossBullet( inout vec4 bossBullet, vec4 playerHitBox, float screenWidth, float screenHeight )
{
    if ( !Collide( bossBullet.xy, POWER_BULLET_SIZE, vec2( gCamera.x + screenWidth * 0.5, 0.0 ), vec2( screenWidth, screenHeight ) ) )
    {
        bossBullet.x = 0.0;
    }
    
	if ( bossBullet.x > 0.0 )
    {
        bossBullet.xy += bossBullet.zw;
        bossBullet.w -= 1.0 / 10.0;
    }
   
	if ( Collide( playerHitBox.xy, playerHitBox.zw, bossBullet.xy, POWER_BULLET_SIZE ) )
    {
        PlayerHit( playerHitBox );
        bossBullet.x = 0.0;
    }        
}

void UpdateSoldier( inout vec4 soldier, inout vec4 soldierState, vec4 playerHitBox, float screenWidth, float screenHeight )
{
    float soldierSupport = GetSupport( soldier.xy );    
    if ( soldierState.x == STATE_RUN )
    {
		soldierState.y = mod( soldierState.y + ENEMY_ANIM_SPEED, 2.0 );        
        
        if ( soldier.y != soldierSupport )
        {
            // lost support - either jump or go back
            if ( Rand() > 0.3 )
            {
            	soldierState.x = STATE_JUMP;
            	soldierState.y = 1.0;
            	soldierState.z = 0.0;
			}
            else
            {
            	soldier.z = -soldier.z;
            }
        }
    }
    else if ( soldierState.x == STATE_JUMP )
    {
		soldierState.z += 1.0 / 20.0;
        soldier.y += 3.0 * ( 1.0 - soldierState.z );
        if ( soldierState.z > 1.0 && soldier.y <= soldierSupport )
        {
            soldier.y = soldierSupport;
            soldierState.x = STATE_RUN;
        }
    }
	soldier.x += soldier.z * ENEMY_RUN_SPEED;

    if ( soldier.x > gCamera.x + screenWidth || soldier.x < gCamera.x )
    {
    	soldier.x = -1.0;        
    }

    // soldier death
    if ( soldier.x > 0.0 && soldier.y < WATER_HEIGHT )   
    {
        gExplosion 	= vec4( soldier.xy + vec2( 0.0, SOLDIER_SIZE.y * 0.5 ), 0.0, 0.0 );
		soldier 	= vec4( 0.0, 0.0, 0.0, 0.0 );
    }
    
	if ( soldier.x > 0.0 && Collide( playerHitBox.xy, playerHitBox.zw, soldier.xy, SOLDIER_SIZE ) )
    {
        PlayerHit( playerHitBox );
    }    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // don't compute gameplay outside of the data area
    if ( fragCoord.x > 32.0 || fragCoord.y > 32.0 ) 
    {
        discard;    
    }

    float resMultX  	= floor( iResolution.x / NES_RES_X );
    float resMultY  	= floor( iResolution.y / NES_RES_Y );
    float resRcp		= 1.0 / max( min( resMultX, resMultY ), 1.0 );
    float screenWidth	= floor( iResolution.x * resRcp );
    float screenHeight	= floor( iResolution.y * resRcp );
    
    // keys
    bool keyLeft  	= texture( iChannel1, vec2( KEY_LEFT, 0.25 ) ).x > 0.5;
    bool keyRight 	= texture( iChannel1, vec2( KEY_RIGHT, 0.25 ) ).x > 0.5;
    bool keyUp  	= texture( iChannel1, vec2( KEY_UP, 0.25 ) ).x > 0.5;
    bool keyDown 	= texture( iChannel1, vec2( KEY_DOWN, 0.25 ) ).x > 0.5;    
    bool keyShoot	= texture( iChannel1, vec2( KEY_A, 0.25 ) ).x > 0.5 || texture( iChannel1, vec2( KEY_Q, 0.25 ) ).x > 0.5;
    bool keyJump 	= texture( iChannel1, vec2( KEY_S, 0.25 ) ).x > 0.5 || texture( iChannel1, vec2( KEY_W, 0.25 ) ).x > 0.5;
    
	gPlayer        	= LoadValue( txPlayer );
	gPlayerState   	= LoadValue( txPlayerState );
	gPlayerDir    	= LoadValue( txPlayerDir );
    gPlayerWeapon  	= LoadValue( txPlayerWeapon );
	gCamera       	= LoadValue( txCamera );
	gSoldier0     	= LoadValue( txSoldier0 );
    gSoldier1      	= LoadValue( txSoldier1 );
    gSoldier2      	= LoadValue( txSoldier2 );
	gSoldier0State 	= LoadValue( txSoldier0State );
    gSoldier1State 	= LoadValue( txSoldier1State );
    gSoldier2State 	= LoadValue( txSoldier2State );
	gSniper        	= LoadValue( txSniper );
	gPlayerBullet0 	= LoadValue( txPlayerBullet0 );
    gPlayerBullet1 	= LoadValue( txPlayerBullet1 );
    gPlayerBullet2 	= LoadValue( txPlayerBullet2 );
	gPlayerBullet3 	= LoadValue( txPlayerBullet3 );
    gPlayerBullet4 	= LoadValue( txPlayerBullet4 );
    gPlayerBullet5 	= LoadValue( txPlayerBullet5 );    
	gEnemyBullet0  	= LoadValue( txEnemyBullet0 );
	gEnemyBullet1  	= LoadValue( txEnemyBullet1 );
    gEnemyBullet2  	= LoadValue( txEnemyBullet2 );
    gEnemyBullet3  	= LoadValue( txEnemyBullet3 );
	gExplosion     	= LoadValue( txExplosion );
	gHit           	= LoadValue( txHit );
	gTurret0       	= LoadValue( txTurret0 );
	gTurret1       	= LoadValue( txTurret1 );
	gTurret0State   = LoadValue( txTurret0State );
	gTurret1State   = LoadValue( txTurret1State );    
    gPowerUp		= LoadValue( txPowerUp );
    gPowerUpState	= LoadValue( txPowerUpState );
    gBossCore		= LoadValue( txBossCore );
    gBossCannon0	= LoadValue( txBossCannon0 );
    gBossCannon1	= LoadValue( txBossCannon1 );
    gBossBullet0	= LoadValue( txBossBullet0 );
    gBossBullet1	= LoadValue( txBossBullet1 );
    gGameState		= LoadValue( txGameState );
    gBridge			= LoadValue( txBridge );

    // game state machine
    ++gGameState.y;    
    if ( gGameState.x == GAME_STATE_TITLE )
    {
        if ( gGameState.y > UI_TITLE_TIME )
        {
            gGameState.x = GAME_STATE_LEVEL;
            gGameState.y = 0.0;
        }
    }
    else if ( gGameState.x == GAME_STATE_LEVEL )
    {
		if ( gGameState.y <= UI_GAME_START_TIME )
    	{
        	gCamera 		= vec4( 32.0, -100.0, 0.0, 0.0 );
			gPlayer 		= vec4( gCamera.x + 32.0 * 2.0 + 24.0, PLAYER_SPAWN_HEIGHT, PLAYER_SPAWN_HEIGHT, 0.0 );
    		gPlayerState.x 	= STATE_JUMP;
        	gPlayerState.y 	= 0.0;        
        	gPlayerState.z 	= 1.0;
        	gPlayerState.w 	= PLAYER_LIFE_NUM;
        	gPlayerWeapon 	= vec4( WEAPON_RIFLE, 0.0, RIFLE_FIRE_RATE, RIFLE_BULLET_NUM );
        	gBossCore		= vec4( 32.0 * 108.0 + 23.0 + 12.0, 34.0, BOSS_CORE_HP, 0.0 );
            gBossCannon0	= vec4( 3478.0, 92.0, 0.0, BOSS_CANNON_HP );
            gBossCannon1	= gBossCannon0 + vec4( 22.0, 0.0, 0.0, 0.0 );
            gSoldier0		= vec4( 0.0, 0.0, 0.0, 0.0 );
            gSoldier1		= vec4( 0.0, 0.0, 0.0, 0.0 );
            gSoldier2		= vec4( 0.0, 0.0, 0.0, 0.0 );
            gBridge			= vec4( 0.0, 0.0, 0.0, 0.0 );
            gPowerUp		= vec4( 0.0, 0.0, 0.0, 0.0 );
            gTurret0		= vec4( 0.0, 0.0, 0.0, 0.0 );
            gTurret1		= vec4( 0.0, 0.0, 0.0, 0.0 );
    	}
    }
    else if ( gGameState.x == GAME_STATE_LEVEL_DIE )
    {
        if ( gGameState.y > UI_TITLE_TIME )
        {
            gGameState.x = GAME_STATE_GAME_OVER;
            gGameState.y = 0.0;
        }
    }    
    else if ( gGameState.x == GAME_STATE_LEVEL_WIN )
    {
        if ( gGameState.y > UI_TITLE_TIME )
        {
            gGameState.x = GAME_STATE_VICTORY;
            gGameState.y = 0.0;
        }
    }
    else if ( gGameState.x == GAME_STATE_VICTORY )
    {
        if ( gGameState.y > UI_VICTORY_TIME )
        {
            gGameState.x = GAME_STATE_TITLE;
            gGameState.y = 0.0;
        }
    } 
	if ( gGameState.x == GAME_STATE_GAME_OVER )
    {
		if ( gGameState.y > UI_TITLE_TIME )
        {
            gGameState.x = GAME_STATE_TITLE;
            gGameState.y = 0.0;
        }
    }

 
	UpdateSpawner( screenWidth );
        
    // player state machine
	float playerSupport = GetSupport( gPlayer.xy );
    if ( gPlayerState.x == STATE_RUN )
    {
        if ( keyJump )
    	{
            gPlayer.z		= gPlayer.y;
            gPlayer.w		= 0.0;
	        gPlayerState.x 	= STATE_JUMP;
            gPlayerState.y 	= 0.0;
			gPlayerState.z 	= 0.0;
    	}
        else if ( keyRight || keyLeft )
        {
    		gPlayerState.y = mod( gPlayerState.y + PLAYER_RUN_ANIM_SPEED, 3.0 );
        }        
        else
        {
            if ( keyDown )
            {
                gPlayerState.x = STATE_PRONE;
            }
            gPlayerState.y = 0.0;
        }

        if ( gPlayer.y != playerSupport )
        {
			gPlayerState.x = STATE_FALL;
        }
        if ( gPlayer.y <= WATER_HEIGHT )
        {
            if ( gPlayer.x < WATER_END )
            {
            	gPlayerState.x = STATE_WATER;
            }
            else
            {
                PlayerHit( vec4( gPlayer.xy, BILL_PRONE_SIZE ) );
            }
        }
    }        
    else if ( gPlayerState.x == STATE_PRONE )
    {
        if ( !keyDown || keyRight || keyLeft )
        {
            gPlayerState.x = STATE_RUN;
        }
        else if ( keyJump )
    	{
     		gPlayerState.x = STATE_FALL;
        	gPlayer.y -= PLAYER_FALL_SPEED + 20.0;
		}        
    }
    else if ( gPlayerState.x == STATE_JUMP )
    {
        if ( keyRight )
        {
            gPlayer.w = 1.0;
        }
        else if ( keyLeft )
        {
            gPlayer.w = -1.0;
        }
        
        gPlayerState.y = mod( gPlayerState.y + PLAYER_JUMP_ANIM_SPEED, 2.0 );
		gPlayerState.z += 1.0 / 30.0;
        gPlayer.x += gPlayer.w * PLAYER_RUN_SPEED;
        gPlayer.y += 4.5 * ( 1.0 - gPlayerState.z );
        if ( gPlayerState.z > 1.0 && gPlayer.y <= playerSupport && gPlayer.y - gPlayer.z < PLAYER_JUMP_HEIGHT )
        {
            gPlayer.y = playerSupport;
            gPlayerState.x = STATE_RUN;
        }
    }
    else if ( gPlayerState.x == STATE_FALL )
    {
        if ( gPlayer.y <= playerSupport )
        {
            gPlayer.y = playerSupport;
            gPlayerState.x = STATE_RUN;
        }
        else
        {
            gPlayer.y -= PLAYER_FALL_SPEED;
        }
    }    
    else if ( gPlayerState.x == STATE_WATER )
    {
        if ( keyDown )
        {
			gPlayerState.x = STATE_UNDER_WATER;
        }
        
		if ( playerSupport > WATER_HEIGHT )
        {
            gPlayerState.x 	= STATE_RUN;
            gPlayer.y		= playerSupport;
        }
    }
    else if ( gPlayerState.x == STATE_UNDER_WATER )
    {
        if ( !keyDown )
        {
        	gPlayerState.x = STATE_WATER;
        }
    }
    
    // importality tick
    --gPlayerDir.w;
    
    // look dir
    vec2 newDir;
    gPlayerDir.x = keyRight ? 1.0 : ( keyLeft ? -1.0 : 0.0 );
	gPlayerDir.y = keyUp 	? 1.0 : ( keyDown ? -1.0 : 0.0 );
    if ( ( gPlayerDir.x == 0.0 && gPlayerDir.y == 0.0 ) || gPlayerState.x == STATE_PRONE )
    {
        gPlayerDir.xy = gPlayerDir.z < 0.0 ? vec2( -1.0, 0.0 ) : vec2( 1.0, 0.0 );
    }
    
    // flip
    if ( keyRight && gPlayerState.x != STATE_UNDER_WATER )
    {
        gPlayerDir.z = 1.0;
    }
    else if ( keyLeft && gPlayerState.x != STATE_UNDER_WATER )
    {
        gPlayerDir.z = -1.0;
    }    
    
    // move
    if ( gPlayerState.x != STATE_PRONE && gPlayerState.x != STATE_UNDER_WATER && gPlayerState.x != STATE_JUMP )
    {
        if ( keyLeft )
        {
            gPlayer.x -= PLAYER_RUN_SPEED;
        }
        else if ( keyRight )
        {
            gPlayer.x += PLAYER_RUN_SPEED;
        }
    }
    

    // clamp player to edge of the screen
    gPlayer.x = clamp( gPlayer.x, gCamera.x, PLAYER_END );
    
    // scroll camera
   	if ( gPlayer.x - screenWidth * 0.5 + 24.0 > gCamera.x )
    {
        gCamera.x = min( gPlayer.x - screenWidth * 0.5 + 24.0, CAMERA_END );
    }
        
    
    // player size and center
    vec4 playerHitBox 		= vec4( 0.0, 0.0, BILL_RUN_SIZE );
    vec2 playerWeaponOffset = gPlayerDir.y == 1.0 && gPlayerDir.x != 0.0 ? vec2( 6.0, 30.0 ) : ( gPlayerDir.y == 1.0 ? vec2( -2.0, 40.0 ) : ( gPlayerDir.y == -1.0 ? vec2( 7.0, 14.0 ) : vec2( 10.0, 19.0 ) ) );    
    if ( gPlayerState.x == STATE_PRONE )
    {
        playerHitBox.zw		= BILL_PRONE_SIZE;
        playerWeaponOffset 	= vec2( 14.0, 7.0 );
    }
    else if ( gPlayerState.x == STATE_JUMP )
    {    
        playerHitBox.zw 	= BILL_JUMP_SIZE;
        playerWeaponOffset 	= vec2( 0.0, BILL_JUMP_SIZE.y * 0.5 );
    }
    else if ( gPlayerState.x == STATE_WATER )
    {
        playerWeaponOffset.y -= 12.0;
    }

    playerHitBox.x = gPlayer.x;
    playerHitBox.y = floor( gPlayer.y + playerHitBox.w * 0.5 * ( 1.0 - PLAYER_HIT_BOX_SIZE_MUL ) + 0.5 );
    playerHitBox.zw *= PLAYER_HIT_BOX_SIZE_MUL;

    if ( gPlayerDir.w > 0.0 || gPlayerState.x == STATE_UNDER_WATER )
    {
    	// player is immortal        
        playerHitBox = vec4( -1000000.0 );
    }

    playerWeaponOffset.x = gPlayerDir.z < 0.0 ? -playerWeaponOffset.x : playerWeaponOffset.x;
    vec2 playerWeapon = gPlayer.xy + playerWeaponOffset;
    vec2 playerTarget = gPlayer.xy + vec2( 0.0, BILL_RUN_SIZE.y * 0.5 );
    
    // player shooting
    ++gPlayerWeapon.y;
    float playerBulletNum = 	float( gPlayerBullet0.x > 0.0 ) 
        					+ 	float( gPlayerBullet1.x > 0.0 )
    						+ 	float( gPlayerBullet2.x > 0.0 )
    						+ 	float( gPlayerBullet3.x > 0.0 )
    						+ 	float( gPlayerBullet4.x > 0.0 )
    						+ 	float( gPlayerBullet5.x > 0.0 );

    if ( keyShoot && gPlayerWeapon.y > gPlayerWeapon.z && playerBulletNum < gPlayerWeapon.w && gPlayerState.x != STATE_UNDER_WATER )
    {
        gPlayerWeapon.y = 0.0;
        if ( gPlayerBullet0.x <= 0.0 )
        {
        	gPlayerBullet0.xy = playerWeapon;
            gPlayerBullet0.zw = normalize( gPlayerDir.xy );
        }
        else if ( gPlayerBullet1.x <= 0.0 )
        {
        	gPlayerBullet1.xy = playerWeapon;
            gPlayerBullet1.zw = normalize( gPlayerDir.xy );
        }
        else if ( gPlayerBullet2.x <= 0.0 )
        {
        	gPlayerBullet2.xy = playerWeapon;
            gPlayerBullet2.zw = normalize( gPlayerDir.xy );
        }     
        else if ( gPlayerBullet3.x <= 0.0 )
        {
        	gPlayerBullet3.xy = playerWeapon;
            gPlayerBullet3.zw = normalize( gPlayerDir.xy );
        }
        else if ( gPlayerBullet4.x <= 0.0 )
        {
        	gPlayerBullet4.xy = playerWeapon;
            gPlayerBullet4.zw = normalize( gPlayerDir.xy );
        }  
        else if ( gPlayerBullet5.x <= 0.0 )
        {
        	gPlayerBullet5.xy = playerWeapon;
            gPlayerBullet5.zw = normalize( gPlayerDir.xy );
        }          
    }
    
    UpdatePlayerBullet( gPlayerBullet0, screenWidth, screenHeight );
    UpdatePlayerBullet( gPlayerBullet1, screenWidth, screenHeight );
    UpdatePlayerBullet( gPlayerBullet2, screenWidth, screenHeight );
    UpdatePlayerBullet( gPlayerBullet3, screenWidth, screenHeight );
    UpdatePlayerBullet( gPlayerBullet4, screenWidth, screenHeight );
    UpdatePlayerBullet( gPlayerBullet5, screenWidth, screenHeight );    
    UpdateEnemyBullet( gEnemyBullet0, playerHitBox, screenWidth, screenHeight );
    UpdateEnemyBullet( gEnemyBullet1, playerHitBox, screenWidth, screenHeight );
    UpdateEnemyBullet( gEnemyBullet2, playerHitBox, screenWidth, screenHeight );
    UpdateEnemyBullet( gEnemyBullet3, playerHitBox, screenWidth, screenHeight );
    UpdateBossBullet( gBossBullet0, playerHitBox, screenWidth, screenHeight );
    UpdateBossBullet( gBossBullet1, playerHitBox, screenWidth, screenHeight );
    UpdateSoldier( gSoldier0, gSoldier0State, playerHitBox, screenWidth, screenHeight );
    UpdateSoldier( gSoldier1, gSoldier1State, playerHitBox, screenWidth, screenHeight );
    UpdateSoldier( gSoldier2, gSoldier2State, playerHitBox, screenWidth, screenHeight );

    PlayerBulletSoldierTest( gPlayerBullet0, gSoldier0 );
    PlayerBulletSoldierTest( gPlayerBullet1, gSoldier0 );
    PlayerBulletSoldierTest( gPlayerBullet2, gSoldier0 );
    PlayerBulletSoldierTest( gPlayerBullet3, gSoldier0 );
    PlayerBulletSoldierTest( gPlayerBullet4, gSoldier0 );
    PlayerBulletSoldierTest( gPlayerBullet5, gSoldier0 );    
    
    PlayerBulletSoldierTest( gPlayerBullet0, gSoldier1 );
    PlayerBulletSoldierTest( gPlayerBullet1, gSoldier1 );
    PlayerBulletSoldierTest( gPlayerBullet2, gSoldier1 );
    PlayerBulletSoldierTest( gPlayerBullet3, gSoldier1 );
    PlayerBulletSoldierTest( gPlayerBullet4, gSoldier1 );
    PlayerBulletSoldierTest( gPlayerBullet5, gSoldier1 );    
    
    PlayerBulletSoldierTest( gPlayerBullet0, gSoldier2 );
    PlayerBulletSoldierTest( gPlayerBullet1, gSoldier2 );
    PlayerBulletSoldierTest( gPlayerBullet2, gSoldier2 );
    PlayerBulletSoldierTest( gPlayerBullet3, gSoldier2 );
    PlayerBulletSoldierTest( gPlayerBullet4, gSoldier2 );
    PlayerBulletSoldierTest( gPlayerBullet5, gSoldier2 );    
    
    PlayerBulletSniperTest( gPlayerBullet0, gSniper );
    PlayerBulletSniperTest( gPlayerBullet1, gSniper );
    PlayerBulletSniperTest( gPlayerBullet2, gSniper );
    PlayerBulletSniperTest( gPlayerBullet3, gSniper );
    PlayerBulletSniperTest( gPlayerBullet4, gSniper );
    PlayerBulletSniperTest( gPlayerBullet5, gSniper );    
    
    PlayerBulletTurretTest( gPlayerBullet0, gTurret0, gTurret0State );
    PlayerBulletTurretTest( gPlayerBullet1, gTurret0, gTurret0State );
    PlayerBulletTurretTest( gPlayerBullet2, gTurret0, gTurret0State );
    PlayerBulletTurretTest( gPlayerBullet3, gTurret0, gTurret0State );
    PlayerBulletTurretTest( gPlayerBullet4, gTurret0, gTurret0State );
    PlayerBulletTurretTest( gPlayerBullet5, gTurret0, gTurret0State );    
    
    PlayerBulletTurretTest( gPlayerBullet0, gTurret1, gTurret1State );
    PlayerBulletTurretTest( gPlayerBullet1, gTurret1, gTurret1State );
    PlayerBulletTurretTest( gPlayerBullet2, gTurret1, gTurret1State );
    PlayerBulletTurretTest( gPlayerBullet3, gTurret1, gTurret1State );
    PlayerBulletTurretTest( gPlayerBullet4, gTurret1, gTurret1State );
    PlayerBulletTurretTest( gPlayerBullet5, gTurret1, gTurret1State );    
    
    PlayerBulletPowerUpTest( gPlayerBullet0 );
    PlayerBulletPowerUpTest( gPlayerBullet1 );
    PlayerBulletPowerUpTest( gPlayerBullet2 );
    PlayerBulletPowerUpTest( gPlayerBullet3 );
    PlayerBulletPowerUpTest( gPlayerBullet4 );
    PlayerBulletPowerUpTest( gPlayerBullet5 );    
    
    PlayerBulletBossCoreTest( gPlayerBullet0 );
    PlayerBulletBossCoreTest( gPlayerBullet1 );
    PlayerBulletBossCoreTest( gPlayerBullet2 );
    PlayerBulletBossCoreTest( gPlayerBullet3 );
    PlayerBulletBossCoreTest( gPlayerBullet4 );
    PlayerBulletBossCoreTest( gPlayerBullet5 );  
    
    PlayerBulletBossCannonTest( gPlayerBullet0, gBossCannon0 );
    PlayerBulletBossCannonTest( gPlayerBullet1, gBossCannon0 );
    PlayerBulletBossCannonTest( gPlayerBullet2, gBossCannon0 );
    PlayerBulletBossCannonTest( gPlayerBullet3, gBossCannon0 );
    PlayerBulletBossCannonTest( gPlayerBullet4, gBossCannon0 );
	PlayerBulletBossCannonTest( gPlayerBullet5, gBossCannon0 );  

    PlayerBulletBossCannonTest( gPlayerBullet0, gBossCannon1 );
    PlayerBulletBossCannonTest( gPlayerBullet1, gBossCannon1 );
    PlayerBulletBossCannonTest( gPlayerBullet2, gBossCannon1 );
    PlayerBulletBossCannonTest( gPlayerBullet3, gBossCannon1 );
    PlayerBulletBossCannonTest( gPlayerBullet4, gBossCannon1 );
	PlayerBulletBossCannonTest( gPlayerBullet5, gBossCannon1 );  	    
     
    
    // powerup state machine
	float powerUpSupport = GetSupport( gPowerUp.xy );    
    if ( gPowerUp.x > 0.0 )
    {
        if( gPowerUpState.x == STATE_RUN )
        {        
            gPowerUp.x += 2.0;
            gPowerUp.y = gPowerUpState.y + 32.0 * sin( 5.0 * iTime );
        }
        else if( gPowerUpState.x == STATE_JUMP )
        {
            gPowerUpState.z += 1.0 / 30.0;
            gPowerUp.x += 1.0;
            gPowerUp.y += 4.5 * ( 1.0 - gPowerUpState.z );
            if ( gPowerUpState.z > 1.0 && gPowerUp.y <= powerUpSupport )
            {
                if ( gPowerUp.y <= WATER_HEIGHT )
                {
                    gPowerUp.x = 0.0;
                    gExplosion = vec4( gPowerUp.xy + vec2( 0.0, POWER_UP_SIZE.y * 0.5 ), 0.0, 0.0 );
                }
                else
                {	
                    gPowerUp.y = powerUpSupport;
                	gPowerUpState.x = STATE_WATER;
                }
            } 
        }
        
        if ( gPowerUpState.x != STATE_RUN )
        {
            if ( Collide( gPlayer.xy, BILL_RUN_SIZE, gPowerUp.xy, POWER_UP_SIZE ) )
            {
                gPowerUp.x 		= 0.0;
				gPlayerWeapon 	= vec4( WEAPON_MACHINE_GUN, 0.0, MACHINE_GUN_FIRE_RATE, MACHINE_GUN_BULLET_NUM );
            }  
        }
    }
    
    // first exploding bridge
    if ( gPlayer.x > BRIDGE_0_START_TILE * 32.0 - 16.0 && gBridge.x == 0.0 )
    {
        gBridge.x 	= BRIDGE_0_START_TILE;
        gBridge.y 	= 0.0;
        gExplosion 	= vec4( gBridge.x * 32.0 + 16.0, 16.0 * 6.0, 0.0, 0.0 );
    }
    if ( gBridge.x > 0.0 && gBridge.x < BRIDGE_0_END_TILE - 1.0 )
    {
        ++gBridge.y;
        if ( gBridge.y > BRIGDE_EXPLODE_TIME )
        {
            ++gBridge.x;
            gBridge.y = 0.0;
            gExplosion = vec4( gBridge.x * 32.0 + 16.0, 16.0 * 6.0, 0.0, 0.0 );
        }
    }
    
    // second exploding bridge
    if ( gPlayer.x > BRIDGE_1_START_TILE * 32.0 - 16.0 && gBridge.x == BRIDGE_0_END_TILE - 1.0 )
    {
        gBridge.x 	= BRIDGE_1_START_TILE;
        gBridge.y 	= 0.0;
        gExplosion 	= vec4( gBridge.x * 32.0 + 16.0, 16.0 * 6.0, 0.0, 0.0 );
    }
    if ( gBridge.x >= BRIDGE_1_START_TILE - 1.0 && gBridge.x < BRIDGE_1_END_TILE - 1.0 )
    {
        ++gBridge.y;
        if ( gBridge.y > BRIGDE_EXPLODE_TIME )
        {
            ++gBridge.x;
            gBridge.y = 0.0;
            gExplosion = vec4( gBridge.x * 32.0 + 16.0, 16.0 * 6.0, 0.0, 0.0 );
        }
    }    
    
	UpdateSniper( gSniper, playerTarget );    
	UpdateTurret( gTurret0, gTurret0State, playerTarget );
    UpdateTurret( gTurret1, gTurret1State, playerTarget );
    UpdateBossCannon( gBossCannon0 );
    UpdateBossCannon( gBossCannon1 );
    
    // explosion
    if ( gExplosion.z >= 3.0 )
    {
        gExplosion.xy = vec2( 0.0 );
    }
    else
    {
        gExplosion.z += 0.2;
    }
    
    // hits
    if ( gHit.z >= 1.0 )
    {
		gHit.xy = vec2( 0.0 );
    }
    else
    {
        gHit.z += 0.2;
    }    
    
    fragColor = vec4( 0.0 );
    StoreValue( txPlayer, gPlayer, fragColor, fragCoord );
    StoreValue( txPlayerState, gPlayerState, fragColor, fragCoord );
    StoreValue( txPlayerWeapon, gPlayerWeapon, fragColor, fragCoord );
    StoreValue( txPlayerDir, gPlayerDir, fragColor, fragCoord );
    StoreValue( txCamera, gCamera, fragColor, fragCoord );
    StoreValue( txSoldier0, gSoldier0, fragColor, fragCoord );
    StoreValue( txSoldier1, gSoldier1, fragColor, fragCoord );
    StoreValue( txSoldier2, gSoldier2, fragColor, fragCoord );
    StoreValue( txSoldier0State, gSoldier0State, fragColor, fragCoord );
    StoreValue( txSoldier1State, gSoldier1State, fragColor, fragCoord );
    StoreValue( txSoldier2State, gSoldier2State, fragColor, fragCoord );
    StoreValue( txSniper, gSniper, fragColor, fragCoord );
    StoreValue( txPlayerBullet0, gPlayerBullet0, fragColor, fragCoord );
    StoreValue( txPlayerBullet1, gPlayerBullet1, fragColor, fragCoord );
    StoreValue( txPlayerBullet2, gPlayerBullet2, fragColor, fragCoord );
    StoreValue( txPlayerBullet3, gPlayerBullet3, fragColor, fragCoord );
    StoreValue( txPlayerBullet4, gPlayerBullet4, fragColor, fragCoord );
    StoreValue( txPlayerBullet5, gPlayerBullet5, fragColor, fragCoord );    
    StoreValue( txEnemyBullet0, gEnemyBullet0, fragColor, fragCoord );
    StoreValue( txEnemyBullet1, gEnemyBullet1, fragColor, fragCoord );
    StoreValue( txEnemyBullet2, gEnemyBullet2, fragColor, fragCoord );
    StoreValue( txEnemyBullet3, gEnemyBullet3, fragColor, fragCoord );
    StoreValue( txExplosion, gExplosion, fragColor, fragCoord );
    StoreValue( txHit, gHit, fragColor, fragCoord );
    StoreValue( txTurret0, gTurret0, fragColor, fragCoord );
    StoreValue( txTurret1, gTurret1, fragColor, fragCoord );
    StoreValue( txTurret0State, gTurret0State, fragColor, fragCoord );
    StoreValue( txTurret1State, gTurret1State, fragColor, fragCoord );    
    StoreValue( txPowerUp, gPowerUp, fragColor, fragCoord );
    StoreValue( txPowerUpState, gPowerUpState, fragColor, fragCoord );
    StoreValue( txBossCore, gBossCore, fragColor, fragCoord );
    StoreValue( txBossCannon0, gBossCannon0, fragColor, fragCoord );
    StoreValue( txBossCannon1, gBossCannon1, fragColor, fragCoord );
    StoreValue( txBossBullet0, gBossBullet0, fragColor, fragCoord );
    StoreValue( txBossBullet1, gBossBullet1, fragColor, fragCoord );    
    StoreValue( txGameState, gGameState, fragColor, fragCoord );
    StoreValue( txBridge, gBridge, fragColor, fragCoord );
    
    // clear to 0 on first frame
    fragColor = iFrame < 1 ? vec4( 0.0 ) : fragColor;
}