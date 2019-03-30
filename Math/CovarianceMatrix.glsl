// https://www.shadertoy.com/view/Xsy3Dt
#define PI 3.141592654

/*
	A covariance matrix is always diagonally symmetric and "positive-semidefinite".

	Values in the diagonals indicate the variance of different 
*/


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //Decide our distribution's characteristics based on user interaction
    vec2 mouse = iMouse.xy / iResolution.xy;
    float
        spread  = 0.25,
        stretch = pow(2.0, 3.0*mouse.y-1.5),
        yVar    = spread * stretch,
        xVar    = spread / stretch,
        xyCoVar = spread * (1.8*mouse.x-0.9);
    
    //The covariance matrix -- we don't actually use it to visualize!
    mat2 mCov = mat2(
    	xVar,    xyCoVar,
    	xyCoVar, yVar);
    
    //Compute the inverse covariance matrix for rendering
    float dCov = (xVar*yVar-xyCoVar*xyCoVar);
    mat2 mCovInv = mat2(
        yVar    /dCov, -xyCoVar/dCov,
        -xyCoVar/dCov, xVar    /dCov);
    
    //What position in the standard normal distribution does this pixel map to?
    vec2 loc = 2.0 * (fragCoord.xy - .5*iResolution.xy) / iResolution.y;
    vec2 stdPos = mCovInv * loc;
    
    //Visualize the probability density
    float density = exp(-.5*dot(stdPos, stdPos));
    
    //...Plus some little ellipses for each standard deviation away from the mean
    float ringPhase = PI*max(length(stdPos),.5);
    float ring = pow(cos(ringPhase)*cos(ringPhase), 8.0)
        * (.5+.5*cos(atan(stdPos.y,stdPos.x)*13.0*floor(length(stdPos)+.5)));
    
    fragColor = vec4(density+.3*ring, density, density, 1.0);
}
