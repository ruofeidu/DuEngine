// https://www.shadertoy.com/view/https://www.shadertoy.com/view/MtcSzH
// continuous gradient
// https://www.shadertoy.com/view/XtK3Dd
#define GRADIENT_RADIUS (8)
#define PI           (3.14159265359)
#define LUMWEIGHT    (vec3(0.2126,0.7152,0.0722))
#define gradientInput iChannel0
#define gradientDirectionX (true)

#define GRADIENT_RADIUSf float(GRADIENT_RADIUS)
#define GRADIENT_RADIUSi22f 4./float(GRADIENT_RADIUS*GRADIENT_RADIUS)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = vec4(0.);
    
    for( int i = -GRADIENT_RADIUS ; i <= GRADIENT_RADIUS ; i++ ){
    	for( int j = -GRADIENT_RADIUS ; j <= GRADIENT_RADIUS ; j++ ){
            fragColor += (gradientDirectionX ? float(i) : float(j))
                *exp(-float(i*i + j*j)*GRADIENT_RADIUSi22f)/GRADIENT_RADIUSf
                *texture(gradientInput,(fragCoord.xy+vec2(i,j))/iResolution.xy);
        }
        
    }
}