// 4sf3Rn
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec3 doit( in vec2 pix )
{
    vec2 p = -1.0 + 2.0*pix;
    p.x *= iResolution.x/iResolution.y;

    vec3 ro = vec3( 0.0, 0.0, 2.5 );
    vec3 rd = normalize( vec3( p, -2.0 ) );

    vec3 col = vec3(0.1);

    // intersect sphere
    float b = dot(ro,rd);
    float c = dot(ro,ro) - 1.0;
    float h = b*b - c;
    if( h>0.0 )
    {
        float t = -b - sqrt(h);
        vec3 pos = ro + t*rd;
        vec3 nor = pos;

        // texture mapping
        vec2 uv;
        uv.x = atan(nor.x,nor.z)/6.2831 - 0.03*iTime - iMouse.x/iResolution.x;
        uv.y = acos(nor.y)/3.1416;
		uv.y *= 0.5;

        col = vec3(0.2,0.3,0.4);
        vec3 te  = 1.0*texture( iChannel1, 0.5*uv.yx ).xyz;
             te += 0.3*texture( iChannel1, 2.5*uv.yx ).xyz;
		col = mix( col, (vec3(0.2,0.5,0.1)*0.55 + 0.45*te + 0.5*texture( iChannel0, 15.5*uv.yx ).xyz)*0.4, smoothstep( 0.45,0.5,te.x) );

        vec3 cl = texture( iChannel0, 2.0*uv ).xxx;
		col = mix( col, vec3(0.9), 0.75*smoothstep( 0.55,0.8,cl.x) );
	
        // lighting
        float dif = max(nor.x*2.0+nor.z,0.0);
        float fre = 1.0-clamp(nor.z,0.0,1.0);
        float spe = clamp( dot( nor,normalize(vec3(0.4,0.3,1.0)) ), 0.0, 1.0 );
        col *= 0.03 + 0.75*dif;
        col += pow(spe,64.0)*(1.0-te.x);
        col += mix( vec3(0.20,0.10,0.05), vec3(0.4,0.7,1.0), dif )*0.3*fre;
        col += mix( vec3(0.10,0.10,0.10), vec3(0.7,0.9,1.0), dif )*7.0*fre*fre*fre*fre;
    }
	else
	{
		c = dot(ro,ro) - 10.0;
		h = b*b - c;
        float t = -b - sqrt(h);
        vec3 pos = ro + t*rd;
        vec3 nor = pos;

        vec2 uv;
        uv.x = 16.0*atan(nor.x,nor.z)/6.2831 - 0.05*iTime - iMouse.x/iResolution.x;
        uv.y = 2.0*acos(nor.y)/3.1416;
        col = texture( iChannel0, uv, 1.0 ).zyx;
		col = col*col*col;
        col *= 0.15;
        vec3 sta = texture( iChannel0, 0.5*uv, 4.0 ).yzx;
		col += pow(sta, vec3(8.0))*1.3;

	}
	
    col = 0.5*(col+sqrt(col));
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // render this with four sampels per pixel
    vec3 col0 = doit( (fragCoord.xy+vec2(0.0,0.0) )/iResolution.xy );
    vec3 col1 = doit( (fragCoord.xy+vec2(0.5,0.0) )/iResolution.xy );
    vec3 col2 = doit( (fragCoord.xy+vec2(0.0,0.5) )/iResolution.xy );
    vec3 col3 = doit( (fragCoord.xy+vec2(0.5,0.5) )/iResolution.xy );
    vec3 col = 0.25*(col0 + col1 + col2 + col3);

    fragColor = vec4(col,1.0);
}