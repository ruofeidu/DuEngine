#include "stdafx.h"
#include "FrameBuffer.h"

void FrameBuffer::render() {
	glBindFramebuffer(GL_DRAW_FRAMEBUFFER, this->getID());
	m_uniforms->update();
	m_geometry->render();
}

void FrameBuffer::loadShadersLinkUniforms(string vertexShaderName, string fragShaderName, string uniformShaderName, string mainFileName) {
	m_program = new ShaderProgram(vertexShaderName, fragShaderName, uniformShaderName, mainFileName);
	m_uniforms->linkShaderProgram(m_program);
#if VERBOSE_OUTPUT
	debug("Frame buffer " + to_string(this->getID()) + " loaded fragment shader: " + fragShaderName);
#endif
}

Uniforms * FrameBuffer::getUniforms() {
	return m_uniforms;
}
