// https://www.shadertoy.com/view/4d2cDy
#define PI 3.14159265358

mat3 rotx(float a) { mat3 rot; rot[0] = vec3(1.0, 0.0, 0.0); rot[1] = vec3(0.0, cos(a), -sin(a)); rot[2] = vec3(0.0, sin(a), cos(a)); return rot; }
mat3 roty(float a) { mat3 rot; rot[0] = vec3(cos(a), 0.0, sin(a)); rot[1] = vec3(0.0, 1.0, 0.0); rot[2] = vec3(-sin(a), 0.0, cos(a)); return rot; }
mat3 rotz(float a) { mat3 rot; rot[0] = vec3(cos(a), -sin(a), 0.0); rot[1] = vec3(sin(a), cos(a), 0.0); rot[2] = vec3(0.0, 0.0, 1.0); return rot; }

vec3 lightDir = normalize(vec3(0.0, 1.0, 1.0));

float hash( vec2 p ) {
    return fract(sin(dot(p,vec2(1177.1,2711.7)))*43758.5453123);
}

float noise( in vec2 p ) {
    vec2 i = floor( p );
    vec2 f = fract( p );
	vec2 u = f * f * (3.0-2.0 * f);
    return mix( mix( hash( i + vec2(0.0,0.0) ),
                     hash( i + vec2(1.0,0.0) ), u.x),
                mix( hash( i + vec2(0.0,1.0) ),
                     hash( i + vec2(1.0,1.0) ), u.x), u.y);
}


float wv(in vec2 uv, vec2 d, float t, float A)
{
    return (sin ( dot(d, uv) / 4.0 + t)) * A;
}


float fbmClouds(in vec2 uv)
{
    uv *= 1.0;

    float f = texture(iChannel3, uv).r ;

    // whipping up the clouds a little so they would not look too much like generic fbm
	vec2 _uv = uv*10.;
    mat2 rm  = mat2 (vec2(-sin(f+_uv.y), cos(f+_uv.x)), vec2(cos(f+_uv.y), sin(f+_uv.x)));
    uv += .1*uv*rm;

    f*=.5;
    f += texture(iChannel3, uv*2.0).r * 0.5*0.5;
    f += texture(iChannel3, uv*4.0).r * 0.5*0.5*0.5;
    f += texture(iChannel3, uv*32.0).r * 0.5*0.5*0.5*0.5*0.5;//*0.5;
    f += texture(iChannel3, uv*8.0).r * 0.5*0.5*0.5*0.5;
    f += texture(iChannel3, uv*64.0).r * 0.5*0.5*0.5*0.5*0.5;//*0.5;
    return f;
}

// water
float fbm(in vec2 uv, float lod)
{
    float f =  textureLod(iChannel2, uv, lod).r * 0.5;
    	  f += textureLod(iChannel2, uv*2.0, lod).r * 0.5*0.5;
    	  f += textureLod(iChannel2, uv*4.0, lod).r * 0.5*0.5*0.5;
    	  f += textureLod(iChannel2, uv*8.0, lod).r * 0.5*0.5*0.5*0.5;

    f = f*f*f*f;
    return f;
}

float wavesLo(const in vec3 rp, float t, float A, float lod)
{
    vec2 uv = rp.xz;

    uv.y += pow(max(rp.y + 0.4, 0.0), 10.) * 1.5;
    float w00 = noise(uv * 1.2 * vec2(.2,  2.2) + vec2(0.20 * t, t * 1.5));
    float w01 = fbm(uv*.05+vec2(0.0, iTime*.01), lod);
    float w02 = fbm(uv*.1 +vec2(iTime*.002, iTime*.014), lod);
    return w00*.12+w01*.1+w02*.1;
}

// high detail waves
float waves(const in vec3 rp, float t, float A)
{
    vec2 uv = rp.xz;
    vec2 nuv2 = uv+0.05*vec2(noise(uv*5.+t*.03), noise(uv*2.+t*.04));

    float w3 = wv(nuv2 * 170.0, vec2( -0.1, 0.6), t * 4.5, A) * 0.03;
	float w4 = wv(nuv2 * 170.0, vec2( 0.1, 0.6) , t * 6.,  A) * 0.03;
    float w7 = wv(nuv2 * 570.0, vec2( 0.05, 0.4), t * 15., A) * 0.02;
    float w8 = wv(nuv2 * 570.0, vec2( -0.05, 0.3) , t * 15.,  A) * 0.02;
    float w5 = -wv(nuv2 * 1670.0, vec2(-0.1, 0.4), t * 63., A) * 0.007;
    float w6 = -wv(nuv2 * 1670.0, vec2( 0.1, 0.5) ,  t * 63.,  A) * 0.007;

    return wavesLo(rp, t, A, 0.0) +w3+w4+w7+w8+w5+w6;
}

float mapLo(in vec3 rp)
{
    return rp.y - wavesLo(rp, 2.0+iTime*.5, .04, 4.0);
}


float map(in vec3 rp)
{
    return rp.y - waves(rp, 2.0+iTime*.5, .04);
}


vec3 grad(vec3 rp, float preci)
{
    vec2 off = vec2(preci, 0.0);
    vec3 g = vec3(map(rp + off.xyy) - map(rp - off.xyy),
				  map(rp + off.yxy) - map(rp - off.yxy),
				  map(rp + off.yyx) - map(rp - off.yyx));
    return normalize(g);
}

// scanning the surroundings for differences in heights on the heightmap
vec2 sub(vec3 rp, float preci)
{
    vec2 off = vec2(preci, 0.0);
    vec2 g = vec2(map(rp + off.xyy) + map(rp - off.xyy),
				  map(rp + off.yyx) + map(rp - off.yyx));
    return g;
}

// for the spec bump
vec3 texGrad(in vec2 uv)
{
    vec2 offset = vec2(0.01, 0.0);
    uv *= .5;
    float h0 = texture(iChannel0, uv).r;
    float h1 = h0-texture(iChannel0, uv+offset.xy).r;
    float h2 = h0-texture(iChannel0, uv+offset.yx).r;

    float bump = .4;
    vec3 g = cross(normalize(vec3(bump, h1, 0.0)), normalize(vec3(0.0, h2, bump)));
    return g;
}


const vec3 up = vec3(0.0, 1.0, 0.0);
const vec3 sun = normalize(vec3(0.0, 0.1, 1.0));
const vec3 horizonColor = vec3(.66, .9, 1.0);


void trace(in vec3 rp, in vec3 rd, inout vec4 color)
{
    // bg
    vec3 col = horizonColor;
    color.rgb = mix(col, vec3(0.3, 0.55, .96)*.9, smoothstep(-.15, .2, rd.y));

    // sun
    float s = pow(max(dot(rd, normalize(vec3(0.0, 0.7, 1.0))), 0.), 14.0);
    color.rgb += vec3(.9, .9, 1.0)*s*.3;
    vec3 sunCenterDir = normalize(vec3(0.0, 0.7, 1.0));
    vec3 diffV = rd-sunCenterDir;
    float diffVLen = length(diffV);

    color.rgb += max(0.0, smoothstep(.0, .3, .11-diffVLen));
    color.rgb += max(0.0, smoothstep(.0, .02, .03-diffVLen));;

    float a = atan(diffV.y, diffV.x);
    float st = iTime*.05;
    float sl = .8+.2*sin(iTime*.4);
    float cl = .8+.2*cos(iTime*.2);
    a += iTime*.01;
    color += smoothstep(0., .3, (.25*sl)-diffVLen)*max(0.0, .25-abs(sin(a*8.+st)))*(0.2+0.8*max(0., sin(a*2.)));
    color += smoothstep(0., .4, (.35*cl)-diffVLen)*max(0.0, .25-abs(sin(1.5+a*4.+st)))*(0.3+0.7*max(0., sin(a*3.)));


    // trace to plane on top of waves
    vec3 ro = rp;
    float t = -(0.155+dot(rp, -up)) / dot(-up, rd);
    if (t < 0.0)
    {
        return;
    }

	rp += rd*t;
    bool hit = false;
    float dist = 0.0;

    // actual tracing

    // low freq
    for (int i = 0; i < 55; ++i)
    {
        float travelledSq=dot(ro-rp, ro-rp);
        dist = mapLo(rp);

        if(dist < 0.01)
        {
            hit = true;
            break;
        }
        rp += rd * max(dist * (log2(2.+travelledSq)), 0.01);
        if(travelledSq > 9000.0) break;
    }

    //detail tracing
    for (int i = 0; i < 10; ++i)
    {
        rp += dist * rd;
        if (abs(dist) < 0.0001) break;
        dist = map(rp);
    }

    // shadings
    if(hit)
    {
        vec3 g = grad(rp, 0.002 * (1.0+log2(length(ro-rp) * 100.)));

        // base color
        color = vec4(.05, 0.22, .4, 0.0);

        // diffuse
        float d = max(0.0, dot(g, lightDir));
        color *= mix(1.0, d, .4);

        // top
        vec2 heights = sub(rp, 0.3);
        float sst = length(max(vec2(0.00001), heights));
        float sunD = -1.*(dot(sun, g));
        color.rgb = mix(color.rgb, vec3(.2, 0.5, 0.72)*.5, smoothstep(0., .4, sunD));

        // bottom
        float ssb = length(min(vec2(0.0), heights));
        color.rgb = mix(color.rgb, vec3(.05, 0.22, .4)*.5, smoothstep(0.0, 0.4, ssb));

        // foam
        vec3 pw = vec3(1.+2.3/(sst*1.+.001))*2.2;
        vec3 texcol1 = texture(iChannel0, rp.xz*.5+vec2(.0, .07*iTime)).rgb;

        vec3 pw2 = vec3(1.+.7/(sst*1.2+.01));
        vec3 texcol2 = texture(iChannel0, rp.xz*.5+vec2(.0, .07*iTime)).rgb*1.;

        color.rgb += max(pow(texcol1, pw).rrr, pow(texcol2, pw2).rrr);


        // fresnel
        vec3 H = normalize(-rd + normalize(sun));
        float F = clamp(max(0.0, 1.0+dot(rd, g)), 0., 1.);
        color.rgb += .2*pow(F, 6.)*textureLod(iChannel1, reflect(rd, g), 0.0).rgb;//*vec3(.45, .7, 1.);
        color.rgb += .4*pow(F, 5.)*vec3(.3, .5, .5)*.5;

        // spec
        // +bump
        vec3 tg =  texGrad (rp.xz*5.1 + vec2(-iTime*.15, iTime*.6));
        vec3 tg2 = texGrad (rp.xz*6.2 + vec2( iTime*.1,  iTime*.6));
        tg = normalize(tg+tg2);
        tg = normalize(tg+texGrad(rp.xz*4.2 + vec2( iTime*.01, iTime*.5))*0.3);

        vec3 sg = grad(rp, 0.001);
        sg = normalize(sg+tg*.3);

        H = normalize(-rd + normalize(vec3(0.0, 1.0, 1.5)));

        float specD = max(0.0, dot(H, sg));
        float spec =  pow(specD, 100.0);
        color.rgb += spec * vec3(1., .8, .7)*.7;
    }
    color.a = length(ro-rp);

}


mat3 lookat(vec3 from, vec3 to)
{
    vec3 f = normalize(to - from);
    vec3 _tmpr = normalize(cross(f, vec3(0.0, .999, 0.0)));
    vec3 u = normalize(cross(_tmpr, f));
    vec3 r = normalize(cross(u, f));
    return mat3(r, u, f);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = vec4(0.);
	vec2 uv = (fragCoord.xy-iResolution.xy*.5) / iResolution.x;
    vec2 im = 4.0 * ((iMouse.xy / iResolution.xy) - vec2(0.5));

    if (iMouse.z <= 0.0)
    {
        im = vec2(.1, .2);
    }

    vec3 rd = normalize(vec3(uv, (1.0-.2*length(uv))));
    vec3 rp = vec3(0.0, .3, -1.0);
    vec3 _rp = rp;
    rp = roty(im.x) * rp;

    mat3 lkat = lookat(rp, vec3(0.0, .0+im.y*1., 0.0));
    rd = lkat * rd;

    trace(rp, rd, fragColor);
    fragColor.rgb = mix(fragColor.rgb, horizonColor, 0.3 * smoothstep(0.05, 0., abs(rd.y-0.01)));

    ///////////////
    // clouds
    float t = -(6.5+dot(rp, -up)) / dot(-up, rd);
    if (t>0.)
    {
    	_rp += rd*t;
        vec2 cuv = iTime*.0004+_rp.xz*.001;
        float f = fbmClouds(cuv);
        float f3 = fbmClouds(cuv+vec2(0., -.007));
        f = max(0.0, f-0.5)/0.5;
        f3 = max(0.0, f3-0.5)/0.5;
        f3 = 1.+(f3-f)*.8;
        f3 = max(f3, .0);
        fragColor.rgb = mix(fragColor.rgb, f3*vec3(1.0-smoothstep(0.1, .6, f)*.1), f);
        fragColor.a = t;
	}
    fragColor.rgb = clamp(fragColor.rgb, 0.0, 1.0);
}
