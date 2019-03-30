#define iChannelKeyboard iChannel1

#define FLY_CAM_INVERT_Y 1

//    _____ _          ____                
//   |  ___| |_   _   / ___|__ _ _ __ ___  
//   | |_  | | | | | | |   / _` | '_ ` _ \ 
//   |  _| | | |_| | | |__| (_| | | | | | |
//   |_|   |_|\__, |  \____\__,_|_| |_| |_|
//            |___/                        
//

struct FlyCamState
{
    vec3 vPos;
    vec3 vAngles;
    vec4 vPrevMouse;
};

void FlyCam_LoadState( out FlyCamState flyCam, sampler2D sampler, ivec2 addr )
{
    vec4 vPos = LoadVec4( sampler, addr + ivec2(0,0) );
    flyCam.vPos = vPos.xyz;
    vec4 vAngles = LoadVec4( sampler, addr + ivec2(1,0) );
    flyCam.vAngles = vAngles.xyz;
    vec4 vPrevMouse = LoadVec4( sampler, addr + ivec2(2,0) );    
    flyCam.vPrevMouse = vPrevMouse;
}

void FlyCam_StoreState( ivec2 addr, const in FlyCamState flyCam, inout vec4 fragColor, in ivec2 fragCoord )
{
    StoreVec4( addr + ivec2(0,0), vec4( flyCam.vPos, 0 ), fragColor, fragCoord );
    StoreVec4( addr + ivec2(1,0), vec4( flyCam.vAngles, 0 ), fragColor, fragCoord );
    StoreVec4( addr + ivec2(2,0), vec4( iMouse ), fragColor, fragCoord );
}

void FlyCam_GetAxes( FlyCamState flyCam, out vec3 vRight, out vec3 vUp, out vec3 vForwards )
{
    vec3 vAngles = flyCam.vAngles;
    mat3 rotX = mat3(1.0, 0.0, 0.0, 
                     0.0, cos(vAngles.x), sin(vAngles.x), 
                     0.0, -sin(vAngles.x), cos(vAngles.x));
    
    mat3 rotY = mat3(cos(vAngles.y), 0.0, -sin(vAngles.y), 
                     0.0, 1.0, 0.0, 
                     sin(vAngles.y), 0.0, cos(vAngles.y));    

    mat3 rotZ = mat3(cos(vAngles.z), sin(vAngles.z), 0.0,
                     -sin(vAngles.z), cos(vAngles.z), 0.0,
                     0.0, 0.0, 1.0 );
    
    
    mat3 m = rotY * rotX * rotZ;
    
    vRight = m[0];
    vUp = m[1];
    vForwards = m[2];
}

bool FlyCam_Update( inout FlyCamState flyCam, vec3 vStartPos, vec3 vStartAngles )
{   
    bool bMoving = false;
    //float fMoveSpeed = 0.01;
    float fMoveSpeed = iTimeDelta * 0.5;
    float fRotateSpeed = 3.0;
    
    if ( Key_IsPressed( iChannelKeyboard, KEY_SHIFT ) )
    {
        fMoveSpeed *= 4.0;
    }
    
    if ( iFrame == 0 )
    {
        flyCam.vPos = vStartPos;
        flyCam.vAngles = vStartAngles;
        flyCam.vPrevMouse = iMouse;
    }
      
    vec3 vMove = vec3(0.0);
        
    if ( Key_IsPressed( iChannelKeyboard, KEY_W ) )
    {
        vMove.z += fMoveSpeed;
        bMoving = true;
    }
    if ( Key_IsPressed( iChannelKeyboard, KEY_S ) )
    {
        vMove.z -= fMoveSpeed;
        bMoving = true;
    }

    if ( Key_IsPressed( iChannelKeyboard, KEY_A ) )
    {
        vMove.x -= fMoveSpeed;
        bMoving = true;
    }
    if ( Key_IsPressed( iChannelKeyboard, KEY_D ) )
    {
        vMove.x += fMoveSpeed;
        bMoving = true;
    }
    
    vec3 vForwards, vRight, vUp;
    FlyCam_GetAxes( flyCam, vRight, vUp, vForwards );
        
    flyCam.vPos += vRight * vMove.x + vForwards * vMove.z;
    
    vec3 vRotate = vec3(0);
    
    bool bMouseDown = iMouse.z > 0.0;
    bool bMouseWasDown = flyCam.vPrevMouse.z > 0.0;
    
    if ( bMouseDown && bMouseWasDown )
    {
    	vRotate.yx += ((iMouse.xy - flyCam.vPrevMouse.xy) / iResolution.xy) * fRotateSpeed;
        
        if( length(vRotate.yx) > 0.0 )
        {
        	bMoving = true;
        }
    }
    
#if FLY_CAM_INVERT_Y    
    vRotate.x *= -1.0;
#endif    
    
    if ( Key_IsPressed( iChannelKeyboard, KEY_E ) )
    {
        vRotate.z -= fRotateSpeed * 0.01;
        bMoving = true;
    }
    if ( Key_IsPressed( iChannelKeyboard, KEY_Q ) )
    {
        vRotate.z += fRotateSpeed * 0.01;
        bMoving = true;
    }
        
	flyCam.vAngles += vRotate;
    
    flyCam.vAngles.x = clamp( flyCam.vAngles.x, -PI * .5, PI * .5 );
    
    return bMoving;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    FlyCamState flyCam;
    FlyCam_LoadState( flyCam, iChannel0, ivec2(4, 0));
    
    vec4 vPrevResolution = texelFetch( iChannel0, ivec2(7,0), 0);

    float fPathCount = vPrevResolution.z;
    if ( iTimeDelta < 1.0 / 50.0 )
    {
        fPathCount += 1.0;
    }
	else
    if ( iTimeDelta > 1.0 / 60.0 )
	{
        fPathCount -= 1.0;
	}
    
    fPathCount = clamp( fPathCount, 1.0, 30.0 );

    fragColor = vec4(0.0,0.0,1.0,1.0);

    if ( fragCoord.x > 8.0 || fragCoord.y > 2.0 )
    {
        discard;
    }
    
    vec3 vStartPos = vec3( 5, 3.0, -7 );
    vec3 vStartAngles = vec3( 0.2, -0.5, 0 );
    
    bool bMoving = FlyCam_Update( flyCam, vStartPos, vStartAngles );
    
    CameraState cam;
	Cam_LoadState( cam, iChannel0, ivec2(0) );
    
#if 0
    {
        float fDist = 0.01 + 3.0 * (iMouse.y / iResolution.y);

        float fAngle = (iMouse.x / iResolution.x) * radians(360.0);
    	//float fElevation = (iMouse.y / iResolution.y) * radians(90.0);
    	float fElevation = 0.15f * radians(90.0);    

        if ( iMouse.z <= 0.0 )
        {
            fDist = 2.0;
            fAngle = 3.5f;
            fElevation = 0.2f;
        }
        
        cam.vPos = vec3(sin(fAngle) * fDist * cos(fElevation),sin(fElevation) * fDist,cos(fAngle) * fDist * cos(fElevation));
        cam.vTarget = vec3(0,0.05,0.0);
        cam.vPos +=cam.vTarget;
        cam.fFov = 20.0 / (1.0 + fDist * 0.5);
        cam.vUp = vec3(0,1,0);
    	vec3 vFocus = vec3(0,0.05,0.0);	    
	    cam.fPlaneInFocus = length( vFocus - cam.vPos );
    }
#endif    
    
    vec3 vForwards, vRight, vUp;
    FlyCam_GetAxes( flyCam, vRight, vUp, vForwards );
    
    cam.vPos = flyCam.vPos;
    cam.vTarget = flyCam.vPos + vForwards;
    cam.vUp = vUp;
    cam.fFov = 25.0;
    cam.fPlaneInFocus = 5.0;    
    
    cam.bStationary = !bMoving;
    
    if ( any(notEqual(iResolution.xy, vPrevResolution.xy)))
    {
        cam.bStationary = false;
    }
    
    Cam_StoreState( ivec2(0), cam, fragColor, ivec2(fragCoord.xy) );   
    FlyCam_StoreState( ivec2(4,0), flyCam, fragColor, ivec2(fragCoord));    
    if ( all(equal(ivec2(fragCoord.xy), ivec2(7,0))))
    {
        fragColor.xyz = vec3(iResolution.xy, fPathCount);
    }
}
