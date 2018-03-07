// Prints numbers

// Original version: https://www.shadertoy.com/view/4sBSWW

// Smaller Number Printing - @P_Malin
// Creative Commons CC0 1.0 Universal (CC-0)

// Feel free to modify, distribute or use in commercial code, just don't hold me liable for anything bad that happens!
// If you use this code and want to give credit, that would be nice but you don't have to.

// I first made this number printing code in https://www.shadertoy.com/view/4sf3RN
// It started as a silly way of representing digits with rectangles.
// As people started actually using this in a number of places I thought I would try to condense the 
// useful function a little so that it can be dropped into other shaders more easily,
// just snip between the perforations below.
// Also, the licence on the previous shader was a bit restrictive for utility code.
//
// Note that the values printed are not always accurate!

// ---- 8< ---- GLSL Number Printing - @P_Malin ---- 8< ----
// Creative Commons CC0 1.0 Universal (CC-0) 
// https://www.shadertoy.com/view/4sBSWW

float DigitBin(const in int x) {
	return x == 0 ? 480599.0 : x == 1 ? 139810.0 : x == 2 ? 476951.0 : x == 3 ? 476999.0 : x == 4 ? 350020.0 : x == 5 ? 464711.0 : x == 6 ? 464727.0 : x == 7 ? 476228.0 : x == 8 ? 481111.0 : x == 9 ? 481095.0 : 0.0;
}

// Original version
float PrintValue00(const in vec2 fragCoord, const in vec2 vPixelCoords, const in vec2 vFontSize, const in float fValue, const in float fMaxDigits, const in float fDecimalPlaces) {
	vec2 vStringCharCoords = (fragCoord.xy - vPixelCoords) / vFontSize;
	if ((vStringCharCoords.y < 0.0) || (vStringCharCoords.y >= 1.0)) return 0.0;
	float fLog10Value = log2(abs(fValue)) / log2(10.0);
	float fBiggestIndex = max(floor(fLog10Value), 0.0);
	float fDigitIndex = fMaxDigits - floor(vStringCharCoords.x);
	float fCharBin = 0.0;
	if (fDigitIndex >(-fDecimalPlaces - 1.01)) {
		if (fDigitIndex > fBiggestIndex) {
			if ((fValue < 0.0) && (fDigitIndex < (fBiggestIndex + 1.5))) fCharBin = 1792.0;
		} else {
			if (fDigitIndex == -1.0) {
				if (fDecimalPlaces > 0.0) fCharBin = 2.0;
			} else {
				if (fDigitIndex < 0.0) fDigitIndex += 1.0;
				float fDigitValue = (abs(fValue / (pow(10.0, fDigitIndex))));
				float kFix = 0.0001;
				fCharBin = DigitBin(int(floor(mod(kFix + fDigitValue, 10.0))));
			}
		}
	}
	return floor(mod((fCharBin / pow(2.0, floor(fract(vStringCharCoords.x) * 4.0) + (floor(vStringCharCoords.y * 5.0) * 4.0))), 2.0));
}

// Improved version
//
// Most important change is dropping everything left of the decimal point ASAP 
// when printing the fractional digits. This is done to bring the magnitule down
// for the following division and modulo.
//
// Another change is to replace the logarithm with a power-of-ten value 
// calculation that is needed later anyway.
// This change is optional, either one works.
float PrintValue(vec2 fragCoord, vec2 pixelCoord, vec2 fontSize, float value,
	float digits, float decimals) {
	vec2 charCoord = (fragCoord - pixelCoord) / fontSize;
	if (charCoord.y < 0.0 || charCoord.y >= 1.0) return 0.0;
	float bits = 0.0;
	float digitIndex1 = digits - floor(charCoord.x) + 1.0;
	if (-digitIndex1 <= decimals) {
		float pow1 = pow(10.0, digitIndex1);
		float absValue = abs(value);
		float pivot = max(absValue, 1.5) * 10.0;
		if (pivot < pow1) {
			if (value < 0.0 && pivot >= pow1 * 0.1) bits = 1792.0;
		} else if (digitIndex1 == 0.0) {
			if (decimals > 0.0) bits = 2.0;
		} else {
			value = digitIndex1 < 0.0 ? fract(absValue) : absValue * 10.0;
			bits = DigitBin(int(mod(value / pow1, 10.0)));
		}
	}
	return floor(mod(bits / pow(2.0, floor(fract(charCoord.x) * 4.0) + floor(charCoord.y * 5.0) * 4.0), 2.0));
}
// ---- 8< -------- 8< -------- 8< -------- 8< ----


float GetCurve(float x) {
	return ceil(sin(x * 3.14159 * 4.0)*10.0 - 0.5) / 10.0;
}

float GetCurveDeriv(float x) {
	return 3.14159 * 4.0 * cos(x * 3.14159 * 4.0);
}

// Multiples of 4x5 work best
vec2 fontSize = vec2(4, 5) * vec2(5, 3);

vec2 grid(int x, int y) { return fontSize.xx * vec2(1, ceil(fontSize.y / fontSize.x)) * vec2(x, y) + vec2(2); }

vec2 limitTo(vec2 point, int x1, int y1, int x2, int y2, int startX, int startY) {
	return clamp(point, grid(x1, y1), iResolution.xy - grid(x2, y2)) + grid(startX, startY);
}
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	vec3 vColour = vec3(0.0);
	vec2 mouse = iMouse.xy;

	if (mouse.x < 10.0 && mouse.y < 10.0) {
		mouse = (vec2(sin(iGlobalTime), cos(iGlobalTime)) / 2.0 + 0.5)*iResolution.xy;
	}
	// Draw Horizontal Line
	if (abs(fragCoord.y - iResolution.y * 0.5) < 1.0) {
		vColour = vec3(0.25);
	}
	// Draw Sin Wave
	// See the comment from iq or this page
	// http://www.iquilezles.org/www/articles/distance/distance.htm
	float fCurveX = fragCoord.x / iResolution.x;
	float fSinY = (GetCurve(fCurveX) * 0.25 + 0.5) * iResolution.y;
	float fSinYdX = (GetCurveDeriv(fCurveX) * 0.25) * iResolution.y / iResolution.x;
	float fDistanceToCurve = abs(fSinY - fragCoord.y) / sqrt(1.0 + fSinYdX*fSinYdX);
	float fSetPixel = fDistanceToCurve - 1.0; // Add more thickness
	vColour = mix(vec3(1.0, 0.0, 0.0), vColour, clamp(fSetPixel, 0.0, 1.0));

	// Draw Sin Value	
	float fValue4 = GetCurve(mouse.x / iResolution.x);
	float fPixelYCoord = (fValue4 * 0.25 + 0.5) * iResolution.y;

	// Plot Point on Sin Wave
	float fDistToPointA = length(vec2(mouse.x, fPixelYCoord) - fragCoord.xy) - 4.0;
	vColour = mix(vColour, vec3(0.0, 1.0, 1.0), (1.0 - clamp(fDistToPointA, 0.0, 1.0)));

	// Plot Mouse Pos
	float fDistToPointB = length(vec2(mouse.x, mouse.y) - fragCoord.xy) - 4.0;
	vColour = mix(vColour, vec3(0.0, 1.0, 0.0), (1.0 - clamp(fDistToPointB, 0.0, 1.0)));

	// Print Sin Value
	vec2 vPixelCoord4 = limitTo(vec2(mouse.x, fPixelYCoord), 0, 2, 8, 4, 0, 0);// + vec2(4.0, 4.0);
	float fDigits = 2.0;
	float fDecimalPlaces = 4.0;
	float fIsDigit4 = PrintValue(fragCoord, vPixelCoord4, fontSize, fValue4, fDigits, fDecimalPlaces);
	vColour = mix(vColour, vec3(0.0, 1.0, 1.0), fIsDigit4);

	// Print Shader Time
	fDigits = 6.0;
	vColour = mix(vColour, vec3(0.0, 0.0, 1.0), PrintValue(fragCoord, grid(11, 0), fontSize, iGlobalTime, fDigits, fDecimalPlaces));

	// Print Date
	vColour = mix(vColour, vec3(1.0, 1.0, 0.0), PrintValue(fragCoord, grid(0, 0), fontSize, iDate.x, 4.0, 0.0));
	vColour = mix(vColour, vec3(1.0, 1.0, 0.0), PrintValue(fragCoord, grid(5, 0), fontSize, iDate.y + 1.0, 2.0, 0.0));
	vColour = mix(vColour, vec3(1.0, 1.0, 0.0), PrintValue(fragCoord, grid(8, 0), fontSize, iDate.z, 2.0, 0.0));

	// Draw Time
	vColour = mix(vColour, vec3(1.0, 0.0, 1.0), PrintValue(fragCoord, grid(24, 0), fontSize, mod(iDate.w / (60.0 * 60.0), 12.0), 2.0, 0.0));
	vColour = mix(vColour, vec3(1.0, 0.0, 1.0), PrintValue(fragCoord, grid(27, 0), fontSize, mod(iDate.w / 60.0, 60.0), 2.0, 0.0));
	vColour = mix(vColour, vec3(1.0, 0.0, 1.0), PrintValue(fragCoord, grid(30, 0), fontSize, mod(iDate.w, 60.0), 2.0, 0.0));
	// Draw Resolution
	vColour = mix(vColour, vec3(0.867, 0.910, 0.247), PrintValue(fragCoord, grid(35, 0), fontSize, iResolution.x, 2.0, 0.0));
	vColour = mix(vColour, vec3(0.867, 0.910, 0.247), PrintValue(fragCoord, grid(40, 0), fontSize, iResolution.y, 2.0, 0.0));
	vColour = mix(vColour, vec3(0.867, 0.910, 0.247), PrintValue(fragCoord, grid(50, 0), fontSize, iFrame, 2.0, 0.0));
	// Frame Rate
	vColour = mix(vColour, vec3(0.216, 0.471, 0.698), PrintValue(fragCoord, grid(60, 0), fontSize, float(iFrameRate), 2.0, 4.0));
	vColour = mix(vColour, vec3(0.216, 0.471, 0.698), PrintValue(fragCoord, grid(70, 0), fontSize, iTimeDelta * 1000, 2.0, 4.0));

	if (mouse.x >= 0.0) {
		// Print Mouse X
		vec2 vPixelCoord2 = limitTo(mouse.xy, 8, 2, 8, 4, -8, 1);
		float fValue2 = mouse.x / iResolution.x;
		fDigits = 1.0;
		fDecimalPlaces = 5.0;
		float fIsDigit2 = PrintValue(fragCoord, vPixelCoord2, fontSize, fValue2, fDigits, fDecimalPlaces);
		vColour = mix(vColour, vec3(0.0, 1.0, 0.0), fIsDigit2);

		// Print Mouse Y
		vec2 vPixelCoord3 = limitTo(mouse.xy, 8, 2, 8, 4, 0, 1);
		float fValue3 = mouse.y / iResolution.y;
		fDigits = 1.0;
		float fIsDigit3 = PrintValue(fragCoord, vPixelCoord3, fontSize, fValue3, fDigits, fDecimalPlaces);
		vColour = mix(vColour, vec3(0.0, 1.0, 0.0), fIsDigit3);
	}

	fragColor = vec4(vColour, 1.0);
}