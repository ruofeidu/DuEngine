
vec2 barrelDistortion(vec2 coord, float amt) {
	vec2 cc = coord - 0.5;
	float dist = dot(cc, cc);
	//return coord + cc * (dist*dist)  * amt;
	return coord + cc * dist * amt;

    }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	//vec2 uv=(fragCoord.xy/iResolution.xy);

	vec2 uv=(fragCoord.xy/iResolution.xy*.5)+.25;
	//uv.y +=.1;
	vec4 a1=texture(iChannel0, barrelDistortion(uv,0.0));
	vec4 a2=texture(iChannel0, barrelDistortion(uv,0.2));
	vec4 a3=texture(iChannel0, barrelDistortion(uv,0.4));
	vec4 a4=texture(iChannel0, barrelDistortion(uv,0.6));
	
	vec4 a5=texture(iChannel0, barrelDistortion(uv,0.8));
	vec4 a6=texture(iChannel0, barrelDistortion(uv,1.0));
	vec4 a7=texture(iChannel0, barrelDistortion(uv,1.2));
	vec4 a8=texture(iChannel0, barrelDistortion(uv,1.4));
	
	vec4 a9=texture(iChannel0, barrelDistortion(uv,1.6));
	vec4 a10=texture(iChannel0, barrelDistortion(uv,1.8));
	vec4 a11=texture(iChannel0, barrelDistortion(uv,2.0));
	vec4 a12=texture(iChannel0, barrelDistortion(uv,2.2));

	vec4 tx=(a1+a2+a3+a4+a5+a6+a7+a8+a9+a10+a11+a12)/12.;
	fragColor = vec4(tx.rgb,1.);
}
