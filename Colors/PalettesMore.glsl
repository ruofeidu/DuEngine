// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// A simple way to create color variation in a cheap way (yes, trigonometrics ARE cheap
// in the GPU, don't try to be smart and use a triangle wave instead).

// See http://iquilezles.org/www/articles/palettes/palettes.htm for more information


vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float bands = 11.0;
    
    float curr = bands;

	vec2 p = fragCoord.xy / iResolution.xy;
    
    // animate
    //p.x += 0.01*iTime;
    
    // Vec1 -> Brightness
    // Vec2 -> Saturation
    // Vec3 -> Size of interval (if all components equal)
    // Vec4 -> Style of interval (components) 
    // 			& position on interval (if adding single float)
    
    // compute colors
    vec3 col = vec3(0);
    if( p.y>((curr -= 1.0)/bands) ) { // Rainbow (orig)
        col=pal(p.x,vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(0.8,0.8,0.8),vec3(0.0,0.33,0.67)+0.21);
    } else if( p.y > ((curr -= 1.0)/bands) ) { // Rainbow (more yellow, narrower green, deeper red)
        col=pal(p.x,vec3(0.55,0.4,0.3),vec3(0.50,0.51,0.35)+0.1,vec3(0.8,0.75,0.8),vec3(0.075,0.33,0.67)+0.21);
    } else if( p.y > ((curr -= 1.0)/bands) ) { // Black -> Blue -> White (cooler)
        col=pal(p.x,vec3(0.55),vec3(0.8),vec3(0.29),vec3(0.00,0.05,0.15) + 0.54 );
    } else if( p.y > ((curr -= 1.0)/bands) ) { // Black -> Blue -> White (warmer)
        col=pal(p.x,vec3(0.5),vec3(0.55),vec3(0.45),vec3(0.00,0.10,0.20) + 0.47 );
    } else if( p.y > ((curr -= 1.0)/bands) ) {
        col=pal(p.x,vec3(0.5),vec3(0.5),vec3(0.9),vec3(0.3,0.20,0.20) + 0.31 );
    } else if( p.y > ((curr -= 1.0)/bands) ) {
        col=pal(p.x,vec3(0.5),vec3(0.5),vec3(0.9),vec3(0.0,0.10,0.20) + 0.47 );
    } else if( p.y > ((curr -= 1.0)/bands) ) {
        col=pal(p.x,vec3(0.5),vec3(0.5),vec3(1.0,1.0,0.5),vec3(0.8,0.90,0.30) );
    } else if( p.y > ((curr -= 1.0)/bands) ) {
        col=pal(p.x,vec3(0.5),vec3(0.5),vec3(1.0,0.7,0.4),vec3(0.0,0.15,0.20) );
    } else if( p.y > ((curr -= 1.0)/bands) ) {
        col=pal(p.x,vec3(0.5),vec3(0.5),vec3(2.0,1.0,0.0),vec3(0.5,0.20,0.25) );
    } else if( p.y > ((curr -= 1.0)/bands) ) {
        col=pal(p.x,vec3(0.5),vec3(0.5),vec3(1),vec3(0.0,0.33,0.67));
    } else if( p.y > ((curr -= 1.0)/bands) ) {
        col=pal(p.x,vec3(0.8,0.5,0.4),vec3(0.2,0.4,0.2),vec3(2.0,1.0,1.0),vec3(0.0,0.25,0.25) );
    }

    // band
    float f = fract(p.y*bands);
    // borders
    col *= smoothstep( 0.49, 0.47, abs(f-0.5) );
    // shadowing
    col *= 0.5 + 0.5*sqrt(4.0*f*(1.0-f));

	fragColor = vec4( col, 1.0 );
}
