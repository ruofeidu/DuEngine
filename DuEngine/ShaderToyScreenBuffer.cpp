#include "stdafx.h"
#include "ShaderToyScreenBuffer.h"
#include "ShaderToyUniforms.h"

ShaderToyScreenBuffer::ShaderToyScreenBuffer(ShaderToyGeometry * _geometry, int numChannels) {
	m_geometry = _geometry;
	m_uniforms = new ShaderToyUniforms(_geometry, numChannels);
}

GLuint ShaderToyScreenBuffer::getID() {
	return 0;
}

void ShaderToyScreenBuffer::reshape(int _width, int _height) {
	m_uniforms->reset(_width, _height);
}

void ShaderToyScreenBuffer::reset() {
	m_uniforms->reset(m_geometry);
}
