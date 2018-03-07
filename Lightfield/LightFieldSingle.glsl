#define N 16.0
#define M 16.0
#define rows (N - 1.0)
#define cols (M - 1.0)
#define size vec2(cols, rows)
#define spanX (1.0 / M)
#define spanY (1.0 / N)
#define span vec2(spanX, spanY)

// uniform float focalLength, apertureSize, gapRatio;
float focalLength = 0.0;
float apertureSize = 2.0;
float gapRatio = 8.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec2 projectedCoord = 2.0 * uv - 1.0; 
	
	vec2 cameraGap = gapRatio / size;  							// 8 / 15 = (0.53, 0.53)
	vec2 initCamera = -0.5 * cameraGap * size;					// vec2(-7.5, -7.5)
	float focalRatio = 10.0 * gapRatio;							// 80
	vec2 cameraIndex = iMouse.xy / iResolution.xy * size;
	vec2 centerCamera = initCamera + cameraIndex * cameraGap;	// vec2(-3.76) 
	float focalLengthRatio = 1.0 + focalLength / focalRatio;			// ~1.01
	
	fragColor = vec4(0.0);
	float validPixelCount = 0.0;
	float minDist = 1e8;
	vec2 minPos = vec2(0.0); 
	
	for (float i = 0.0; i < N; ++i) {
		for (float j = 0.0; j < M; ++j) {
			vec2 pos = vec2(j, i); 
			vec2 cameraPos = initCamera + pos * cameraGap;
			float dist = distance(cameraPos, centerCamera); 
			if (dist < minDist) {
				minDist = dist; 
				minPos = pos; 
			}
			if (dist < apertureSize) {
				vec2 pixel = cameraPos + (projectedCoord - cameraPos) * focalLengthRatio;
				pixel = 0.5 * pixel + 0.5; 
				pos.y = rows - pos.y - 1.0; 
				vec2 UV = (pos + pixel) * span;
				if (UV.x < 0 || UV.x > 1 || UV.y < 0 || UV.y > 1) continue; 
				fragColor += texture(iChannel0, UV);
				++validPixelCount;
			}
		}
	}
	
	if (validPixelCount > 0.0) fragColor = fragColor / validPixelCount; else {
		vec2 cameraPos = initCamera + minPos * cameraGap;
		vec2 pixel = cameraPos + (projectedCoord - cameraPos) * focalLengthRatio;
		pixel = 0.5 * pixel + 0.5; 
		fragColor = texture2D(iChannel0, (minPos + pixel) * span);
	}
	
}
