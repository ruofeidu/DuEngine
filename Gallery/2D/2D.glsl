// https://www.shadertoy.com/view/llsBD2 
#define PI 3.141592653589793
#define PI2 6.283185307179586
#define PI4 12.566370614359172
#define PI_HALF 1.5707963267948966

const float fruitTiling = 4.0;
const float fruitDistanceThreshold = 0.45;
const float fruitTypeAnimSpeed = 1.2;
const float fruitTypeAnimHardness = 4.5;
const float edgeSoftness = 0.003;
const float backgroundSpeed = 0.03;
const float backgroundTiling = 10.0;

const vec3 colorBg[3] = vec3[](
    vec3(0.162, 0.557, 0.096), // Apple
    vec3(0.136, 0.483, 0.797), // Banana
    vec3(0.010, 0.345, 0.760)  // Orange
);
const vec3 colorPeel[3] = vec3[](
	vec3(0.406, 0.004, 0.008),
    vec3(0.615, 0.311, 0.006),
    vec3(0.714, 0.083, 0.0)
);
const vec3 colorPulp[3] = vec3[](
	vec3(0.964, 0.727, 0.321),
    vec3(0.917, 0.770, 0.215),
    vec3(0.823, 0.313, 0.030)
);
const vec3 colorSeeds[3] = vec3[](
    vec3(0.031, 0.009, 0.003),
    vec3(0.167, 0.092, 0.042),
    vec3(0.974, 0.800, 0.249)
);

const vec3 seedsCountFirstLast[3] = vec3[](
    vec3(8.0, 5.0, 7.0),
    vec3(5.0, 0.0, 5.0),
    vec3(7.0, 0.0, 6.0)
);
vec3 seedsStartLengthThickness[3] = vec3[](
    vec3(0.2, 0.2, 0.9),
    vec3(0.15, 0.1, 0.6),
    vec3(0.2, 0.2, 0.6)
);

vec3 mixThree(in vec3 valA, in vec3 valB, in vec3 valC, in float factor)
{
    vec2 twoFactors = vec2(factor) * 2.0 - vec2(0.0, 1.0);
    twoFactors = clamp(twoFactors, vec2(0.0), vec2(1.0));
    if (twoFactors.y > 0.0)
    {
        return mix(valB, valC, twoFactors.y);
    }
    else
    {
        return mix(valA, valB, twoFactors.x);
    }
}

vec3 mixThree(in vec3[3] values, in float factor)
{
    vec2 twoFactors = vec2(factor) * 2.0 - vec2(0.0, 1.0);
    twoFactors = clamp(twoFactors, vec2(0.0), vec2(1.0));
    if (twoFactors.y > 0.0)
    {
        return mix(values[1], values[2], twoFactors.y);
    }
    else
    {
        return mix(values[0], values[1], twoFactors.x);
    }
}

float remapClamped(in float rangeMin, in float rangeMax, in float newRangeMin, in float newRangeMax, in float value)
{
    float newVal = clamp((value - rangeMin) / (rangeMax - rangeMin), 0.0, 1.0);
    return mix(newRangeMin, newRangeMax, newVal);
}


float polarAngle01(in vec2 uv)
{
    float angle = atan(uv.x, uv.y);
    angle = remapClamped(-PI, PI, 0.0, 1.0, angle);
    return angle;
}

vec3 background(in vec2 uv, in float fruitType)
{
    vec2 bgUV = uv + vec2(iTime * backgroundSpeed);
    bgUV = (bgUV - vec2(0.5)) * backgroundTiling;
    
    bgUV = fract(bgUV) + vec2(0.5);
    bgUV = floor(bgUV);
    float mask = bgUV.x + bgUV.y;
    mask = ceil(clamp(mask, 0.0, 1.0)) - floor(mask * 0.5);
    mask = clamp(mask, 0.0, 1.0);
    
    vec3 bg = mixThree(colorBg, fruitType);
    bg = mix(bg, vec3(0.8) * bg, mask);
    return bg;
        
}

vec2 appleSpace(in vec2 uv)
{
    // "Perspective" scaling. Apple I want to form is more conical than spherical
 	float scaleOverV = remapClamped(-0.5, 0.4, 0.9, 1.6, uv.y);
    vec2 outUV = uv * vec2(scaleOverV, 1.0);
    
    // Making it concave at the "poles"
    float shape = cos(polarAngle01(uv) * PI4 + PI);
    shape = remapClamped(-1.0, 1.0, 0.0, 1.0, shape);
    shape = pow(shape, 0.25);
    shape = remapClamped(0.0, 1.0, 1.5, 1.0, shape);
    outUV *= vec2(shape);
    
    return outUV;
}

vec2 bananaSpace(in vec2 uv)
{
    // Squeezing the circle to a 6-sided polygon
    const float sides = 6.0;
    float shape = cos(polarAngle01(uv) * sides * PI2 + PI);
    shape = remapClamped(-1.0, 1.0, 0.0, 1.0, shape);
    shape = pow(shape, 1.4);
    shape = remapClamped(0.0, 1.0, 1.1, 1.0, shape);
    
    // Blending back to a circle slightly
    vec2 outUV = mix(uv, uv * vec2(shape), 0.5);
    outUV *= vec2(1.4); // Making it smaller
    return outUV;
}

vec2 orangeSpace(in vec2 uv)
{
    return uv * vec2(1.08);
}

float seeds(in vec2 uv, in float fruitType)
{
    // Offset V for apple seeds
    float appleFactor = 1.0 - clamp(fruitType * 2.0, 0.0, 1.0);
    uv.y += 0.077 * appleFactor;
    
    vec3 seedCount = mixThree(
        seedsCountFirstLast,
        fruitType
    );
    
    vec3 seedSize = mixThree(
        seedsStartLengthThickness,
        fruitType
    );
    
    vec2 polar = vec2(
        fract(polarAngle01(uv) + 0.25) * seedCount.x,
        distance(uv, vec2(0.0))
    ); 
    
    float seedsU = abs(fract(polar.x) - 0.5) / seedSize.z;
    float seedsV = remapClamped(
        seedSize.x - seedSize.y,
        seedSize.y,
        0.0,
        1.0,
        polar.y
    );
    vec2 seedsUV = vec2(seedsU, seedsV);
    
    float shape = distance(seedsUV, vec2(0.0, 0.5));
    
    vec2 masks = vec2(polar.x + 1.0);
    masks = floor(masks - seedCount.yz);
    masks = clamp(masks, vec2(0.0), vec2(1.0));
    float seedMask = masks.x * (1.0 - masks.y);
        
    shape = smoothstep(
        0.295 + edgeSoftness * 2.0,
        0.295 - edgeSoftness * 2.0,
        shape
    );
    return shape * seedMask;
}

float calcFruitType()
{
    float fruit = iTime * fruitTypeAnimSpeed;
    vec2 waves = vec2(fruit) + vec2(0.0, PI_HALF);
    waves = vec2(
        sin(waves.x),
        sin(waves.y)
    );
    waves *= fruitTypeAnimHardness;
    waves = clamp(waves, -1.0, 1.0);
    fruit = waves.x + waves.y;
    fruit = smoothstep(-2.0, 2.0, fruit);
    return fruit;
}

vec2 calcFruitUV(in vec2 uv, in float fruitType)
{
    vec2 twoFactors = vec2(fruitType) * 2.0 - vec2(0.0, 1.0);
    twoFactors = clamp(twoFactors, vec2(0.0), vec2(1.0));
    if (twoFactors.y > 0.0)
    {
        vec2 outUV = mix(
            bananaSpace(uv),
            orangeSpace(uv),
            twoFactors.y
        );
        return outUV;
    }
    else
    {
        vec2 outUV = mix(
            appleSpace(uv),
            bananaSpace(uv),
            twoFactors.x
        );
        return outUV;
    }
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{   
    float fruitType = calcFruitType();
    
    vec2 imageUV = fragCoord.xy / vec2(iResolution.x) + vec2(0.0, -1.0);
    vec3 bg = background(imageUV, fruitType);
    
	vec2 mainUV = fragCoord.xy / vec2(iResolution.x) * vec2(1.0, -1.0);
    mainUV = (mainUV + vec2(0.0, 0.15)) * vec2(fruitTiling);
    float uvOddRowMask = floor(mod(mainUV.y, 2.0));
    mainUV += vec2(mix(0.0, 0.5, uvOddRowMask), 0.0);
    mainUV = fract(mainUV) - vec2(0.5, 0.5);
    
    vec2 fruitUV = calcFruitUV(mainUV, fruitType);
    
    float dist = distance(fruitUV, vec2(0.0, 0.0));
    float peel = smoothstep(
        fruitDistanceThreshold + edgeSoftness,
        fruitDistanceThreshold - edgeSoftness,
        dist
    );
    float pulp = smoothstep(
        fruitDistanceThreshold - 0.05 + edgeSoftness,
        fruitDistanceThreshold - 0.05 - edgeSoftness,
        dist
    );
    
    vec3 outColor = mix(bg, mixThree(colorPeel, fruitType), peel);
    outColor = mix(outColor, mixThree(colorPulp, fruitType), pulp);
    float seedMask = seeds(mainUV, fruitType);
    outColor = mix(outColor, mixThree(colorSeeds, fruitType), seedMask);
    
    outColor = pow(outColor, vec3(0.4545)); // Gamma 2.2
	fragColor = vec4(outColor,1.0);
}
