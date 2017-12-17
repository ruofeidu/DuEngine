#pragma once
#include "stdafx.h"
#include "Uniforms.h"
#include "ShaderToyGeometry.h"
#include "ShaderProgram.h"

class FrameBuffer
{
protected:
	Uniforms* m_uniforms;
	ShaderToyGeometry* m_geometry;
	ShaderProgram* m_program = nullptr; 

public:
	void render();
	void loadShadersLinkUniforms(string vertexShaderName, string fragShaderName, string uniformShaderName, string mainFileName);

public:
	Uniforms* getUniforms();

public:
	// get FBO index
	virtual GLuint getID() = 0;
	virtual void reshape(int _width, int _height) = 0;
	virtual void reset() = 0; 
};
