// https://www.shadertoy.com/view/4sccWr
// Into You - by Martijn Steinrucken aka BigWings - 2018
// countfrolic@gmail.com
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// You can change the focal plane by moving the mouse up and down.

// A video of the effect can be found here:
// https://www.youtube.com/watch?v=lrMiME82Cuk

// Making of video part1:
// https://www.youtube.com/watch?v=dXyPOLf2MbU

// Android Phone Wallpaper:
// https://play.google.com/store/apps/details?id=com.TheArtOfCode.FallingHearts

// Music - Novo Amor - Anchor
// https://soundcloud.com/mrsuicidesheep/novo-amor-anchor


#define S(a, b, t) smoothstep(a, b, t)
#define sat(x) clamp(x, 0., 1.)
#define HEARTCOL vec3(1., .01, .01)
#define NUM_HEARTS 50.
#define LIGHT_DIR vec3(.577, -.577, -.577)

// Polynomial smooth max from IQ
float smax( float a, float b, float k ) {
	float h = sat( .5 + .5*(b-a)/k );
	return mix( a, b, h ) + k*h*(1.-h);
}

// Quaternion rotation functions from Ollj
vec4 qmulq(vec4 q1, vec4 q2){return vec4(q1.xyz*q2.w+q2.xyz*q1.w+cross(q1.xyz,q2.xyz),(q1.w*q2.w)-dot(q1.xyz,q2.xyz));}
vec4 aa2q(vec3 axis, float angle){return vec4(normalize(axis)*sin(angle*0.5),cos(angle*0.5));}
vec4 qinv(vec4 q){return vec4(-q.xyz,q.w)/dot(q,q);}
vec3 qmulv(vec4 q, vec3 p){return qmulq(q,qmulq(vec4(p,.0),qinv(q))).xyz;}

vec2 RaySphere(vec3 rd, vec3 p) {
    float l = dot(rd, p);
    float det = l*l - dot(p, p) + 1.;
    if (det < 0.) return vec2(-1);

    float sd = sqrt(det);
    return vec2(l - sd, l+sd);
}

struct sphereInfo {
	vec3 p1, p2, n1, n2;
    vec2 uv1, uv2;
};

sphereInfo GetSphereUvs(vec3 rd, vec2 i, vec2 rot, vec3 s) {
	sphereInfo res;
    rot *= 6.2831;
    vec4 q = aa2q(vec3(cos(rot.x),sin(rot.x),0), rot.y);
    vec3 o = qmulv(q, -s)+s;
    vec3 d = qmulv(q, rd);
    
    res.p1 = rd*i.x;
    vec3 p = o+d*i.x-s;
    res.uv1 = vec2(atan(p.x, p.z), p.y);
    res.n1 = res.p1-s;
    
    res.p2 = rd*i.y;
    p = o+d*i.y-s;
    res.uv2 = vec2(atan(p.x, p.z), p.y);
    res.n2 = s-res.p2;
        
    return res;
}

float Heart(vec2 uv, float b) {
	uv.x*=.5;
    float shape = smax(sqrt(abs(uv.x)), b, .3*b)*.5;
    uv.y -= shape*(1.-b);

    return S(b, -b, length(uv)-.5);
}

vec4 HeartBall(vec3 rd, vec3 p, vec2 rot, float t, float blur) {
    vec2 d = RaySphere(rd, p);
    
   	vec4 col = vec4(0);
    if(d.x>0.) {
    	sphereInfo info = GetSphereUvs(rd, d, rot, p);
    	
        float sd = length(cross(p, rd));
        float edge =  S(1., mix(1., 0.1, blur), sd);
        
        float backMask = Heart(info.uv2, blur)*edge; 
        float frontMask = Heart(info.uv1, blur)*edge; 
        float frontLight = sat(dot(LIGHT_DIR, info.n1)*.8+.2);
        float backLight = sat(dot(LIGHT_DIR, info.n2)*.8+.2)*.9;

        col = mix(vec4(backLight*HEARTCOL, backMask), 
                  vec4(frontLight*HEARTCOL, frontMask), 
                  frontMask);
    }
    return col;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy-.5*iResolution.xy) / iResolution.y;
    vec2 m = iMouse.xy/iResolution.xy;
    float t = iTime*.3;
  
    vec3 rd = normalize(vec3(uv, 1));
    
    m.y = iMouse.z>0. ? 1.-m.y : .4;

    vec2 rot = t*vec2(.12, .18);
    vec4 col = vec4(0);
        
    for(float i=0.; i<1.; i+=(1./NUM_HEARTS)) {
        float x = (fract(cos(i*536.3)*7464.4)-.5)*15.;
        float y = (fract(-t*.2+i*7.64)-.5)*15.;
        float z = mix(14., 2., i);
        
        float blur = mix(.03, .35, S(.0, .4, abs(m.y-i)));
        
        rot += (fract(sin(i*vec2(536.3, 23.4))*vec2(764.4, 987.3))-.5);
        vec4 heart = HeartBall(rd, vec3(x, y, z), rot, t, blur);
        
        col = mix(col, heart, heart.a);
    }
	
    fragColor = col;
}
