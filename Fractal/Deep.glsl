// lsXfRs
//created by 834144373(恬纳微晰)
#define R iResolution.xy
#define DEPTH_STEP 64
#define time iTime
float map(vec3 p){
	float a = p.z*0.1001;
	p.xy *= mat2(cos(a), sin(a), -sin(a), cos(a));
	float t = length(mod(p.xy, 2.0) - 1.0) - 0.07 - sin(p.z)*sin(time)/4.;
	t = min(t,length(mod(p.yz, 2.0) - 1.0) - 0.07 - sin(p.x)*cos(time)/4.);
	t = min(t,length(mod(p.zx, 2.0) - 1.0) - 0.07 - sin(p.y)*sin(time)/4.);
	return t;
}

void mainImage( out vec4 Color, in vec2 U ){
	float j = 0.;
	float depth = 1.;
	float d = 0.;
	for(int i=0;i<64;i++){
		depth += (d = map(vec3(0.,0.,time) + normalize(vec3((U+U-R)/R.y,2.)) * depth));
		j = float(i);
		if(d<0.01)
			break;
	}
	depth = 1.-j/float(DEPTH_STEP);
    /*
	float coeff = pow(depth,2.2)*3.;
	float c1 = clamp(coeff,0.,1.);
	float c2 = clamp(coeff,1.,2.)-1.;   
	float c3 = clamp(coeff,2.,3.)-2.;
	vec3 col = vec3(c1,c2,c3);
	*/
    //Super thanks for Shane's suggestion,
    //vec3 col = pow(vec3(1.5, 1, 1)*val, vec3(1, 3, 16));
    vec3 col = pow(vec3(1.)*depth, vec3(1, 3, 10));	
	Color = vec4(col,0.);
}

