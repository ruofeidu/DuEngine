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
#include "ShaderToy.h"

ShaderToyFrameBuffer::ShaderToyFrameBuffer(ShaderToyGeometry* _geometry,
                                           float scale, int numChannels,
                                           TextureFilter filter,
                                           TextureWarp warp) {
  m_geometry = _geometry;
  m_uniforms = new ShaderToyUniforms(_geometry, numChannels);

  for (int i = 0; i < 2; ++i) {
    glGenFramebuffers(1, &m_FBO[i]);
    glBindFramebuffer(GL_FRAMEBUFFER, m_FBO[i]);
    m_textures[i] =
        new TextureFrameBuffer(m_FBO[i], m_geometry->getWidth(),
                               m_geometry->getHeight(), scale, filter, warp);
  }

  m_pointer = 0;
  m_pointerToTexture = m_textures[1 - m_pointer];
}

GLuint ShaderToyFrameBuffer::getID() { return m_FBO[m_pointer]; }

GLuint ShaderToyFrameBuffer::getTextureID() {
  return m_pointerToTexture->getTextureID();
}

Texture* ShaderToyFrameBuffer::getTexture() { return m_pointerToTexture; }

void ShaderToyFrameBuffer::swapTextures() {
  m_pointer = 1 - m_pointer;
  m_pointerToTexture = m_textures[1 - m_pointer];
  for (int i = 0; i < 2; ++i) {
    m_textures[i]->setReadingTextureID(m_pointerToTexture->getDirectID());
  }
}

void ShaderToyFrameBuffer::reshape(int _width, int _height) {
  for (int i = 0; i < 2; ++i) {
    glBindFramebuffer(GL_FRAMEBUFFER, m_FBO[i]);
    glViewport(0, 0, _width, _height);
    m_textures[i]->reshape(_width, _height);
  }
  m_uniforms->reset(_width, _height);
}

void ShaderToyFrameBuffer::reset() {}
