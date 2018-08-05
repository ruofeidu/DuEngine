// MddfzN
// Creates a line segment:
// p - coordinate system
// a - position of segment
// b - angle of segment
// w - width of segment
float lineSegment(vec2 p, vec2 a, vec2 b, float w) 
{
    vec2 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return smoothstep(0.0, w, length(pa - ba*h));
}

// Creates the line segment and
// movement for the second hand
float secondHand(vec2 uv)
{
    float secondHand;
    float second = mod(iDate.w, 60.0);
    float angle = -second * 2.0 * 3.14159 / 60.0 + + (3.14159/2.0);	// Converts from time to radians
    secondHand = 1.0 - lineSegment(uv, vec2(0.0, 0.0), 0.31 * vec2(cos(angle), sin(angle)), .005);
    return secondHand;
}

// Creates the line segment and
// movement for the minute hand
float minuteHand(vec2 uv)
{
    float minuteHand;
    float minute = mod(iDate.w/60.0, 60.0);	// Converts time in seconds to minutes
    float angle = -minute * 2.0 * 3.14159 / 60.0 + (3.14159/2.0);
    minuteHand = 1.0 - lineSegment(uv, vec2(0.0, 0.0), .25 * vec2(cos(angle), sin(angle)), .005);
    return minuteHand;
}

// Creates the line segment and
// movement for the hour hand
float hourHand(vec2 uv)
{
    float hourHand;
    float hour = mod(iDate.w/3600.0, 24.0);
    float angle = -hour * 2.0 * 3.14159 / 12.0 + (3.14159/2.0);
    hourHand = 1.0 - lineSegment(uv, vec2(0.0, 0.0), .19 * vec2(cos(angle), sin(angle)), .005);
    return hourHand;
}

// Creates a circle:
// uv - coordinate system
// p - position
// r - radius of circle
// blur - blur
float circle(vec2 uv, vec2 p, float r, float blur)
{
    float d = length(uv-p);
    float c = smoothstep(r, r-blur, d);
    return c;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Recenter coordinate system so that
    // the center of the screen is (0., 0.)
    vec2 uv = fragCoord/iResolution.xy;
    uv = uv - 0.5;
    uv.x *= iResolution.x/iResolution.y;

    //Drawing of the clock outline
    vec3 col;
    col = vec3(0.0);
    float disc = circle(uv, vec2(0.0, 0.0), 0.35, 0.01);
    disc -= circle(uv, vec2(0.0, 0.0), 0.34, 0.01);
    col = vec3(1.0, 1.0, 1.0)*disc;
    
    // Drawing of the hands
    col += vec3(0.0, secondHand(uv), secondHand(uv));
    col += vec3(0.0, minuteHand(uv), 0.0);
    col += vec3(hourHand(uv), 0.0, hourHand(uv));
    
    // Variation in screen color
    //col -= vec3(cos(iTime*.5)*.25, cos(iTime*.75)*.25, sin(iTime*.75));
	col -= 0.5*cos(.75*iTime+uv.xyx+vec3(2.0,2.0,2.0));
    
    // Output to screen
    fragColor = vec4(col,1.0);
}