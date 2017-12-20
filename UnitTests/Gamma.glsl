// https://www.shadertoy.com/view/Xdl3DM 
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Shaders must perform lighting computations in linear space, and then apply gamma correction on 
// their own in order to get a perceptually linear response. WebGL/Browsers/OS don't apply gamma 
// for you, not WebGL supports anything similar to GL_ARB_framebuffer_sRGB
	
/*
Move the mouse until the circles and the middle of the gradient blend with the background.
When doing WebGL, once you have performed your lighting computations in linear space, you must apply gamma correction by hand for a perceptually linear display.
Comments (12)
*/

float PrintValue(const in vec2 vStringCharCoords, const in float fValue, const in float fMaxDigits, const in float fDecimalPlaces);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;

	// gamma value to be tested
	float gamma = 2.20;	
	if( iMouse.z>0.0 ) gamma = 0.5 + 2.5*iMouse.x/iResolution.x;
	
    // background	
    vec2 p = floor(fragCoord);
    float f = mod( p.x +p.y, 2.0 );

    // patterns	
    // apply gamma	
    float midgrey = pow( 0.5, 1.0/gamma );
    
	f = mix( midgrey,  f, smoothstep(0.1,0.101,length(uv-vec2(0.2,0.2))) );
	f = mix( midgrey,  f, smoothstep(0.1,0.101,length(uv-vec2(0.2,0.8))) );
	f = mix( midgrey,  f, smoothstep(0.1,0.101,length(uv-vec2(0.8,0.2))) );
	f = mix( midgrey,  f, smoothstep(0.1,0.101,length(uv-vec2(0.8,0.8))) );

    // print gamma value	
	f = mix( f, 0.0, PrintValue( (uv-vec2(0.43,0.9))*40.0, gamma, 1.0, 2.0) );

    
	fragColor = vec4( f, f, f, 1.0 );
}














//---------------------------------------------------------------
// number rendering code below by P_Malin
//
// https://www.shadertoy.com/view/4sf3RN
//---------------------------------------------------------------


float InRect(const in vec2 vUV, const in vec4 vRect)
{
	vec2 vTestMin = step(vRect.xy, vUV.xy);
	vec2 vTestMax = step(vUV.xy, vRect.zw);	
	vec2 vTest = vTestMin * vTestMax;
	return vTest.x * vTest.y;
}

float SampleDigit(const in float fDigit, const in vec2 vUV)
{
	const float x0 = 0.0 / 4.0;
	const float x1 = 1.0 / 4.0;
	const float x2 = 2.0 / 4.0;
	const float x3 = 3.0 / 4.0;
	const float x4 = 4.0 / 4.0;
	
	const float y0 = 0.0 / 5.0;
	const float y1 = 1.0 / 5.0;
	const float y2 = 2.0 / 5.0;
	const float y3 = 3.0 / 5.0;
	const float y4 = 4.0 / 5.0;
	const float y5 = 5.0 / 5.0;

	// In this version each digit is made of up to 3 rectangles which we XOR together to get the result
	
	vec4 vRect0 = vec4(0.0);
	vec4 vRect1 = vec4(0.0);
	vec4 vRect2 = vec4(0.0);
		
	if(fDigit < 0.5) // 0
	{
		vRect0 = vec4(x0, y0, x3, y5); vRect1 = vec4(x1, y1, x2, y4);
	}
	else if(fDigit < 1.5) // 1
	{
		vRect0 = vec4(x1, y0, x2, y5); vRect1 = vec4(x0, y0, x0, y0);
	}
	else if(fDigit < 2.5) // 2
	{
		vRect0 = vec4(x0, y0, x3, y5); vRect1 = vec4(x0, y3, x2, y4); vRect2 = vec4(x1, y1, x3, y2);
	}
	else if(fDigit < 3.5) // 3
	{
		vRect0 = vec4(x0, y0, x3, y5); vRect1 = vec4(x0, y3, x2, y4); vRect2 = vec4(x0, y1, x2, y2);
	}
	else if(fDigit < 4.5) // 4
	{
		vRect0 = vec4(x0, y1, x2, y5); vRect1 = vec4(x1, y2, x2, y5); vRect2 = vec4(x2, y0, x3, y3);
	}
	else if(fDigit < 5.5) // 5
	{
		vRect0 = vec4(x0, y0, x3, y5); vRect1 = vec4(x1, y3, x3, y4); vRect2 = vec4(x0, y1, x2, y2);
	}
	else if(fDigit < 6.5) // 6
	{
		vRect0 = vec4(x0, y0, x3, y5); vRect1 = vec4(x1, y3, x3, y4); vRect2 = vec4(x1, y1, x2, y2);
	}
	else if(fDigit < 7.5) // 7
	{
		vRect0 = vec4(x0, y0, x3, y5); vRect1 = vec4(x0, y0, x2, y4);
	}
	else if(fDigit < 8.5) // 8
	{
		vRect0 = vec4(x0, y0, x3, y5); vRect1 = vec4(x1, y1, x2, y2); vRect2 = vec4(x1, y3, x2, y4);
	}
	else if(fDigit < 9.5) // 9
	{
		vRect0 = vec4(x0, y0, x3, y5); vRect1 = vec4(x1, y3, x2, y4); vRect2 = vec4(x0, y1, x2, y2);
	}
	else if(fDigit < 10.5) // '.'
	{
		vRect0 = vec4(x1, y0, x2, y1);
	}
	else if(fDigit < 11.5) // '-'
	{
		vRect0 = vec4(x0, y2, x3, y3);
	}	
	
	float fResult = InRect(vUV, vRect0) + InRect(vUV, vRect1) + InRect(vUV, vRect2);
	
	return mod(fResult, 2.0);
}

const float kCharBlank = 12.0;
const float kCharMinus = 11.0;
const float kCharDecimalPoint = 10.0;

float PrintValue(const in vec2 vStringCharCoords, const in float fValue, const in float fMaxDigits, const in float fDecimalPlaces)
{
	float fAbsValue = abs(fValue);
	
	float fStringCharIndex = floor(vStringCharCoords.x);
	
	float fLog10Value = log2(fAbsValue) / log2(10.0);
	float fBiggestDigitIndex = max(floor(fLog10Value), 0.0);
	
	// This is the character we are going to display for this pixel
	float fDigitCharacter = kCharBlank;
	
	float fDigitIndex = fMaxDigits - fStringCharIndex;
	if(fDigitIndex > (-fDecimalPlaces - 1.5))
	{
		if(fDigitIndex > fBiggestDigitIndex)
		{
			if(fValue < 0.0)
			{
				if(fDigitIndex < (fBiggestDigitIndex+1.5))
				{
					fDigitCharacter = kCharMinus;
				}
			}
		}
		else
		{		
			if(fDigitIndex == -1.0)
			{
				if(fDecimalPlaces > 0.0)
				{
					fDigitCharacter = kCharDecimalPoint;
				}
			}
			else
			{
				if(fDigitIndex < 0.0)
				{
					// move along one to account for .
					fDigitIndex += 1.0;
				}

				// This is inaccurate - I think because I treat each digit independently
				// The value 2.0 gets printed as 2.09 :/
				float fDigitValue = (fAbsValue / (pow(10.0, fDigitIndex)));
				fDigitCharacter = mod(floor(fDigitValue+0.0001), 10.0);
			}		
		}
	}

	vec2 vCharPos = vec2(fract(vStringCharCoords.x), vStringCharCoords.y);

	return SampleDigit(fDigitCharacter, vCharPos);	
}