// 
#define mainImage(o,U)														\
vec2 u = (U+U-(o.xy=iResolution.xy))/o.y*12.;								\
float l = dot(u,u)-2.,a = mod(atan(u.y,u.x)/.785 + ceil(8.*iTime) , 8.);	\
o += (a<1.?.843: fract(a)<.1 ? 0.:.396) - pow(l*l,9.)-o

// 184 chars - 834144373 showed that HIS Kung Fu is better than Fabrice's !! ;-P
/**
void mainImage(out vec4 o,vec2 u)
{
      float l = dot(u = (u+u-(o.xy=iResolution.xy))/o.y*12.,u)-2.,
            a = mod(atan(u.y,u.x)/.785 + ceil(8.*iTime) , 8.);   
      o += (a<1.?.843: fract(a)<.1 ? 0.:.396) - pow(l*l,9.)-o;
}
/**/

// 199 chars - Fabrice never fails to impress!
/**
void mainImage(out vec4 o,vec2 u)
{
      float l = dot(u = (u+u-(o.xy=iResolution.xy))/o.y*12.,u)-2.,
            a = mod(atan(u.y,u.x)/.785 + ceil(8.*iTime), 8.);   
      o += (a<1.?.843:.396) - pow(l*l,9.) - exp(40.*cos(a*6.3)-40.) -o;
}
/**/

// 171 chars - With some cheating and optimizations from Fabrice and 834144373
// May not work on all systems, but it works on my iMac
/**
void mainImage(out vec4 o,vec2 u)
{
    o += -pow(dot(u = (u+u-(u=iResolution.xy))/u.y*12.,u)-2.,18.) +
        ((o.a = mod(atan(u.y,u.x)/.785 + ceil(8.*iDate.w) , 8.))<1.?.8: fract(o.a)<.1 ? 0.:.4);
}
/**/

// 201 chars - 834144373 used Kung Fu to vanquish 8 more chars
/**
void mainImage(out vec4 o,vec2 u)
{
    float l = dot(u = (u+u-(u=iResolution.xy))/u.y*12.,u)-2.,
        a = mod(atan(u.y,u.x)/.785+4.+ceil(8.*iTime),8.),
        s = 9.*sin(a*3.14);
    o += (a<1.?.843:.396)-pow(l,18.)-exp(-s*s)-o;
}
/**/

// 209 chars - I further optizmized flockaroo's rewrite. I'm certain Fabrice will school me on this.
/**
void mainImage(out vec4 o,vec2 u)
{
    float l = 32.*length(u = (u+u-(o.xy=iResolution.xy))/o.y)-4.,
        a = mod(atan(u.y,u.x)/3.14*4.+4.+ceil(8.*iTime),8.),
        s = 9.*sin(a*3.14);
    o += (a<1.?.843:.396)-pow(l*l,9.)-exp(-s*s)-o;
}
/**/

// 219 chars - WOW! We have a new code golfing Jedi ... flockaroo killed it with a SERIOUS rewrite of the shader!
/**
void mainImage(out vec4 o,vec2 u)
{
    float p = 3.1415,
        l = 36.*length(u = (u+u-(o.xy=iResolution.xy))/o.y)-4.,
        a = mod(atan(u.y,u.x)/p*4.+4.+ceil(8.*iTime),8.),
        s = sin(a*p)*7.;
    o=vec4((1.-pow(l*l,4.)-exp(-s*s))*(a<1.?.84:.396));
}
/**/

// 262 chars - Using many optimizations from Fabrice:
/**
void mainImage(out vec4 o,vec2 u)
{
    float l = length(u = (u+u-(o.xy=iResolution.xy))/o.y),
        k = (.5+ceil(8.*iTime))*.7854,
        v = smoothstep(.03,.02,abs(l-.11))
              * smoothstep(0.,.17,abs(mod(atan(u.y,u.x)*2.546+1.,2.)-1.));
    o += (cos(k)*u.x-sin(k)*u.y < l*.92||v < 1. ? v*.396 : .84) -o;
}
/**/

// 291 chars - Original
/**
void mainImage(out vec4 o,vec2 u)
{
    float l = length(u = (u+u-(o.xy=iResolution.xy))/o.y),
        k = .3927+ceil(8.*iDate.w)/8.*6.283185307,
        v = smoothstep(.01,.0,abs(l-.11)-.02)
              * smoothstep(0.,.1,abs(mod(atan(u.y,u.x)*2.546+1.,2.)-1.)),
        c = cos(k),s = sin(k);
    o = vec4((mat2(c,s,-s,c)*u).x/l<.9239||v<1.? v*.396 : .843);
}
/**/