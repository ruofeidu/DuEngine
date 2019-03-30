#pragma once
/**
 * DuRenderer is a basic OpenGL-based renderer which implements most of the
 * ShaderToy functionality Ruofei Du | Augmentarium Lab | UMIACS Computer
 * Science Department | University of Maryland, College Park me [at] duruofei
 * [dot] com 12/6/2017
 */
#include "TextureMat.h"

class Texture2D : public TextureMat {
 public:
  Texture2D(){};
  Texture2D(string filename, bool vflip = true,
            TextureFilter filter = TextureFilter::LINEAR,
            TextureWarp warp = TextureWarp::REPEAT);
};
