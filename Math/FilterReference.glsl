// https://www.shadertoy.com/view/XtVcWc
//Survey of useful filters by nmz (twitter: @stormoid)

//The MIT License
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//Turned off by default to help visualize the kernels, should be done before using the filters
//#define SINC_MULTIPLY
//N.B. The Lanczos and Mitchell-Netravali filters have an internal sinc() multiplication 

/*
	Included filters:
		Smoothstep based
		Quintic smoothstep basef
		Lanczos (mostly historical)
		Mitchell-Netravali (fixed width 3, great for bicubic filtering)
		Max filter (useful parameterization)
		Triangular (2nd order B-spline)
		Parzen (4th order B-spline)
		Hann (cosine sum window)
		Hamming (cosine sum window)
		Blackman (cosine sum window)
		Nuttall (cosine sum window, C1 continuous)
		Tukey (tapered cosine window)
		Cook (truncated gaussian)
		Blackman-Nuttall (cosine sum window)
		Blackman-Harris (cosine sum window)

	References:
		https://developer.nvidia.com/gpugems/GPUGems/gpugems_ch24.html
		https://web.archive.org/web/20120122064506/http://www.control.auc.dk/~awkr00/graphics/filtering/filtering.html
		https://en.wikipedia.org/wiki/Window_function
*/


float sqr(float x){return x*x;}
float cub(float x){return x*x*x;}

float quintic(float a, float b, float x)
{
    x = clamp((x - a) / (b - a), 0.0, 1.0);
	return x*x*x*(x*(x*6.0 - 15.0) + 10.0);
}

float mitchellNetravali(float x, float B, float C)
{
	float ax = abs(x);
    float ax3 = ax*ax*ax;
    if (ax < 1.) 
    {
        return ((12. - 9. * B - 6. * C) * ax * ax * ax +
                (-18. + 12. * B + 6. * C) * ax * ax + (6. - 2. * B)) / 6.;
    } 
    else if ((ax >= 1.) && (ax < 2.)) 
    {
        return ((-B - 6. * C) * ax * ax * ax +
                (6. * B + 30. * C) * ax * ax + (-12. * B - 48. * C) *
                ax + (8. * B + 24. * C)) / 6.;
    } 
    else
    {
        return 0.;
    }
}

//Max filter: https://web.archive.org/web/20120122064506/http://www.control.auc.dk/~awkr00/graphics/filtering/filtering.html
float maxFilt(float x, float w, float s)
{
    x = abs(x);
    if (abs(x) > w || x < 0.)
        return 0.;
    else if(x <= s)
        return 1. - (x*x)/(s*w);
    else
        return (w-x)*(w-x)/(w*(w-s));
}

float sinc(float x)
{
    float pix = 3.14159265358979*x;
    return sin(pix)/(pix+1e-9);
}

//The following kernels are sinc windows (attenuating sinc to 0 at the edges)
float lanczos(float x, float w)
{
    if (abs(x) < w)
    return sinc(x)*sinc(x/w);
    else
    	return 0.;
}

float hann(float x, float w)
{
    const float pi = 3.14159265358979;
    if (abs(x) > w)
        return 0.;
    return 0.5-0.5*cos(pi*x/w + pi);
}

float hamming(float x, float w)
{
    const float pi = 3.14159265358979;
    if (abs(x) > w)
        return 0.;
    //return 0.54-0.46*cos(pi*x/w + pi);
    return 0.53836 - 0.46164*cos(pi*x/w + pi);
}

float blackman(float x, float w)
{
    const float pi = 3.14159265358979;
    if (abs(x) > w)
        return 0.;
    return 0.42-0.5*cos(pi*x/w + pi) + 0.08*cos(2.*pi*x/w);
}


//C1 continuous
float nuttall(float x, float w)
{
    const float pi = 3.14159265358979;
    if (abs(x) > w)
        return 0.;
    return 0.355768 - 0.487396*cos(pi*x/w + pi) + 0.144232*cos(2.*pi*x/w) - 0.012604*cos(3.*pi*x/w + pi*3.);
}

float tukey(float x, float w, float a)
{
    w *= 2.0;
    x += w*0.5;
    const float pi = 3.14159265358979;
    float xoa = 2.*x/(a*w);
    if (x < 0. || abs(x) > w)
        return 0.;
    if (x < a*w*0.5)
        return 0.5*(1.+cos(pi*(xoa-1.)));
    else if (x < w*(1.-a*0.5))
        return 1.;
    else
        return 0.5*(1.+cos(pi*(xoa - 2./a + 1.)));
}

float parzen(float x, float w)
{
    float nx = abs(x);
    if (nx > w)
        return 0.;
   	else if (nx <= w/2.)
    	return 1.0 - 6.0*sqr(x/w)*(1.0 - nx/w);
    else
        return 2.0*cub(1.0 - nx/w);
}

//Cook filter (truncated Gaussian)
//not shown
float cook(float x, float w)
{
    const float e = 2.718281828459;
    if (abs(x) > w)
        return 0.;
	return pow(e,-x*x)-pow(e,-w*w);
}

//not shown
float blackman_nuttall(float x, float w)
{
    const float pi = 3.14159265358979;
    if (abs(x) > w)
        return 0.;
    return 0.3635819 - 0.4891775*cos(pi*x/w + pi) + 0.1365995*cos(2.*pi*x/w) - 0.0106411*cos(3.*pi*x/w + pi*3.);
}

//not shown
float blackman_harris(float x, float w)
{
    const float pi = 3.14159265358979;
    if (abs(x) > w)
        return 0.;
    return 0.35875 - 0.48829*cos(pi*x/w + pi) + 0.14128*cos(2.*pi*x/w) - 0.01168*cos(3.*pi*x/w + pi*3.);
}

//not shown
float triangular(float x, float w)
{
    if (abs(x) > w)
        return 0.;
    return 1.-abs(x/w);
}

float f(float x, float w, int type)
{
    float rz= 0.;
    switch (type){
        case 0: rz = smoothstep(w,0., abs(x)); break;
        case 1: rz = quintic(w,0., abs(x)); break;
        case 2: rz = lanczos(x, w); break;
        case 3: rz = maxFilt(x, w, 0.5); break;
        case 4: rz = parzen(x, w); break;
        case 5: rz = hann(x, w); break;
        case 6: rz = hamming(x, w); break;
        case 7: rz = blackman(x, w); break;
        case 8: rz = nuttall(x, w); break;
        case 9: rz = tukey(x, w, 0.95); break;
        case 10: rz = mitchellNetravali(x, 0.3333, 0.3333); break;
    }

    //Bonus filters!
    //rz = triangular(x, w);
    //rz = blackman_nuttall(x, w);
    //rz = blackman_harris(x, w);
    //rz =cook(x, w);    
    //rz = mitchellNetravali(x, 1., 0.); //Cubic B-spline
    //rz = mitchellNetravali(x, 0., 0.5); //Catmull-rom
    
    #ifdef SINC_MULTIPLY
    if (type != 2 && type != 10)
    	return rz*sinc(x);
    else
        return rz;
    #else
    return rz;
    #endif
}

float smoothPlot(vec2 p, float w, int type)
{
    float v = f(p.x, w, type)-p.y;
	float e = 0.1;
    float g = 0.1 + sqr(f(p.x + e, w, type) - f(p.x - e, w, type));
    return float(smoothstep(0., .035, abs(v)/sqrt(g)));
}

float derivPlot(vec2 p, float w, int type)
{
    float e = 0.01;
    float dr = (f(p.x+e, w, type) - f(p.x-e, w, type))/(e*2.);
    return smoothstep(0.01,.0, abs(dr-p.y));
}

#define chr(A) col -= getChar(pp, A),pp.x-=0.5

//for codes see: https://www.shadertoy.com/view/ldSBzd
float getChar(vec2 p, int _char)
{
	vec2 pos = vec2(_char%16, 15 - _char / 16);
	pos += clamp(p, 0.001, 0.999);
	return textureLod(iChannel0, pos/16., 0.).r;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 q = fragCoord/iResolution.xy;
    vec2 p = q-0.5;
    p.x *= iResolution.x/iResolution.y;
    vec2 mo = iMouse.xy/iResolution.xy;
    
    int type = int(iTime*0.5)%11;
    
    if (textureLod(iChannel1, q, 0.).x > 0.5)
    	type = int(mo.x*11.);

    p *= 3.37;
    p.y += 0.25;
    float w = 3. - mo.y*2.;
    float rz = smoothPlot(p, w, type);
    vec3 col = vec3(rz)*vec3(0.975,.985,0.995);
    
#if 1
   //Grid 
    col -= smoothstep(0.018,0.0, abs(p.x-0.005))*vec3(.25,0.17,0.02);
    col -= smoothstep(0.018,0.0, abs(p.y-0.005))*vec3(.25,0.17,0.02);
    vec2 rp = mod(p,1.)-0.005;
    col -= smoothstep(0.01,0.0, abs(rp.x))*vec3(.25,0.15,0.02);
    col -= smoothstep(0.01,0.0, abs(rp.y))*vec3(.25,0.15,0.02);
    if (type != 10)
    	col -= smoothstep(0.01,0.0, abs(abs(p.x)-w))*vec3(.02,0.3,0.25);
#endif
    
    vec2 wd = 35./iResolution.xy;
    vec2 lc = vec2(9,7)*wd;
    
    vec2 pp = (p + vec2(3.,-1.7))*4.2;
    switch (type){
        case 0:  //Smoothstep
            chr(83);chr(109);chr(111);chr(111);chr(116);
            chr(104);chr(115);chr(116);chr(101);chr(112);
            break;
        case 1: //Quintic
            chr(83);chr(109);chr(111);chr(111);chr(116);chr(104);
            chr(101);chr(114);chr(115);chr(116);chr(101);chr(112);
            break;
        case 2: //Lanczos
            chr(76);chr(97);chr(110);chr(99);chr(122);chr(111);chr(115);
            break;
        case 3: //Max Filter
            chr(77);chr(97);chr(120);pp.x-=0.5;
        	chr(70);chr(105);chr(108);chr(116);chr(101);chr(114);pp.x-=0.5;
        	chr(115);chr(61);chr(48);chr(46);chr(53);
            break;
        case 4: //Parzen
            chr(80);chr(97);chr(114);chr(122);chr(101);chr(110);
            break;
        case 5: //Hann
            chr(72);chr(97);chr(110);chr(110);
            break;
        case 6: //Hamming
            chr(72);chr(97);chr(109);chr(109);chr(105);chr(110);chr(103);
            break;
        case 7: //Blackman
            chr(66);chr(108);chr(97);chr(99);chr(107);chr(109);chr(97);chr(110);
            break;
        case 8: //Nuttall
            chr(78);chr(117);chr(116);chr(116);chr(97);chr(108);chr(108);
            break;
        case 9: //Tukey
            chr(84);chr(117);chr(107);chr(101);chr(121);
        	pp.x-=0.5;chr(97);chr(61);chr(48);chr(46);chr(57);chr(53);
            break;
        case 10: //Mitchell-Netravali
            chr(77);chr(105);chr(116);chr(99);chr(104);chr(101);chr(108);chr(108);chr(45);
        	chr(78);chr(101);chr(116);chr(114);chr(97);chr(118);chr(97);chr(108);chr(105);
        	pp.x-=0.5;chr(98);chr(61);chr(49);chr(47);chr(51);
        	pp.x-=0.5;chr(99);chr(61);chr(49);chr(47);chr(51);
            break;
    }
    
    col -= derivPlot(p, w, type)*vec3(0.7,0.3,0.7);
    
    col *= (smoothstep(0.26,.25,(fract(sin(dot(p.x, p.y))*150130.1)))*0.03+0.97)*vec3(1.005,1.,0.99);
    col *= clamp(pow( 256.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.09 ),0.,1.)*0.3+0.7;

    fragColor = vec4(col,1.0);
}