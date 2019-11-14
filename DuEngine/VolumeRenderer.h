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

#pragma once;
#include "DuEngine.h"
#include "ShaderProgram.h"
#include "ShaderToyFrameBuffer.h"
#include "ShaderToyScreenBuffer.h"
#include "ShaderToyUniforms.h"
#include "TexturesManager.h"
#include "stdafx.h"
using namespace glm;
using namespace std;

class VolumeRenderer {
  friend class DuEngine;

 public:
  VolumeRenderer(DuEngine* _renderer, double _width, double _height,
                 float scale, int _x0, double _y0);

  VolumeRenderer(DuEngine* _renderer);

 private:
  ShaderToyScreenBuffer* m_screenBuffer;
  vector<ShaderToyFrameBuffer*> m_frameBuffers;

 public:
  void reshape(int _width, int _height);

  void reset();

  void recompile();

  void render();

 public:
  int getNumFrameBuffers();
  FrameBuffer* getBuffer(int id);
  ShaderToyFrameBuffer* getFrameBuffer(int id);

 private:
  int numChannels = 0;
  int numBuffers = 0;
};
