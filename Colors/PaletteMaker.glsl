// https://www.shadertoy.com/view/Msc3zB
// A palette generator shader heavily inspired by http://paletton.com/#

float pi = 3.14159265358979;

// parameters
const float gradientAngle = 45.0; // degrees
const vec2 lumSatOffset = vec2(0.1,0.0); // range [-1..1]
const float lumSatAngle = 110.0; // degrees
const float lumSatFactor = 0.4;// range [0..1]

    
vec3 hsv2rgb (in vec3 hsv) 
{
    return hsv.z * (1.0 + 0.5 * hsv.y * (cos (6.2832 * (hsv.x + vec3 (0.0, 0.6667, 0.3333))) - 1.0));
}

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 baseColor(vec2 uv)
{
	vec3 col = vec3(max(uv.y,0.0)+max(uv.x,0.0),max(-uv.y,0.0)+max(uv.x,0.0),max(-uv.x,0.0));
    return col;
}

vec2 screenToWorld(vec2 screenPos)
{
    vec2 uv = screenPos.xy / iResolution.xy - vec2(0.5);
    uv *= vec2(iResolution.x/iResolution.y, 1.0);
    uv += vec2(0.4, 0.0);
    return uv;
}        

vec3 addBlackDot(vec3 col, vec2 worldUV, vec2 selection, vec3 dotcolor)
{
    vec2 difSelection = selection*0.27-worldUV;
    col = mix(vec3(1.0), col, smoothstep(0.01,0.015,sqrt(dot(difSelection,difSelection))));
    col = mix(dotcolor, col, smoothstep(0.008,0.01,sqrt(dot(difSelection,difSelection))));
    return col;
}


vec3 addLumSatBlackDot(vec3 col, vec2 worldUV, vec2 selection)
{
    vec2 difSelection = selection*0.2-worldUV;
    col = mix(vec3(1.0), col, smoothstep(0.007,0.01,sqrt(dot(difSelection,difSelection))));
    col = mix(vec3(0.0), col, smoothstep(0.005,0.007,sqrt(dot(difSelection,difSelection))));
    return col;
}

vec2 rotate(vec2 xy, float angle)
{
    float sn = sin(angle);
    float cs = cos(angle);
    return vec2(xy.x*cs-xy.y*sn, xy.y*cs + xy.x*sn);
}

float degToRad(float angle)
{
    return angle * pi * (1.0/180.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = screenToWorld(fragCoord.xy);
    vec2 hueSelection = screenToWorld(iMouse.xy);
    
    hueSelection = normalize(hueSelection);
    vec2 worldUV = uv;
    
    
    
    float d = sqrt(dot(uv,uv));
    uv = normalize(uv);
    
    
    vec3 useCol = baseColor(hueSelection);
    vec3 colHSV = rgb2hsv(useCol);
    vec3 extremityCol = hsv2rgb(vec3(colHSV.r, uv*0.5+0.5));
       
      
   	// mix left
    vec3 col = mix(mix(useCol, extremityCol, d*5.0), baseColor(uv), smoothstep(0.195,0.2,d)); // blend palette SV with round H
    col = mix(col, vec3(0.0),  smoothstep(0.345,0.35,d));
    
    // palette position
    vec2 paletteCenter = vec2(0.8,0.0);
    vec2 dt = paletteCenter - worldUV;
    
    float angle = atan(dt.y, dt.x)/(pi*2.0) + 0.5;
    
    vec3 colPalette=vec3(0.0);
    
    float angles[4];
    angles[0] = 0.0;
	angles[1] = gradientAngle;
    angles[2] = 180.0;
    angles[3] = 180.0+gradientAngle;
    
    float distPalette = sqrt(dot(dt,dt));
    for (int i=0;i<4;i++)
    {
        vec2 dir = rotate(hueSelection, degToRad(angles[i]));
		float ifl = float(i);
        
        // black dots
        col = addBlackDot(col, worldUV, dir, vec3((i==0)?0.4:0.0));

        
        vec3 colPaletteBase = mix(colPalette, baseColor(dir), smoothstep(0.25*ifl, 0.25*ifl, angle));
        float gradientH = rgb2hsv(colPaletteBase).r;
        // LumSat
        float lumSatAngleRad = degToRad(lumSatAngle);
        for (int i=0;i<5;i++)
        {
            float ifl = float(i);
            vec2 lumSatPos = lumSatOffset + vec2(cos(lumSatAngleRad),sin(lumSatAngleRad)) * lumSatFactor * (-1.0 + 0.5*ifl);
            col = addLumSatBlackDot(col, worldUV, lumSatPos);
            
            // variation on gradient

            vec3 variation = hsv2rgb(vec3(gradientH, lumSatPos+1.0));
            colPalette = mix(colPalette, variation, smoothstep(0.19*ifl, 0.2*ifl, distPalette*(1.0/0.345)));
        }
     
    }    
    // mix right
    col = mix(colPalette, col, smoothstep(0.345,0.35, distPalette));
    
	fragColor = vec4(col,1.0);
}