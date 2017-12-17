#pragma once
#include "stdafx.h"
#include "ShaderToyGeometry.h"
#include "ShaderProgram.h"

class Uniforms
{
public:
	virtual void update() = 0;
	virtual void reset(int _width, int _height) = 0;
	virtual void reset(ShaderToyGeometry* geometry) = 0;
	virtual void linkShaderProgram(ShaderProgram* program) = 0;

protected:
	ShaderProgram* m_program;
};
