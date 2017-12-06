//#version 430
uniform float iGlobalTime;
uniform vec4 iResolution;

void main() {
	gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
}
