// https://www.shadertoy.com/view/llsfDS
// variant of https://shadertoy.com/view/XstXzs   + map: https://www.shadertoy.com/view/XdcGWr
// variant of https://www.shadertoy.com/view/XsdXRl

void mainImage( out vec4 O, vec2 U )
{ 	U = 2.2 * U/iResolution.y - 1.1;
    U.x = acos( U.x / cos( U.y = asin(U.y) )) - iTime;

    O = texture(iChannel0,U/4.).grba;
    O += vec4( 2.*O.r - O.b, O.rba );
	O = smoothstep(0., .7, .5*O*O*O) + 1./U.x;
}
