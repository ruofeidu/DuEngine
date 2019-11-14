// DuEngine: Real-time Rendering Engine and Shader Testbed
// Ruofei Du | http://www.duruofei.com
//
// Creative Commons Attribution-ShareAlike 3.0 License with 996 ICU clause:
//
// The above license is only granted to entities that act in concordance with
// local labor laws. In addition, the following requirements must be observed:
// The licensee must not, explicitly or implicitly, request or schedule their
// employees to work more than 45 hours in any single week. The licensee must
// not, explicitly or implicitly, request or schedule their employees to be at
// work consecutively for 10 hours. For more information about this protest, see
// http://996.icu

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
