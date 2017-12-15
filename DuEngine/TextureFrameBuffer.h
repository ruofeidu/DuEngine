#pragma once
/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
* 12/6/2017
*/
#include "Texture.h"

class TextureFrameBuffer : public Texture
{
public:
	TextureFrameBuffer(GLuint FBO, int width, int height, TextureFilter filter = TextureFilter::LINEAR, TextureWarp warp = TextureWarp::REPEAT);
	void setReadingTextureID(GLuint id);
	void reshape(int _width, int _height);
private:
};

