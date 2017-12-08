#version 450

layout (location = 0) in vec3 Position;

void main() {
	gl_Position = vec4(Position, 1.0);
	//gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
}
