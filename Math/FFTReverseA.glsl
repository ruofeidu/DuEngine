// 
#define FFT_SIZE 256
#define PI 3.14159265359

#define avg(v) ((v.x+v.y+v.z)/3.0)

vec2 fft(vec2 uv)
{
    vec2 complex = vec2(0,0);
    
    uv *= float(FFT_SIZE);
    
    float size = float(FFT_SIZE);
    
    for(int x = 0;x < FFT_SIZE;x++)
    {
    	for(int y = 0;y < FFT_SIZE;y++)
    	{
            float a = 2.0 * PI * (uv.x * (float(x)/size) + uv.y * (float(y)/size));
            vec3 sample2 = texture(iChannel0,mod(vec2(x,y)/size,1.0)).rgb;
            complex += avg(sample2)*vec2(cos(a),sin(a));
        }
    }
    
    return complex;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec3 color = vec3(0.0);
    
    uv+=1.;
	uv/=2.;
    color = vec3(fft(uv-.5).xy,0.)/float(FFT_SIZE);
    
    uv = fragCoord.xy / iResolution.xy;
    
	fragColor = vec4(color,1.0);
}
