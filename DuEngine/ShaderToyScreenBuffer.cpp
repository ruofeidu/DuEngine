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

#include "stdafx.h"
#include "ShaderToyScreenBuffer.h"
#include "ShaderToyUniforms.h"

ShaderToyScreenBuffer::ShaderToyScreenBuffer(ShaderToyGeometry* _geometry,
                                             int numChannels) {
  m_geometry = _geometry;
  m_uniforms = new ShaderToyUniforms(_geometry, numChannels);
}

GLuint ShaderToyScreenBuffer::getID() { return 0; }

void ShaderToyScreenBuffer::reshape(int _width, int _height) {
  m_uniforms->reset(_width, _height);
}

void ShaderToyScreenBuffer::reset() { m_uniforms->reset(m_geometry); }
