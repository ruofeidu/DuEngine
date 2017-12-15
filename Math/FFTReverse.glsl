// 
#define FFT_SIZE 256
#define PI 3.14159265359
#define in_fft(uv) texture(iChannel0,uv).r
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    float a = 0.;
    float size = float(FFT_SIZE);
    for(int x = 0; x < FFT_SIZE; x++) {
    	for(int y = 0; y < FFT_SIZE; y++) {
            vec2 at = vec2(x,y)/size;
            a += cos(((uv.x*at.x)+(uv.y*at.y))*PI*size)*in_fft(at);
        }
    }
    
	fragColor = vec4(vec3(a/float(FFT_SIZE)),1.0);
}