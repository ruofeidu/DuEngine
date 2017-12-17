// https://www.shadertoy.com/view/4tfBWX
// Radius of points being drawn
const float RADIUS = 1.0;

// Offset from image border
const float OFFSET = 10.0;

// Seed for hash function
const vec2 SEED = vec2(0.5, 0.7);

// Speed: Number of points per second
const float SPEED = 50.0;

// Starting points
#define A scale(vec2(0.5, 1.0))
#define B scale(vec2(1.0, 0.0))
#define C scale(vec2(0.0, 0.0))

/**
 * Scale coordinates between 0.1 to the output image resolution, with the specified border offset.
 */
vec2 scale(vec2 coords) {
	return coords * (iResolution.xy - OFFSET * 2.0) + OFFSET;
}

/**
 * Return whether the `fragCoord` pair is within `RADIUS` of `point`.
 */
bool isPixel(vec2 fragCoord, vec2 point) {
	return distance(fragCoord, point) < RADIUS;
}

/**
 * Random function from http://shadertoy.wikia.com/wiki/Noise
 */
vec2 rand(vec2 p) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

/**
 * Randomly choose a point A, B or C with 1/3 probability.
 */
vec2 randABC(vec2 seed) {
    vec2 r = rand(seed);
    if (r.x < (1.0/3.0)) {
        return A;
    } else if (r.x < (1.0/3.0*2.0)) {
    	return B;
    } else {
        return C;
    }
}

/**
 * Return whether the `fragCoord` coordinate pair is a valid point in the
 * sequence of points derived from the `start` point.
 */
bool validPoint(vec2 fragCoord, vec2 start) {
    int iteration = int(iTime * SPEED); // Add 1 point per second
    
    if (isPixel(fragCoord, start)) {
        return true;
    }
    
    // We start at the starting point
    vec2 currentPoint = start;
    
    // Increment every second
    for (int i = 0; i < iteration; i++) {
        // First, derive a different seed for each iteration.
        vec2 seed = vec2(float(i) * 0.001, float(i) * 0.002 / 3.0);
        vec2 targetPoint = randABC(seed);
        currentPoint = currentPoint + ((targetPoint - currentPoint) / 2.0);
        if (isPixel(fragCoord, currentPoint)) {
        	return true;
        }
    }
    
    return false;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec4 red = vec4(1.0, 0.0, 0.0, 1.0);
    vec4 white = vec4(1.0, 1.0, 1.0, 1.0);
    vec4 black = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 color = vec4(fragCoord.xy / iResolution.xy * 1.4, 1.0, 1.0); // Nicer colors depending on XY coords

    // Random starting point
    vec2 R = scale(rand(SEED));
        
    // Determine whether this is a start point
    bool isStartPoint =
        isPixel(fragCoord, A) ||
        isPixel(fragCoord, B) ||
        isPixel(fragCoord, C);
    
    // Determine whether this is a valid point (depending on time)
    bool isValidPoint =
        validPoint(fragCoord, R);
    
    if (isStartPoint) {
    	fragColor = red;
    } else if (isValidPoint) {
        fragColor = color;
    } else {
        fragColor = black;
    }
}