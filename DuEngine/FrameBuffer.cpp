#include "FrameBuffer.h"
#include "ShaderFileParas.h"
#include "stdafx.h"

void FrameBuffer::render() {
  glBindFramebuffer(GL_DRAW_FRAMEBUFFER, this->getID());
  m_uniforms->update();
  m_geometry->render();
}

void FrameBuffer::loadShadersLinkUniforms(ShaderFileParas &paras) {
  m_program = new ShaderProgram(paras);
  m_uniforms->linkShaderProgram(m_program);
#if VERBOSE_OUTPUT
  debug("Frame buffer " + to_string(this->getID()) +
        " loaded fragment shader: " + fragShaderName);
#endif
}

Uniforms *FrameBuffer::getUniforms() { return m_uniforms; }
