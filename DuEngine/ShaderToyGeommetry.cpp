#include "stdafx.h"
#include "ShaderToy.h"

ShaderToy::ShaderToyGeometry::ShaderToyGeometry(double _width, double _height, double _x0, double _y0) {
	reset(_width, _height, _x0, _y0);

	GLuint vertexLength = sizeof(vertexBuffer);

	layoutPosition = 0;
	layoutTexCoord = 1;
	layoutFragCoord = 2;

	int scale = 2;
	glGenBuffers(1, &VBO);
	vertexBuffer[0] = Vertex(vec3(0.5f * scale, 0.5f * scale, 0.0f));
	vertexBuffer[1] = Vertex(vec3(-0.5f * scale, 0.5f * scale, 0.0f));
	vertexBuffer[2] = Vertex(vec3(-0.5f * scale, -0.5f * scale, 0.0f));
	vertexBuffer[3] = Vertex(vec3(0.5f * scale, -0.5f * scale, 0.0f));

	glGenBuffers(1, &EBO);
	elements[0] = 0;	elements[1] = 1;	elements[2] = 3;
	elements[3] = 1;	elements[4] = 2;	elements[5] = 3;

	glGenBuffers(1, &VBO);
	glBindBuffer(GL_ARRAY_BUFFER, VBO);
	glBufferData(GL_ARRAY_BUFFER, vertexLength, vertexBuffer, GL_STATIC_DRAW);

	glGenVertexArrays(1, &VAO);
	glBindVertexArray(VAO);
	glEnableVertexAttribArray(layoutPosition);
	glVertexAttribPointer(layoutPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), NULL);
	//glEnableVertexAttribArray(layoutTexCoord);
	//glVertexAttribPointer(layoutTexCoord, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void*)(sizeof(vec3)));

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(elements), elements, GL_STATIC_DRAW);
}

void ShaderToy::ShaderToyGeometry::reset(double _width, double _height) {
	geometry[0] = _width;
	geometry[1] = _height;
}

void ShaderToy::ShaderToyGeometry::reset(double _width, double _height, double _x0, double _y0) {
	geometry[0] = _width;
	geometry[1] = _height;
	geometry[2] = _x0;
	geometry[3] = _y0;
}

void ShaderToy::ShaderToyGeometry::render() {
	glBindVertexArray(VAO);
	glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
}