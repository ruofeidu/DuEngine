#pragma once
#include "stdafx.h"
using namespace glm;

struct Vertex
{
	vec3 position;
	Vertex() {}
	Vertex(vec3 pos) {
		position = pos;
	}
};

struct TexVertex
{
	vec3 position;
	vec2 texCoord;
	TexVertex() {}
	TexVertex(vec3 pos, vec2 tex) {
		position = pos;
		texCoord = tex;
	}
};

class Geometry
{
public:
	virtual void render() = 0; 
};
