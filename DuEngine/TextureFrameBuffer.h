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
#include "Texture.h"

class TextureFrameBuffer : public Texture {
 public:
  TextureFrameBuffer(GLuint FBO, int width, int height, float scale,
                     TextureFilter filter = TextureFilter::LINEAR,
                     TextureWarp warp = TextureWarp::REPEAT);
  void setReadingTextureID(GLuint id);
  void reshape(int _width, int _height);
  vec3 getResolution();

 private:
  int m_width = 0;
  int m_height = 0;
  float m_scale = 1.0;
};
