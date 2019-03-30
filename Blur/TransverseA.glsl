// https://www.shadertoy.com/view/4tlyD8
/*
	Simple grid for testing
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float foo = mod(fragCoord.x, 10.0) < 2.0 || mod(fragCoord.y, 10.0) < 2.0 ? 0.4 : 0.0;
    foo += mod(fragCoord.x, 10.0) < 2.0 && mod(fragCoord.y, 10.0) < 2.0 ? 0.6 : 0.0;
    
    fragColor = vec4(foo , foo , foo, 1.0);
}
