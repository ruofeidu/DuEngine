// https://www.shadertoy.com/view/XsBXDw
// key is javascript keycode: http://www.webonweboff.com/tips/js/event_key_codes.aspx
bool ReadKey( int key, bool toggle )
{
	float keyVal = texture( iChannel0, vec2( (float(key)+.5)/256.0, toggle?.75:.25 ) ).x;
	return (keyVal>.5)?true:false;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    int keyNum = 65 + int(uv.x * (90.0 - 65.0));
    bool toggle = uv.y > 0.1;
    
    vec4 keyColor = ReadKey(keyNum, toggle) ? vec4(1.0 - uv.y, 0.0, 0.0, 1.0) : vec4(0.0, 1.0 - uv.y, 0.0, 1.0);

    bool hozLine = abs(uv.x * 25.0 - float(int(uv.x * 25.0))) < 0.1;
    bool vertLine = abs(uv.y - 0.1) < 0.005;
    
	fragColor = (hozLine || vertLine) ? vec4(0.0, 0.0, 0.0, 1.0) : keyColor;
}
