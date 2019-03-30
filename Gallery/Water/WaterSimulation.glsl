// 4tXBRs
/*
	Water Simulation.glsl by 834144373
	2017/12/9
----------------------------------------------
	1.Buffer A is 2D Water simulation buffer	
	2.Image is calculate grad.

	Adopt my:
    https://github.com/TNWX-Z/ClickScreenWaterWaveBufferPro
*/

/*
	And if you want to know more about fluid simulation
	the below can help you:
	

	https://github.com/TNWX-Z/EnhanceSmokeSimulationPro

	PS: Enhance Smoke Simulation Pro(ESSP) is not surpport on ShaderToy,
		and ESSP with new color transform technology I called it "Magic Color".
*/

#define time iTime
#define _BufferA iChannel0 

void mainImage( out vec4 C, in vec2 U )
{
    vec2 q = U/iResolution.xy;
    vec3 e = vec3(1./iResolution.xy,0.0);
    float p10 = texture(_BufferA, q-e.zy).x;
    float p01 = texture(_BufferA, q-e.xz).x;
    float p21 = texture(_BufferA, q+e.xz).x;
    float p12 = texture(_BufferA, q+e.zy).x;

    vec3 grad = normalize(vec3(p21 - p01,p12 - p10, 1.));

    //To see normal
    C = (grad.xyzz+1.)/2.;
 	//To see Water   
    C = texture(iChannel1,q + grad.xy);
}
