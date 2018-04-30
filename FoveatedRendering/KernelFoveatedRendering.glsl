/**
 * This shader is a minimum demonstration of the Kernel Foveated Rendering paper
 * However, this pilot demo has NOT dealed with x=0 artifacts and removed TAA, FXAA etc.
 * Link to demo: https://www.shadertoy.com/view/lsdfWn
 * License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
 * For more details, please visit: http://duruofei.com/Public/papers/Meng_KernelFoveatedRendering_PACM_2018.pdf
 * 
 * You can swap the code in Buf A between EXTERNEL SHADER BEGIN / END for a new scene.
 * Note that the best practice is to resize the framebuffer instead of hacking through discard in Buf A.
 * This is minimum demo without anti-aliasing nor deferred shading. Please refer to the paper for more details.
 * https://goo.gl/1noXYE
 *
 * Courtesy of iq's LadyBug shader
 * https://www.shadertoy.com/view/4tByz3
 * License Creative Commons Attribution-NonCommercial-ShareAlike 3.0
 *
 * Citation: Xiaoxu Meng, Ruofei Du, Matthias Zwicker, and Amitabh Varshney. (2018). Kernel Foveated Rendering. I3D '2018, 1(5), 1-20.
 *
 */

vec3 performGaussBlur(vec2 pos) // perform gaussian blur
{
	const float PARA1 = 0.2042, PARA2 = 0.1238, PARA3 = 0.0751;
	vec3 fragColor11 = texture(logTexture, pos - PIXEL_SIZE).xyz;
	vec3 fragColor12 = texture(logTexture, pos - vec2(0.0f, PIXEL_SIZE.y)).xyz;
	vec3 fragColor13 = texture(logTexture, pos + vec2(PIXEL_SIZE.x, -PIXEL_SIZE.y)).xyz;
	vec3 fragColor21 = texture(logTexture, pos - vec2(PIXEL_SIZE.x, 0.0f)).xyz;
	vec3 fragColor22 = texture(logTexture, pos + vec2(0.0f, 0.0f)).xyz;
	vec3 fragColor23 = texture(logTexture, pos + vec2(PIXEL_SIZE.x, 0.0f)).xyz;
	vec3 fragColor31 = texture(logTexture, pos + vec2(-PIXEL_SIZE.x, PIXEL_SIZE.y)).xyz;
	vec3 fragColor32 = texture(logTexture, pos + vec2(0.0f, PIXEL_SIZE.y)).xyz;
	vec3 fragColor33 = texture(logTexture, pos + PIXEL_SIZE).xyz;

	vec3 fragColore1 = texture(logTexture, pos + 2.0*vec2(PIXEL_SIZE.x, 0.0f)).xyz;
	vec3 fragColore2 = texture(logTexture, pos + 2.0*vec2(-PIXEL_SIZE.x, 0.0f)).xyz;
	vec3 fragColore3 = texture(logTexture, pos + 2.0*vec2(0.0f, PIXEL_SIZE.y)).xyz;
	vec3 fragColore4 = texture(logTexture, pos + 2.0*vec2(0.0f, -PIXEL_SIZE.y)).xyz;

	vec3 newColor = PARA3 * (fragColor11 + fragColor13 + fragColor31 + fragColor33) +
		PARA2 * (fragColor12 + fragColor21 + fragColor23 + fragColor32) +
		PARA1 * fragColor22;
	return newColor;
}

vec3 FXAA(vec2 pos) {
	/*---------------------------------------------------------*/
	//#define FXAA_REDUCE_MUL   (1.0/8.0)
	//#define FXAA_SPAN_MAX     8.0
	/*---------------------------------------------------------*/
	vec3 rgbNW = texture(logTexture, pos - vec2(PIXEL_SIZE.x, 0)).xyz;
	vec3 rgbNE = texture(logTexture, pos + vec2(PIXEL_SIZE.x, 0)).xyz;
	vec3 rgbSW = texture(logTexture, pos - vec2(0, PIXEL_SIZE.y)).xyz;
	vec3 rgbSE = texture(logTexture, pos + vec2(0, PIXEL_SIZE.y)).xyz;
	vec3 rgbM = texture(logTexture, pos).xyz;
	rgbNW = rgbM;
	/*---------------------------------------------------------*/
	vec3 luma = vec3(0.299, 0.587, 0.114);
	float lumaNW = dot(rgbNW, luma);
	float lumaNE = dot(rgbNE, luma);
	float lumaSW = dot(rgbSW, luma);
	float lumaSE = dot(rgbSE, luma);
	float lumaM = dot(rgbM, luma);
	/*---------------------------------------------------------*/
	float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
	float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
	float range = lumaMax - lumaMin;
	/*---------------------------------------------------------*/
	//if (range < max(FXAA_EDGE_THRESHOLD_MIN, lumaMax * FXAA_EDGE_THRESHOLD))
	//	return rgbM;
	//return (rgbNW + rgbNE + rgbSW + rgbSE + rgbM) * 0.2;
	vec2 dir;
	dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
	dir.y = ((lumaNW + lumaSW) - (lumaNE + lumaSE));
	/*---------------------------------------------------------*/
	float dirReduce = max(
		(lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * 0.125),
		1.0 / 128.0);
	float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
	dir = min(vec2(FXAA_SPAN_MAX), max(vec2(-FXAA_SPAN_MAX), dir * rcpDirMin)) * PIXEL_SIZE.xy;
	/*--------------------------------------------------------*/
	vec3 rgbA = (1.0 / 2.0) * (
		texture(logTexture, pos + dir * (1.0 / 3.0 - 0.5)).xyz +
		texture(logTexture, pos + dir * (2.0 / 3.0 - 0.5)).xyz);
	vec3 rgbB = rgbA * (1.0 / 2.0) + (1.0 / 4.0) * (
		texture(logTexture, pos + dir * (0.0 / 3.0 - 0.5)).xyz +
		texture(logTexture, pos + dir * (3.0 / 3.0 - 0.5)).xyz);
	float lumaB = dot(rgbB, luma);

	if ((lumaB < lumaMin) || (lumaB > lumaMax)) return rgbA;
	return rgbB;
}

float powFunc(float lr) {
	return pow(lr, ALPHA);
}

float expFunc(float lr) {
	return (exp(lr) - 1.0) / (exp(1.0) - 1.0);
}

float selfFunc(float lr) {
	return 0.5 * lr * lr * lr * lr + 0.5 * lr * lr;
}

float sinFunc(float lr) {
	return asin(lr) * 4.0 / TWOPI;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	float SCALE_RATIO = iMouse.z > 0.0 ? 1.0 : DEFAULT_SIGMA;
    vec2 iRes = iResolution.xy, foveal = FOVEAL, foveal2 = FOVEAL2;
    
    // Equation (12) and (13)
	float maxL = max(
		max(length((vec2(1, 1) - foveal) * iRes),
			length((vec2(1, -1) - foveal) * iRes)
			),
		max(length((vec2(-1, 1) - foveal) * iRes),
			length((vec2(-1, -1) - foveal) * iRes)
			)
		);
	float L = log(maxL * 0.5);
	vec2 uv = fragCoord / iRes; // [0, 1]
	vec2 pq = uv * 2.0 - 1.0 - foveal;
	float r = length(pq * iRes * 0.5); // [-1, 1] * length(iResolution.xy * 0.5)
	float lr = log(r);
	float theta = atan(pq.y * iRes.y, pq.x * iRes.x) + step(pq.y, 0.0) * TWOPI;

	lr /= L;
	if (KERNEL_FUNCTION_TYPE < 1.0)
		lr = lr;
	else if (KERNEL_FUNCTION_TYPE < 2.0)
		lr = expFunc(lr);
	else if (KERNEL_FUNCTION_TYPE < 3.0)
		lr = sinFunc(lr);
	else if (KERNEL_FUNCTION_TYPE < 4.0)
		lr = powFunc(lr);

	theta /= MAX_THETA;
	vec2 logCoord = vec2(lr, theta) / SCALE_RATIO;
    if (!iApplyLogMap2)
        logCoord = uv;

	vec3 col = texture(logTexture, logCoord, 2.0).rgb;
    
#if USE_FXAA
	if (AdjustRegion > 1 && newCoord.y < 0.995 / SCALE_RATIO)
		col = FXAA(logCoord);
	else if (length(uv - foveal2) > 0.1 && AdjustRegion > 0 && logCoord.y < 0.995 / SCALE_RATIO)
		col = performGaussBlur(logCoord);
#endif

	// Usually if the size of framebuffer is scaled with SCALE_RATIO correctly, 
    // the mipmap filtering and mirror wraping could solve the polar issue
    // alternative trick is to enlarge the rect geometry with one extra pixel for mirror wraping.
    // float y = logCoord.y * SCALE_RATIO * iRes.y;
    //if (y > iRes.y - 1.0) {
    //    col = texelFetch(logTexture, ivec2(logCoord*iResolution.xy), 0).rgb;
        // col = FXAA(logCoord);
       // col = vec3(1.0);
       // mainShader(fragColor, fragCoord);
   //}

	vec2 uv2 = uv * 2.0 - 1.0;
    uv2.x *= iResolution.x / iResolution.y;
    foveal.x *= iResolution.x / iResolution.y;
	if (length(foveal - uv2) < 0.05 && length(foveal - uv2) > 0.03)
		col = mix(col, vec3(1.0), 0.2);

	fragColor = vec4(col, 1.0);
}


// Hack for 
