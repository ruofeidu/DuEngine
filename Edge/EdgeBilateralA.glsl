// https://www.shadertoy.com/view/MlG3WG
#define SIGMA 10.0
#define BSIGMA 0.1
#define MSIZE 15

float kernel[MSIZE];

float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

float normpdf3(in vec3 v, in float sigma)
{
	return 0.39894*exp(-0.5*dot(v,v)/(sigma*sigma))/sigma;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    if (iFrame < 10) {
        vec3 c = texture(iChannel0, (fragCoord.xy / iResolution.xy)).rgb;
        //declare stuff
        const int kSize = (MSIZE-1)/2;
        kernel[0] = 0.031225216;
        kernel[1] = 0.033322271;
        kernel[2] = 0.035206333;
        kernel[3] = 0.036826804;
        kernel[4] = 0.038138565;
        kernel[5] = 0.039104044;
        kernel[6] = 0.039695028;
        kernel[7] = 0.039894000;
        kernel[8] = 0.039695028;
        kernel[9] = 0.039104044;
        kernel[10] = 0.038138565;
        kernel[11] = 0.036826804;
        kernel[12] = 0.035206333;
        kernel[13] = 0.033322271;
        kernel[14] = 0.031225216;

        /*
        //create the 1-D kernel
        for (int j = 0; j <= kSize; ++j) {
            kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), SIGMA);
        }
        */

        vec3 final_colour = vec3(0.0);
        float Z = 0.0;

        vec3 cc;
        float factor;
        float bZ = 1.0/normpdf(0.0, BSIGMA);
        //read out the texels
        for (int i = -kSize; i <= kSize; ++i)
        {
            for (int j = -kSize; j <= kSize; ++j)
            {
                cc = texture(iChannel0, (fragCoord.xy+vec2(float(i),float(j))) / iResolution.xy).rgb;
                factor = normpdf3(cc-c, BSIGMA) * bZ * kernel[kSize+j] * kernel[kSize+i];
                Z += factor;
                final_colour += factor*cc;

            }
        }
        fragColor = vec4(final_colour/Z, 1.0);
    } else {
        fragColor = vec4(texture(iChannel1, (fragCoord.xy / iResolution.xy)).rgb, 1.0);
    }
}