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
#include "FrameBuffer.h"
#include "stdafx.h"

class ShaderToyFrameBuffer : public FrameBuffer {
 private:
  GLuint m_pointer;
  // Id of the FBO array.
  TextureFrameBuffer* m_pointerToTexture;

  // Two frame buffer objects.
  GLuint m_FBO[2];

  // Two texture objects.
  TextureFrameBuffer* m_textures[2];

 public:
  ShaderToyFrameBuffer(ShaderToyGeometry* _geometry, float scale,
                       int numChannels, TextureFilter filter, TextureWarp warp);

  GLuint getTextureID();
  Texture* getTexture();

  void swapTextures();

 public:
  GLuint getID() override;
  void reshape(int _width, int _height) override;
  void reset() override;
};
