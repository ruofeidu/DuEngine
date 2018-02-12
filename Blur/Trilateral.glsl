// https://www.shadertoy.com/view/https://www.shadertoy.com/view/MtcSzH
#define input 	iChannel0
#define inputDX iChannel1
#define inputDY iChannel2

// my take on Trilateral Filtering
// http://dl.acm.org/citation.cfm?id=882431

// Upgrading Bilateral Blur with Gradient
// https://www.shadertoy.com/view/MlVGW3
#define RADIUS     (12)
#define DIAMETER   (2*RADIUS+1)

// bigger theses coeff the more we take into account the space concerned

// shouldn't need to change it
// close to 0 => square-shaped
#define COORDCOEFF (1.41)

// if theses two == 0. => filter is a gaussian blur
// the closer to zero the blurier
// the bigger the more selective
#define LUMCOEFF   (8.)
#define GRADCOEFF  (6.)

// see line 84
// not confident in my calculus in buffB & buffC
#define LUMPLANECORRECTION (1.)

#define GAMMA        (2.2)
#define pow3(x,y)    (pow( max(x,0.) , vec3(y) ))
#define LUMWEIGHT    (vec4(0.2126,0.7152,0.0722,0.3333))
#define GRADIENT_RADIUS (8)

#define GRADIENT_RADIUSf float(GRADIENT_RADIUS)
#define GRADIENT_RADIUSi22f (4./float(GRADIENT_RADIUS*GRADIENT_RADIUS))
#define PI           (3.14159265359)
#define viewport(x) ( (x) /iResolution.xy)

#define DX          (iMouse.x/iResolution.x)
#define DY          (iMouse.y/iResolution.y)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = viewport(fragCoord);
    
    vec4 thisColor = texture(input,uv);
    vec4 thisGradX = texture(inputDX,uv);
    vec4 thisGradY = texture(inputDY,uv);
    
    fragColor = vec4(0.);
    vec4 diffColorToGradient;
    vec4 diffGradientX;
    vec4 diffGradientY;
    float sum = 0.;
    float coeff;
    vec2 pos;
    vec4 color = vec4(0.);
    vec4 gradX = vec4(0.);
    vec4 gradY = vec4(0.);
    
    float GradCoeff2 = GRADCOEFF*GRADCOEFF;
    float LumCoeff2 = LUMCOEFF*LUMCOEFF;
    float CoordCoeff2 = COORDCOEFF*COORDCOEFF/float(RADIUS*RADIUS);
    
    for( int i = -RADIUS ; i <= RADIUS ; i++ ){
        for( int j = -RADIUS ; j <= RADIUS ; j++ ){
            
            pos = viewport(fragCoord.xy+vec2(i,j));
            color = texture(input,pos);
            gradX = texture(inputDX,pos);
            gradY = texture(inputDY,pos);
            
            diffGradientX = thisGradX - gradX;
            diffGradientY = thisGradY - gradY;
            
            diffColorToGradient = thisColor - color
                // minus sign ? I must have made an error in buffB & buffC :-( 
                - (thisGradX*float(i) + thisGradY*float(j))*GRADIENT_RADIUSi22f*LUMPLANECORRECTION;
            
            coeff = exp( -(
                // blur in coordinate space
                float(i*i+j*j)*CoordCoeff2
                // blur in distance to first local approximation
                // instead of blur in color space
                + dot(diffColorToGradient,diffColorToGradient)*LumCoeff2
                // blur in gradient space
                + dot( diffGradientX*diffGradientX + diffGradientY*diffGradientY , LUMWEIGHT )*GradCoeff2
                ));
            
            
            if( i == -RADIUS && j == -RADIUS ){
            	fragColor = color*coeff;
            } else {
            	fragColor += color*coeff;
            }
            
            sum += coeff;
            
        }
    }
    
    // no need for uncertainty map (mix to thisColor based on sum log value)
    // like in https://www.shadertoy.com/view/MlVGW3 ?
	fragColor = fragColor/sum;
    
    vec4 normGrad = sqrt(thisGradX*thisGradX + thisGradY*thisGradY)*GRADIENT_RADIUSi22f;
    
    if( iMouse.z > .5 ){
    	fragColor = DX >.5 ? normGrad : thisColor;
    } else {
        if( DY > .5 ){
            fragColor = thisColor - 2.*(fragColor - thisColor);
        }
    }
    
	fragColor.rgb = pow3(fragColor.rgb,1./GAMMA);
    fragColor.a = 1.;
}
