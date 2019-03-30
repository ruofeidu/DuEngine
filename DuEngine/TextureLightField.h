#pragma once
/**
 * DuRenderer is a basic OpenGL-based renderer which implements most of the
 * ShaderToy functionality Ruofei Du | Augmentarium Lab | UMIACS Computer
 * Science Department | University of Maryland, College Park me [at] duruofei
 * [dot] com
 */
#include "TextureMat.h"

class TextureLightField : public TextureMat {
 private:
  GLuint* ids;
  GLsizei m_width;
  GLsizei m_height;

 public:
  TextureLightField(){};
  TextureLightField(string fileName, int rows, int cols,
                    TextureFilter filter = TextureFilter::LINEAR,
                    TextureWarp warp = TextureWarp::REPEAT);

 protected:
  vector<Mat> m_mats;
};
