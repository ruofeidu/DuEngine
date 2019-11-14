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

#pragma once
#include "TextureMat.h"

class Texture3D : public Texture {
 public:
  Texture3D(){};
  Texture3D(string filename, TextureFilter filter = TextureFilter::MIPMAP,
            TextureWarp warp = TextureWarp::REPEAT);
  vec3 getResolution();

 private:
  vector<unsigned char> m_volume;
  int m_resolution[4];
  GLuint m_openGLFormat = GL_RGBA;
  GLuint m_format = GL_BGRA;
  GLuint m_dataType = GL_UNSIGNED_BYTE;
};
