// 4ltSWN
/** 
 * Print-friendly Color Palette x8
 * Link to demo: https://www.shadertoy.com/view/4ltSWN
 * starea @ ShaderToy
 */

// Print-friendly Color Palette x8 starts, Ruofei Du
vec3 RGBLabel(int i) {
	if (i == 0) return vec3(1.000, 1.000, 0.701);  else
	if (i == 1) return vec3(0.988, 0.834, 0.898);  else
	if (i == 2) return vec3(0.992, 0.805, 0.384); else
	if (i == 3) return vec3(0.775, 0.779, 0.875); else
	if (i == 4) return vec3(0.701, 0.871, 0.312); else
	if (i == 5) return vec3(0.553, 0.827, 0.780); else
	if (i == 6) return vec3(0.502, 0.694, 0.827); else
	if (i == 7) return vec3(0.984, 0.502, 0.347);
	return vec3(0.0);
}
// Print-friendly Color Palette x8 ends, Ruofei Du

// other references:
// https://r-forge.r-project.org/scm/viewvc.php/*checkout*/pkg/sp/R/bpy.colors.R?root=rspatial
// Backup experiments
/*
vec4 RGBLabelIQ(int i) {
	return vec4(vec3(0.5) + vec3(0.5) * cos(6.28318 * (vec3(1.0) * float(i) / 8.0 + vec3(0.0, 0.33, 0.67))), 1.0); 
}

// This may look better
vec4 RGBColor(float r, float g, float b) {
	return vec4(vec3(r, g, b) / 255.0, 1.0); 
}

vec4 RGBLabelNew(int i) {
	if (i == 0) return RGBColor(255.0, 255.0, 179.0);  else
	if (i == 1) return RGBColor(252.0, 205.0, 229.0);  else
	if (i == 2) return RGBColor(190.0, 186.0, 218.0); else
	if (i == 3) return RGBColor(141.0, 211.0, 199.0); else
	if (i == 4) return RGBColor(179.0, 222.0, 105.0); else
	if (i == 5) return RGBColor(253.0, 180.0,  98.0); else
	if (i == 6) return RGBColor(128.0, 177.0, 211.0); else
	if (i == 7) return RGBColor(251.0, 128.0, 114.0); else
				return RGBColor(0.0, 0.0, 0.0);
}

vec3 RGBtoHCV(in vec3 RGB)
{
	float Epsilon = 1e-10;
	vec4 P = (RGB.g < RGB.b) ? vec4(RGB.bg, -1.0, 2.0 / 3.0) : vec4(RGB.gb, 0.0, -1.0 / 3.0);
	vec4 Q = (RGB.r < P.x) ? vec4(P.xyw, RGB.r) : vec4(RGB.r, P.yzx);
	float C = Q.x - min(Q.w, Q.y);
	float H = abs((Q.w - Q.y) / (6.0 * C + Epsilon) + Q.z);
	return vec3(H, C, Q.x);
}

vec3 RGBtoHSV(in vec3 RGB)
{
	float Epsilon = 1e-10;
	vec3 HCV = RGBtoHCV(RGB);
	float S = HCV.y / (HCV.z + Epsilon);
	return vec3(HCV.x, S, HCV.z);
}

vec4 RGBLabelOld(int i) {
	if (i == 0) return RGBColor(127.0, 201.0, 127.0); else
	if (i == 1) return RGBColor(190.0, 174.0, 212.0); else
	if (i == 2) return RGBColor(253.0, 192.0, 134.0); else
	if (i == 3) return RGBColor(255.0, 255.0, 153.0); else
	if (i == 4) return RGBColor(56.0, 108.0, 176.0); else
	if (i == 5) return RGBColor(240.0, 2.0, 127.0); else
	if (i == 6) return RGBColor(191.0, 91.0, 23.0); else
	if (i == 7) return RGBColor(102.0, 102.0, 102.0); else
				return RGBColor(0.0, 0.0, 0.0);
}
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 col = RGBLabel(int(floor(uv.x * 9.0))); 
    float grey = dot(col, vec3(0.3, 0.59, 0.11));
	fragColor = vec4( (mod(iTime, 2.0) < 1.0) ? col : vec3(grey), 1.0); 
	fragColor = vec4( (fragCoord.y / iResolution.y < 0.5) ? col : vec3(grey), 1.0); 
}
