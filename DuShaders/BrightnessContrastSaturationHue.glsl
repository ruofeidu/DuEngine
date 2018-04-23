// MdjBRy
/** 
 * Brightness Contrast Saturation Hue
 * Demo: https://www.shadertoy.com/view/MdjBRy
 * starea @ ShaderToy
 * 
 * Forked and remixed from: 
 * [1] https://shadertoy.com/view/llGSzK
 * [2] https://shadertoy.com/view/MsjXRt
 *
 * Created 7/26/2017
 * Updated 8/11/2017
 **/

/*
mat4 brightnessMatrix( float b ) {
    return mat4( 
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        b, b, b, 1 );
}
*/
void brightnessAdjust( inout vec4 color, in float b) {
    color.rgb += b;
}

/*
mat4 contrastMatrix( float c ) {
	float t = 0.5 - c * 0.5;
    return mat4( 
        c, 0, 0, 0,
        0, c, 0, 0,
        0, 0, c, 0,
        t, t, t, 1 );

}
*/

void contrastAdjust( inout vec4 color, in float c) {
    float t = 0.5 - c * 0.5; 
    color.rgb = color.rgb * c + t;
}

mat4 saturationMatrix( float saturation ) {
    vec3 luminance = vec3( 0.3086, 0.6094, 0.0820 );
    float oneMinusSat = 1.0 - saturation;
    vec3 red = vec3( luminance.x * oneMinusSat );
    red.r += saturation;
    
    vec3 green = vec3( luminance.y * oneMinusSat );
    green.g += saturation;
    
    vec3 blue = vec3( luminance.z * oneMinusSat );
    blue.b += saturation;
    
    return mat4( 
        red,     0,
        green,   0,
        blue,    0,
        0, 0, 0, 1 );
}

int modi(int x, int y) {
    return x - y * (x / y);
}

int and(int a, int b) {
    int result = 0;
    int n = 1;
	const int BIT_COUNT = 32;

    for(int i = 0; i < BIT_COUNT; i++) {
        if ((modi(a, 2) == 1) && (modi(b, 2) == 1)) {
            result += n;
        }

        a >>= 1;
        b >>= 1;
        n <<= 1;

        if (!(a > 0 && b > 0))
            break;
    }
    return result;
}

// forked from https://www.shadertoy.com/view/llGSzK
// performance optimized by Ruofei
vec4 vibrance(vec4 inCol, float vibrance) //r,g,b 0.0 to 1.0,  vibrance 1.0 no change, 0.0 image B&W.
{
 	vec4 outCol;
    if (vibrance <= 1.0)
    {
        float avg = dot(inCol.rgb, vec3(0.3, 0.6, 0.1));
        outCol.rgb = mix(vec3(avg), inCol.rgb, vibrance); 
    }
    else // vibrance > 1.0
    {
        float hue_a, a, f, p1, p2, p3, i, h, s, v, amt, _max, _min, dlt;
        float br1, br2, br3, br4, br5, br2_or_br1, br3_or_br1, br4_or_br1, br5_or_br1;
        int use;

        _min = min(min(inCol.r, inCol.g), inCol.b);
        _max = max(max(inCol.r, inCol.g), inCol.b);
        dlt = _max - _min + 0.00001 /*Hack to fix divide zero infinities*/;
        h = 0.0;
        v = _max;

		br1 = step(_max, 0.0);
        s = (dlt / _max) * (1.0 - br1);
        h = -1.0 * br1;

		br2 = 1.0 - step(_max - inCol.r, 0.0); 
        br2_or_br1 = max(br2, br1);
        h = ((inCol.g - inCol.b) / dlt) * (1.0 - br2_or_br1) + (h*br2_or_br1);

		br3 = 1.0 - step(_max - inCol.g, 0.0); 
        
        br3_or_br1 = max(br3, br1);
        h = (2.0 + (inCol.b - inCol.r) / dlt) * (1.0 - br3_or_br1) + (h*br3_or_br1);

        br4 = 1.0 - br2*br3;
        br4_or_br1 = max(br4, br1);
        h = (4.0 + (inCol.r - inCol.g) / dlt) * (1.0 - br4_or_br1) + (h*br4_or_br1);

        h = h*(1.0 - br1);

        hue_a = abs(h); // between h of -1 and 1 are skin tones
        a = dlt;      // Reducing enhancements on small rgb differences

        // Reduce the enhancements on skin tones.    
        a = step(1.0, hue_a) * a * (hue_a * 0.67 + 0.33) + step(hue_a, 1.0) * a;                                    
        a *= (vibrance - 1.0);
        s = (1.0 - a) * s + a * pow(s, 0.25);

        i = floor(h);
        f = h - i;

        p1 = v * (1.0 - s);
        p2 = v * (1.0 - (s * f));
        p3 = v * (1.0 - (s * (1.0 - f)));

        inCol.rgb = vec3(0.0); 
        i += 6.0;
        //use = 1 << ((int)i % 6);
        use = int(pow(2.0,mod(i,6.0)));
        a = float(and(use , 1)); // i == 0;
        use >>= 1;
        inCol.rgb += a * vec3(v, p3, p1);
 
        a = float(and(use , 1)); // i == 1;
        use >>= 1;
        inCol.rgb += a * vec3(p2, v, p1); 

        a = float( and(use,1)); // i == 2;
        use >>= 1;
        inCol.rgb += a * vec3(p1, v, p3);

        a = float(and(use, 1)); // i == 3;
        use >>= 1;
        inCol.rgb += a * vec3(p1, p2, v);

        a = float(and(use, 1)); // i == 4;
        use >>= 1;
        inCol.rgb += a * vec3(p3, p1, v);

        a = float(and(use, 1)); // i == 5;
        use >>= 1;
        inCol.rgb += a * vec3(v, p1, p2);

        outCol = inCol;
    }
    return outCol;
}

// remixed from mAlk's https://www.shadertoy.com/view/MsjXRt
vec4 shiftHue(in vec3 col, in float Shift)
{
    vec3 P = vec3(0.55735) * dot(vec3(0.55735), col);
    vec3 U = col - P;
    vec3 V = cross(vec3(0.55735), U);    
    col = U * cos(Shift * 6.2832) + V * sin(Shift * 6.2832) + P;
    return vec4(col, 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // uniforms
	float brightness = 0.15;
	float contrast = 1.2;
    float saturation = 1.5;
    float _vibrance = 4.0;
    float _hue = abs(sin(iTime * 0.1)); 
    
    vec4 color = texture( iChannel0, fragCoord/iResolution.xy );
    
    fragColor = saturationMatrix(saturation) * color; 
    brightnessAdjust(color, brightness); 
    contrastAdjust(color, contrast); 
    fragColor = vibrance(fragColor, _vibrance);
    fragColor = shiftHue(fragColor.rgb, _hue);
    fragColor.a = 1.0;
    if (iMouse.z > 0.5) fragColor = color; 
}