#pragma once
/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
*/
#include "TextureVideo.h"

class TextureCamera : public TextureVideo
{
public:
	TextureCamera(bool vflip = true, TextureFilter filter = TextureFilter::LINEAR, TextureWarp warp = TextureWarp::REPEAT);
	void resetTime();
	void update();
	~TextureCamera();

private:
	VideoCapture m_video;
};

