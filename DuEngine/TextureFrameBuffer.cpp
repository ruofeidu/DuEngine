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

#include "TextureFrameBuffer.h"
#include "stdafx.h"

TextureFrameBuffer::TextureFrameBuffer(GLuint FBO, int width, int height,
                                       float scale, TextureFilter filter,
                                       TextureWarp warp) {
  type = TextureType::FrameBuffer;
  m_filter = TextureFilter::LINEAR;
  m_warp = TextureWarp::CLAMP;
  m_scale = scale;
  m_width = width;
  m_height = height;
  glGenTextures(1, &id);
  glActiveTexture(GL_TEXTURE0 + id);
  reshape(width, height);
  read_texture_id = id;

#if DEBUG_MULTIPASS
  info("Mipmap generated for framgebuffer " + to_string(FBO) +
       ", with texture ID " + to_string(id));
#endif
}

void TextureFrameBuffer::setReadingTextureID(GLuint id) {
  read_texture_id = id;
}

void TextureFrameBuffer::reshape(int _width, int _height) {
  glBindTexture(GL_TEXTURE_2D, id);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F_ARB, int(_width * m_scale),
               int(_height * m_scale), 0, GL_RGBA, GL_FLOAT, NULL);
  this->generateMipmaps();

  this->setFiltering();
  glFramebufferTexture2D(
      GL_FRAMEBUFFER,
      GL_COLOR_ATTACHMENT0,  // Specifies the attachment point to which an image
                             // from texture should be attached. Must be one of
                             // the following symbolic constants:
                             // GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT, or
                             // GL_STENCIL_ATTACHMENT.
      GL_TEXTURE_2D,
      id,  // Specifies the texture object whose image is to be attached.
      0    // Specifies the mipmap level of the texture image to be attached,
           // which must be 0.
      );
  this->generateMipmaps();

  m_width = _width;
  m_height = _height;
}

vec3 TextureFrameBuffer::getResolution() {
  return vec3(m_width, m_height, 1.0f);
}
