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
#include "stdafx.h"
#include "Uniforms.h"
#include "ShaderToyGeometry.h"
#include "ShaderProgram.h"

class FrameBuffer {
 protected:
  Uniforms* m_uniforms;
  ShaderToyGeometry* m_geometry;
  ShaderProgram* m_program = nullptr;

 public:
  void render();
  void loadShadersLinkUniforms(ShaderFileParas& paras);

 public:
  Uniforms* getUniforms();

 public:
  // get FBO index
  virtual GLuint getID() = 0;
  virtual void reshape(int _width, int _height) = 0;
  virtual void reset() = 0;
};
