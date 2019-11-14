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
#include "Texture3D.h"
#include "DuUtils.h"

Texture3D::Texture3D(string filename, TextureFilter filter, TextureWarp warp) {
  type = TextureType::Bin3D;
  m_glType = GL_TEXTURE_3D;
  m_filter = filter;
  m_warp = warp;

  auto fp = fopen(filename.c_str(), "rb");
  if (!fp) logerror("Cannot open file " + filename);
  char _header[4];
  auto count = fread(&_header, sizeof(decltype(_header)), 1, fp);
  count = fread(&m_resolution, sizeof(decltype(m_resolution)), 1, fp);

  m_volume.resize(m_resolution[0] * m_resolution[1] * m_resolution[2] *
                  m_resolution[3]);
  count = fread(&m_volume[0], m_volume.size(), 1, fp);
  fclose(fp);
  // debug("Read: " + to_string(count) + " ; total bytes: " +
  // to_string(m_resolution[0] * m_resolution[1] * m_resolution[2] *
  // m_resolution[3]));

  switch (m_resolution[3]) {
    case 1:
      m_openGLFormat = GL_R8;
      m_format = GL_RED;
      break;
    case 2:
      m_openGLFormat = GL_RG16;
      m_format = GL_RG;
      break;
    case 3:
      m_openGLFormat = GL_RGB;
      m_format = GL_BGR;
      break;
    case 4:
      m_openGLFormat = GL_RGBA;
      m_format = GL_BGRA;
      break;
    default:
      logerror("Unknown channels of volume");
  }
  glTexImage3D(m_glType,
               0,  // Pyramid level (for mip-mapping) - 0 is the top level
               m_openGLFormat,
               m_resolution[0],  // Volume width
               m_resolution[1],  // Volume height
               m_resolution[2],
               0,  // Border width in pixels (can either be 1 or 0)
               m_format, m_dataType,
               &m_volume[0]  // The actual volume data itself
               );
  this->generateMipmaps();
  this->setFiltering();

#if COMPILE_CHECK_GL_ERROR
  // Check texturing errors.
  GLenum err = glGetError();
  if (err != GL_NO_ERROR) warning("Texturing error: " + to_string(err));
#endif
}

vec3 Texture3D::getResolution() {
  return vec3(m_resolution[0], m_resolution[1], m_resolution[2]);
}
