// MdGfzh
// Himalayas. Created by Reinder Nijhoff 2018
// @reindernijhoff
//
// https://www.shadertoy.com/view/MdGfzh
//
// This is my first attempt to render volumetric clouds in a fragment shader.
//
//
// To create an interesting scene and to add some scale to the clouds, I render a 
// terrain using a simple heightmap, based on the work by Íñigo Quílez on value noise and its 
// analytical derivatives.[3]
//
// In fact, the heightmap of this shader is almost exactly the same as the heightmap that 
// is used in Íñigo Quílez' shader Elevated:
//
// https://www.shadertoy.com/view/MdX3Rr
//
// To reduce noise I use temporal reprojection (both for clouds (Buffer D) and the terrain 
// (Buffer C)) separatly. The temporal reprojection code is based on code from the shader
// "Rain Forest" (again by Íñigo Quílez):
//
// https://www.shadertoy.com/view/4ttSWf
// 
vec3 noised( in vec2 x ) {
    vec2 f = fract(x);
    vec2 u = f*f*(3.0-2.0*f);
    
    vec2 p = vec2(floor(x));
    float a = hash12( (p+vec2(0,0)) );
	float b = hash12( (p+vec2(1,0)) );
	float c = hash12( (p+vec2(0,1)) );
	float d = hash12( (p+vec2(1,1)) );
    
	return vec3(a+(b-a)*u.x+(c-a)*u.y+(a-b-c+d)*u.x*u.y,
				6.0*f*(1.0-f)*(vec2(b-a,c-a)+(a-b-c+d)*u.yx));
}

const mat2 m2 = mat2(1.6,-1.2,1.2,1.6);

float terrainMap( in vec2 x, const int OCTAVES ) {
	vec2 p = x*(MOUNTAIN_HW_RATIO*SCENE_SCALE);
    float s = mix(1., smoothstep(.0,.4, abs(p.y)), .75);
    
    float a = 0.;
    float b = 1.;
	vec2  d = vec2(0.0);
    for( int i=0; i<OCTAVES; i++ ) {
        vec3 n = noised(p);
        d += n.yz;
        a += b*n.x/(1.0+dot(d,d));
		b *= 0.5;
        p = m2*p;
    }
	return s*a*(MOUNTAIN_HEIGHT*INV_SCENE_SCALE*.5);
}

vec3 calcNormal( in vec3 pos, float t, const int OCTAVES ) {
    vec2  eps = vec2( 0.0015*t, 0.0 );
    return normalize( vec3( terrainMap(pos.xz-eps.xy, OCTAVES) - terrainMap(pos.xz+eps.xy, OCTAVES),
                            2.0*eps.x,
                            terrainMap(pos.xz-eps.yx, OCTAVES) - terrainMap(pos.xz+eps.yx, OCTAVES) ) );
}

vec4 render( in vec3 ro, in vec3 rd ) {
	vec3 col, bgcol;
    
    float tmax = 100000.;
    // bouding top plane
    float topd = ((MOUNTAIN_HEIGHT*INV_SCENE_SCALE)-ro.y)/rd.y;
    if( topd>0.0 ) {
        tmax = min( tmax, topd );
    }
    
    // intersect with heightmap
    float t = 1.;
	for( int i=0; i<128; i++ ) {
        vec3 pos = ro + t*rd;
		float h = pos.y - terrainMap( pos.xz, 7 );
        if(abs(h)<(0.003*t) || t>tmax ) break; // use abs(h) to bounce back if under terrain
	    t += .8 * h;
	}
   	
    bgcol = col = getSkyColor(rd);
	if( t<tmax) {
		vec3 pos = ro + t*rd;
        vec3 nor = calcNormal( pos, t, 15 );
           
        // terrain color - just back and white
        float s = smoothstep(0.5,0.9,dot(nor, vec3(.3,1.,0.05)));
        col = mix( vec3(.01), vec3(0.5,0.52,0.6), smoothstep(.1,.7,s ));
		
        // lighting	
        // shadow is calculated based on the slope of a low frequency version of the heightmap
        float shadow = .5 + clamp( -8.+ 16.*dot(SUN_DIR, calcNormal(pos, t, 5)), 0.0, .5 );
        shadow *= smoothstep(20.,80.,pos.y);
        
        float ao = terrainMap(pos.xz, 10)-terrainMap(pos.xz,7);
        ao = clamp(.25 + ao / (MOUNTAIN_HEIGHT*INV_SCENE_SCALE) * 200., 0., 1.);

        float ambient  = max(0.5+0.5*nor.y,0.0);
		float diffuse  = max(dot(SUN_DIR, nor), 0.0);
		float backlight = max(0.5 + 0.5*dot( normalize( vec3(-SUN_DIR.x, 0., SUN_DIR.z)), nor), 0.0);
	 	
        //
        // use a 3-light setup as described by Íñigo Quílez
        // http://iquilezles.org/www/articles/outdoorslighting/outdoorslighting.htm
        //
		vec3 lin = (diffuse*shadow*3.) * SUN_COLOR;
		lin += (ao*ambient)*vec3(0.40,0.60,1.00);
        lin += (backlight)*vec3(0.40,0.50,0.60);
		col *= lin;
        col *= (.6+.4*smoothstep(400.,100.,pos.z)); // dark in the distance
    
        // height based fog, see http://iquilezles.org/www/articles/fog/fog.htm
        float fogAmount = HEIGHT_BASED_FOG_C * (1.-exp( -t*rd.y*HEIGHT_BASED_FOG_B))/rd.y;
        col = mix( col, bgcol, fogAmount);
    } else {
        t = 1000000.;
    }

	return vec4( col, t );
}


bool resolutionChanged() {
    return floor(texelFetch(iChannel1, ivec2(0), 0).r) != floor(iResolution.x);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    if( letterBox(fragCoord, iResolution.xy, 2.25) ) {
        fragColor = vec4( 0., 0., 0., 1. );
        return;
    } else {
        vec3 ro, rd;
        vec2 o = hash33( vec3(fragCoord,iFrame) ).xy - 0.5; // dither
        getRay( iTime, (fragCoord+o), iResolution.xy, ro, rd);

        vec4 res = render( ro, rd );

        vec2 spos = reprojectPos(ro+rd*res.w, iResolution.xy, iChannel1);
        spos -= o/iResolution.xy; // undo dither
        
        vec2 rpos = spos * iResolution.xy;
        
        if( !letterBox(rpos.xy, iResolution.xy, 2.3) && !resolutionChanged()) {
            vec4 ocol = texture( iChannel0, spos, 0.0 );
            res.rgb = mix( ocol.rgb, res.rgb, 0.1);
        }

        fragColor = res;
    }
}
