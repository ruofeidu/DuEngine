// https://www.shadertoy.com/view/4sVyzR
#define kernelSize 5
#define halfKernelSize 2

#define blurStrength 1.0
#define blurEdge 0.3

vec3 fastSurfaceBlur( sampler2D inputColor, sampler2D inputEdge, vec2 uv, vec2 blurStep)
{
	// Normalized gauss kernel
	float blurKernel[kernelSize] = float[kernelSize](
		0.06136, 0.24477, 0.38774, 0.24477, 0.06136
   	);
	
	vec3 result = blurEdge*blurKernel[halfKernelSize]*texture(inputColor,uv).rgb;
	float norma = blurEdge*blurKernel[halfKernelSize];
	
	float mainEdge = texture(inputEdge,uv).x;
	
	// Right direction
	float weight = blurEdge;
	for(int i = 1; i<halfKernelSize; i++){
		vec2 currentPos = uv+float(i)*blurStep;
		
		weight-=abs(texture(inputEdge,currentPos).x-mainEdge)/blurStrength;
		if(weight<=0.0) break;
		
		float coef = weight*blurKernel[halfKernelSize+i];
		result+=coef*texture(inputColor,currentPos).rgb;
		norma+=coef;
	}
	// Left direction
	weight = blurEdge;
	for(int i = 1; i<halfKernelSize; i++){
		vec2 currentPos = uv-float(i)*blurStep;
		
		weight-=abs(texture(inputEdge,currentPos).x-mainEdge)/blurStrength;
		if(weight<=0.0) break;
		
		float coef = weight*blurKernel[halfKernelSize-i];
		result+=coef*texture(inputColor,currentPos).rgb;
		norma+=coef;
	}
    return result/norma;
}