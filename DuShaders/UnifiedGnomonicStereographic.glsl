/** 
 * Cubemap to Stereographic / Gnomonic / Rectilinear / Equirectangular unwrapping by Ruofei Du (DuRuofei.com)
 * Link to demo: https://www.shadertoy.com/view/ldBczm
 * starea @ ShaderToy, License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
 * https://creativecommons.org/licenses/by-nc-sa/3.0/
 * 
 * The conversions to stereographic and gnomonic projection are very similar, so I merged them together.
 * One intuition is both of the projections use spherical lens.
 * The only difference is written in line 50. 
 * Hopefully my commented code is useful for your research & fun! Please comment if you used it for your works :-)
 *
 * Interaction:
 * Click and move your cursor to alter the central point.
 * Press space to compare the gnomonic projection.
 * Press enter for the equirectangular projection. 
 * Press 1 for zooming in, which creates a very similar effect as reference [6], if you click the center.
 * Press 2 for zooming out, creating the "little planet" effect in photography.
 * Press 3 for a slight fish-eye lens.
 *
 * Reference: 
 * [1] Stereographic projection: https://en.wikipedia.org/wiki/Stereographic_projection
 * [2] Weisstein, Eric W. "Stereographic Projection." From MathWorld--A Wolfram Web Resource. http://mathworld.wolfram.com/StereographicProjection.html
 * [3] Gnomonic projection: https://en.wikipedia.org/wiki/Gnomonic_projection
 * [4] Weisstein, Eric W. "Gnomonic Projection." From MathWorld--A Wolfram Web Resource. http://mathworld.wolfram.com/GnomonicProjection.html
 * [5] Equirectangular projection. https://en.wikipedia.org/wiki/Equirectangular_projection
 * [6] Bourke, Paul. "Using a spherical mirror for projection into immersive environments." SIGGRAPH Asia 2005.
 *     http://paulbourke.net/papers/graphite2005/graphite.pdf
 * [7] Little Planet. https://en.wikipedia.org/wiki/Little_planet
 *
 * My related ShaderToy project:
 * [1] starea. Cubemap to Gnomonic Projection. https://www.shadertoy.com/view/4sjcz1
 *
 * Similar projects in ShaderToy
 * [1] hornet. Projection: Stereographic. https://www.shadertoy.com/view/Xsl3D2
 *
 * [1]'s code is super efficient since it uses the Cartesian coordinates from Wikipedia, 
 * but it defines the line intersects the plane z = 0, thus not allowing varying central point.
 *
 * Last updated: 4/4/2017
 *
 **/
const float PI = 3.1415926536;
const float PI_2 = PI * 0.5; 
const float PI2 = PI * 2.0; 
const int KEY_SPACE = 32;
const int KEY_ENTER = 13;
const int KEY_1 = 49;
const int KEY_2 = 50;
const int KEY_3 = 51; 

float localRadius = 0.15; 

// Forked from fb39ca4's keycode viewer tool @ https://www.shadertoy.com/view/4tt3Wn
float keyPressed(int keyCode) {
	return texture(iChannel1, vec2((float(keyCode) + 0.5) / 256., .5/3.)).r;   
}

// Main function, convert screen coordinate system to spherical coordinates in stereographic / gnomonic projection
// screenCoord: [0, 1], centralPoint: [0, 1], FoVScale: vec2(0.9, 0.2) recommended, localRadius
vec2 calcSphericalCoordsFromProjections(in vec2 screenCoord, in vec2 centralPoint, in vec2 FoVScale, in bool stereographic) {
    vec2 cp = (centralPoint * 2.0 - 1.0) * vec2(PI, PI_2);  // [-PI, PI], [-PI_2, PI_2]
    
    // Convert screen coord in gnomonic mapping to spherical coord in [PI, PI/2]
    vec2 convertedScreenCoord = (screenCoord * 2.0 - 1.0) * FoVScale * vec2(PI, PI_2); 
    float x = convertedScreenCoord.x, y = convertedScreenCoord.y;
    
    float rou = sqrt(x * x + y * y), c = stereographic ? 2.0 * atan(rou / localRadius / 2.0) : atan(rou); 
	float sin_c = sin( c ), cos_c = cos( c );  
    
    float lat = asin(cos_c * sin(cp.y) + (y * sin_c * cos(cp.y)) / rou);
	float lon = cp.x + atan(x * sin_c, rou * cos(cp.y) * cos_c - y * sin(cp.y) * sin_c);
    
	lat = (lat / PI_2 + 1.0) * 0.5; lon = (lon / PI + 1.0) * 0.5; //[0, 1]

    // uncomment the following if centralPoint ranges out of [0, PI/2] [0, PI]
	// while (lon > 1.0) lon -= 1.0; while (lon < 0.0) lon += 1.0;
	// while (lat > 1.0) lat -= 1.0; while (lat < 0.0) lat += 1.0;
    
    // convert spherical coord to cubemap coord
   return (bool(keyPressed(KEY_ENTER)) ? screenCoord : vec2(lon, lat)) * vec2(PI2, PI);
}

vec2 calcSphericalCoordsInStereographicProjection(in vec2 screenCoord, in vec2 centralPoint, in vec2 FoVScale) {
	return calcSphericalCoordsFromProjections(screenCoord, centralPoint, FoVScale, true); 
}

vec2 calcSphericalCoordsInGnomonicProjection(in vec2 screenCoord, in vec2 centralPoint, in vec2 FoVScale) {
	return calcSphericalCoordsFromProjections(screenCoord, centralPoint, FoVScale, false); 
}

// convert cubemap coordinates to spherical coordinates: 
vec3 sphericalToCubemap(in vec2 sph) {
    return vec3(sin(sph.y) * sin(sph.x), cos(sph.y), sin(sph.y) * cos(sph.x));
}
    
// convert screen coordinate system to cube map coordinates in rectilinear projection
vec3 calcCubeCoordsInGnomonicProjection(in vec2 screenCoord, in vec2 centralPoint, in vec2 FoVScale) {
	return sphericalToCubemap( calcSphericalCoordsInGnomonicProjection(screenCoord, centralPoint, FoVScale) );
}

vec3 calcCubeCoordsInStereographicProjection(in vec2 screenCoord, in vec2 centralPoint, in vec2 FoVScale) {
	return sphericalToCubemap( calcSphericalCoordsInStereographicProjection(screenCoord, centralPoint, FoVScale) );
}

// the inverse function of calcSphericalCoordsInGnomonicProjection()
vec2 calcEquirectangularFromGnomonicProjection(in vec2 sph, in vec2 centralPoint) {
    vec2 cp = (centralPoint * 2.0 - 1.0) * vec2(PI, PI_2);
	float cos_c = sin(cp.y) * sin(sph.y) + cos(cp.y) * cos(sph.y) * cos(sph.y - cp.y);
    float x = cos(sph.y) * sin(sph.y - cp.y) / cos_c;
    float y = ( cos(cp.y) * sin(sph.y) - sin(cp.y) * cos(sph.y) * cos(sph.y - cp.y) ) / cos_c; 
    return vec2(x, y) + vec2(PI, PI_2); 
}

// Forked from: https://www.shadertoy.com/view/MsXGz4, press enter for comparison
vec3 iqCubemap(in vec2 q, in vec2 mo) {
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x / iResolution.y;
	
    // camera
	float an1 = -6.2831 * (mo.x + 0.25);
	float an2 = clamp( (1.0-mo.y) * 2.0, 0.0, 2.0 );
    vec3 ro = 2.5 * normalize(vec3(sin(an2)*cos(an1), cos(an2)-0.5, sin(an2)*sin(an1)));
    vec3 ww = normalize(vec3(0.0, 0.0, 0.0) - ro);
    vec3 uu = normalize(cross( vec3(0.0, -1.0, 0.0), ww ));
    vec3 vv = normalize(cross(ww, uu));
    return normalize( p.x * uu + p.y * vv + 1.4 * ww );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 q = fragCoord.xy / iResolution.xy;
    
	// Modify this to adjust the field of view
    vec2 FoVScale = vec2(0.5, 0.5); 
    if (bool(keyPressed(KEY_1))) {
        FoVScale = vec2(0.5, 0.5) * 0.5; 
    } else if (bool(keyPressed(KEY_2))) {
        FoVScale = vec2(0.5, 0.5) * 2.0; 
    } else if (bool(keyPressed(KEY_3))) {
        FoVScale = vec2(0.5, 0.5) * 3.0; 
        localRadius = 3.0; 
    } 
         
    // central / foveated point, iMouse.xy corresponds to longitude and latitude 
    vec2 centralPoint = iMouse.xy / iResolution.xy;
    
    // press enter to compare with recilinear projection
    vec3 dir = bool(keyPressed(KEY_SPACE))
        ? calcCubeCoordsInGnomonicProjection(q, centralPoint, FoVScale) 
        : calcCubeCoordsInStereographicProjection(q, centralPoint, FoVScale);
    
	vec3 col = texture(iChannel0, dir).rgb;
    
    // test if the inverse function works correctly by pressing z
    if (bool(keyPressed(90))) {
    	vec2 sph = calcSphericalCoordsInGnomonicProjection(q, centralPoint, FoVScale);    
        sph = calcEquirectangularFromGnomonicProjection(sph, centralPoint);
        col = vec3(sph / vec2(PI2, PI), 0.5); 
    }
    
    col *= 0.25 + 0.75 * pow( 16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.15 );

    fragColor = vec4(col, 1.0);
}