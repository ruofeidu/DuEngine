// https://www.shadertoy.com/view/lslGRN
#define PIXELSIZE_X 15.0
#define PIXELSIZE_Y 15.0
#define GRIDSIZE_X 3.0
#define GRIDSIZE_Y 3.0

vec3 gridColor=vec3(0.0,0.0,0.0);
vec3 color= vec3(0.4,0.4,0.4);
float barrelPower=1.0;
float gradientValue;
float r,g,b;

void DoGrid(vec2 pos){
	float moduloX= mod(pos.x,PIXELSIZE_X);
	float moduloY= mod(pos.y,PIXELSIZE_Y);	
	if(moduloX<GRIDSIZE_X || moduloY<GRIDSIZE_Y){
		color.x=gridColor.x;
		color.y=gridColor.y;
		color.z=gridColor.z;
	}
}

vec2 Distort(vec2 p){
    float theta  = atan(p.y, p.x);
    float radius = length(p);
    radius = pow(radius, barrelPower);
    p.x = radius * cos(theta);
    p.y = radius * sin(theta);
    color.r=0.5 * (p.y + 1.0);
    color.b=radius;    
    return 0.5 * (p + 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	barrelPower+=(sin(iTime)+cos(cos(iTime)))/2.1;
	vec2 normalizedUV=(fragCoord.xy/(iResolution.xy/2.0))-1.0;
	vec2 distortedUV=Distort(normalizedUV)*iResolution.xy;;	
	DoGrid(distortedUV.xy);		
	fragColor = vec4( color, 1.0 );
}