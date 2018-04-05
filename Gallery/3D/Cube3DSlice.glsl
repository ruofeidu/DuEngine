// 
// Created by Sebastien Durand - 2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// To understand what it is, look at part "Where is the Inside?" at url:
// http://eusebeia.dyndns.org/4d/vis/09-interp-1

// less calcul and loop 
#define FAST 

//  0 nothing, 1 Cubinder, 2 Duo-Cylinder, 3 3-Sphere, 4 Tesseract,
#define SHAPE 4

const float RAYON = .02;
const vec3 C1 = vec3(.2,.9,1), C2 = vec3(1,.3,.5);  // Colors for w coord
const vec3 E = vec3(0,.001,0); // epsilon

vec3 L = normalize(vec3(0.6, 0.7, 0.5)); // light

mat4 B;
float WCurrent;

#ifdef FAST
vec4 v0000,v1000,v0100,v0010,v0001,v1100,v1010,v1001;
#endif

float hash(in float x) {
    return fract(sin(x * 171.2972) * 18267.978 + 31.287);
}

vec3 dmin(in vec3 v1, in vec3 v2) {
    return v1.x<v2.x ? v1 : v2;
}

vec4 mv4D;

// From 4D to 3D 
vec3 line4D(in vec3 p, vec4 p1, vec4 dp) {
    p1+=mv4D;
    //dp+=mv4D;
 	vec3 pa = p-p1.xyz, ba = dp.xyz;
    float k = clamp(dot(pa,ba)/dot(ba,ba),0., 1.);
    return vec3(length(pa - ba*k) - RAYON ,k, p1.w +k*dp.w);
}

#ifdef FAST
// FASTER like this but uggly and not working in firefox
vec3 sdTesserac(in vec3 p) {
     
	vec3 d;    
        d = // 000
            dmin(line4D(p, v0000, B[3]),
			dmin(line4D(p, v0000, B[2]),
		    dmin(line4D(p, v0000, B[1]), 
                 line4D(p, v0000, B[0]))));
        d = dmin(d, // 100
            dmin(line4D(p, v1000, B[3]),
			dmin(line4D(p, v1000, B[2]),
		    dmin(line4D(p, v1000, B[1]), 
                 line4D(p, v0100, B[0])))));
        d = dmin(d, // 010
            dmin(line4D(p, v0100, B[3]),
			dmin(line4D(p, v0100, B[2]),
		    dmin(line4D(p, v0010, B[1]), 
                 line4D(p, v0010, B[0])))));
        d = dmin(d, // 110
            dmin(line4D(p, v1100, B[3]),
			dmin(line4D(p, v1100, B[2]),
		    dmin(line4D(p, v1010, B[1]), 
                 line4D(p,-v1001, B[0])))));
        d = dmin(d, // 001
            dmin(line4D(p, v0010, B[3]),
			dmin(line4D(p, v0001, B[2]),
		    dmin(line4D(p, v0001, B[1]), 
                 line4D(p, v0001, B[0])))));
        d = dmin(d, // 101
            dmin(line4D(p, v1010, B[3]),
			dmin(line4D(p, v1001, B[2]),
		    dmin(line4D(p, v1001, B[1]), 
                 line4D(p,-v1010, B[0])))));
        d = dmin(d, // 011
            dmin(line4D(p,-v1001, B[3]),
			dmin(line4D(p,-v1010, B[2]),
		    dmin(line4D(p,-v1100, B[1]), 
                 line4D(p,-v1100, B[0])))));
        d = dmin(d, // 111
            dmin(line4D(p,-v0001, B[3]),
			dmin(line4D(p,-v0010, B[2]),
		    dmin(line4D(p,-v0100, B[1]), 
                 line4D(p,-v1000, B[0])))));    
	return d;
}
#else
// Tesserac projection (smartest but loop make it a little bit slower)
vec3 sdTesserac(in vec3 p) {
	vec3 d = vec3(100.,-1.,0.);
	vec4 k = vec4(-.5);    
	// Simple initialisation of the 32 Edges of tesserac 
	for (int i=0; i<8; i++) {
		k.x = mod(float(i),2.)-.5; k.y = mod(float(i/2),2.)-.5; k.z = mod(float(i/4),2.)-.5; 
        d = dmin(d,
            dmin(line4D(p, B*k    ,  B[3]),
			dmin(line4D(p, B*k.xywz, B[2]),
		    dmin(line4D(p, B*k.xwyz, B[1]), 
                 line4D(p, B*k.wxyz, B[0])))));
	}
	return d;
} 
#endif

// 4D box => Tesserac
float sdBox(in vec4 p, in vec4 b) {
  vec4 d = abs(p) - b;
  return min(max(d.x,max(d.y,max(d.z,d.w))),0.) + length(max(d,0.));
}

// 3-sphere (4d hypersphere)
float sdSphere( vec4 p, float s ) {
    return length(p)-s;
}

// http://eusebeia.dyndns.org/4d/cubinder
float sdCubinder(vec4 p, vec3 rh1h2) {
	vec3 d = abs(vec3(length(p.xz), p.y, p.w)) - rh1h2;
	return min(max(d.x,max(d.y,d.z)),0.) + length(max(d,0.));
}

// http://eusebeia.dyndns.org/4d/duocylinder
float sdDuoCylinder( vec4 p, vec2 r1r2) {
  vec2 d = abs(vec2(length(p.xz),length(p.yw))) - r1r2;
  return min(max(d.x,d.y),0.) + length(max(d,0.));
}


// x: distance, y : distance on segment, z : 4th dimension coord
vec3 map(vec3 p) {
    //p*=2.;
  //  vec3 d1 = vec3(1000);
  //  for (int u=0; u<4; u++) {
  //  	mv4D = B[u]; //vec4(1,0,0,0);
//	    d1 = dmin(d1,sdTesserac(p));
 //       mv4D = -B[u]; //vec4(1,0,0,0);
//	    d1 = dmin(d1,sdTesserac(p));
//    }
    mv4D = vec4(0);
    return dmin(sdTesserac(p), vec3(
#if SHAPE==0
        999.,
#elif SHAPE==1
        sdCubinder(vec4(p,WCurrent)*B, vec3(.5-RAYON*.5)),
#elif SHAPE==2 
        sdDuoCylinder(vec4(p,WCurrent)*B, vec2(.5-RAYON*.5)),
#elif SHAPE==3
        sdSphere(vec4(p,WCurrent)*B, .5),
#else        
        sdBox(vec4(p,WCurrent)*B, vec4(.5-RAYON*.5)),
#endif
        -.1, WCurrent));
}

// Classical AO calculation
float calcAO(in vec3 pos, in vec3 nor) {
    float hr=.01, ao=.0, sca=1.;
    for(int aoi=0; aoi<5; aoi++) {
        ao += -(map(nor * hr + pos).x-hr)*sca;
        sca *= .7;
        hr += .05;
    }
    return clamp(1.-4.*ao, 0., 1.);
}


float softshadow( in vec3 ro, in vec3 rd, float k ) {
    float res=1., t=0.02, h=1.;
    for(int i=0; i<38; i++ ) {
        h = map(ro + rd*t).x;
        res = min( res, k*h/t );
		t += clamp( h, 0.015, 1.0 );
		if( h<0.012 ) break;
    }
    return clamp(res,0.0,1.0);
}

vec3 normal(in vec3 p, in vec3 ray, in float t) {
   // vec2 e = vec2(E.y, -E.y); 
   // return normalize(e.xyy * map(p + e.xyy).x + e.yyx * map(p + e.yyx).x + e.yxy * map(p + e.yxy).x + e.xxx * map(p + e.xxx).x);;
	float pitch = .2 * t / iResolution.x;
    
	vec2 d = vec2(-1,1) * pitch;

	vec3 p0 = p+d.xxx; // tetrahedral offsets
	vec3 p1 = p+d.xyy;
	vec3 p2 = p+d.yxy;
	vec3 p3 = p+d.yyx;
	
	float f0 = map(p0).x;
	float f1 = map(p1).x;
	float f2 = map(p2).x;
	float f3 = map(p3).x;
	
	vec3 grad = p0*f0+p1*f1+p2*f2+p3*f3 - p*(f0+f1+f2+f3);
	//return normalize(grad);	
    // prevent normals pointing away from camera (caused by precision errors)
	return normalize(grad - max(.0,dot (grad,ray ))*ray);
}


// Classical 3D to 2D rendering loop
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec4 mouse = iMouse.xwzy;

	// Configure camera
	vec2 r = iResolution.xy, 
         m = mouse.xy/r, 
         q = fragCoord.xy/r.xy, 
         p =q+q-1.;
	p.x *= r.x/r.y;
    
	float j=.032, s=1., h = .1;

    
    WCurrent = clamp(2.*(mouse.w/iResolution.y)-1.,-.5,.7);
	vec3 c = vec3(.22,.26,.28);
    float k = 0.;

	// Ray marching

    if (q.x>.95) {
        float w = 2.*(fragCoord.y/iResolution.y)-1.;
        c = mix(C1,C2, .5+1.2*w);
        k=1.-smoothstep(abs(w-WCurrent),-.003,.003);
        
    } else if (length(q-.5)<.4) {
        
        float hs = hash(4.+floor(10.+.15*iTime));
		float time = 1.*(15.+.5*iTime * hs + 10.2*hash(hs)); //+ .08*hash(iTime);;
 
        // Rotation Matrix to apply to 4D objects
        float aaa = 10.+time*.4, bbb = 11.+time*.65, ccc = 11.+time*1.32;
        float c1 = cos(aaa), s1 = sin(aaa), 
              c2 = cos(bbb), s2 = sin(bbb), 
              c3 = cos(ccc), s3 = sin(ccc);	
        
        B = mat4(c2,  s2*s3,   0, -s2*c3,   
      			  0,  c1*c3, -s1,  c1*s3,
      			  0,  c3*s1,  c1,  s1*s3,
       			 s2, -c2*s3,   0,  c2*c3);
#ifdef FAST
    	v0000 = B*vec4(-.5,-.5,-.5,-.5);
    	v1000 = B*vec4( .5,-.5,-.5,-.5);
    	v0100 = B*vec4(-.5, .5,-.5,-.5);
    	v0010 = B*vec4(-.5,-.5, .5,-.5);
    	v0001 = B*vec4(-.5,-.5,-.5, .5);
    	v1100 = B*vec4( .5, .5,-.5,-.5);
    	v1010 = B*vec4( .5,-.5, .5,-.5);
    	v1001 = B*vec4( .5,-.5,-.5, .5);
#endif
       	vec3 res,
            o = 3.*normalize(vec3(cos(time+4.*m.x), c1, s1*sin(time+4.*m.x))),
             w = normalize(-o),
        	 u = normalize(cross(w, vec3(0,1,0))), v = cross(u, w),
         	 d = normalize(p.x * u + p.y * v + w+w), n, x;

		float t=0.;
        
        for(int i=0;i<56;i++) { 
            if (h<.003 || t>4.) break;
            t += h = map(o+d*t).x;
        }
        // Rendering    
        if (h <= .003) {
            x = o + t * d;
            res = map(x);
            n = normal(x, d,t);

            // Calculate Shadows
          //  s = softshadow(x, L, 32.); // faster with soft shadow but need to find good params 
            float h;
            for(int i=0;i<30;i++){
                h = map(x+L*j).x;
                j += clamp( h, 0.032, 1.0 );
               	s = min(s, h/j);
             	if(j>7.|| h<0.001) break;
            } 
            float ao= calcAO(x, n);
            // Teserac color
            vec3 co = (mod(res.y,.25)>.1?.7:1.) * mix(C1,C2, .5+1.2*res.z); 
            co*=ao;
            if (res.y >= 0.)  k=1.-smoothstep(abs(res.z-WCurrent),-.002,.002);
            // Shading
            c = mix(c, mix(sqrt((clamp(3.*s,0.,1.)+.3)*co), vec3(pow(max(dot(reflect(L,n),d),0.),99.)),.4),2.*dot(n,-d));
        } 
    }
    
	vec4 col = vec4(c+vec3(2,2,.8)*k,1);
   
    if (q.x<.95) {
    	col *= pow(16.0*q.x*q.y*(1.-q.x)*(1.-q.y),.3);
    }
    fragColor = col;
    
}
