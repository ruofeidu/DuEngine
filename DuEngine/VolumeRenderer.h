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
