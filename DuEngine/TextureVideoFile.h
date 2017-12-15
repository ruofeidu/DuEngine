#pragma once
/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
*/
#include "TextureVideo.h"

class TextureVideoFile : public TextureVideo
{
public:
	TextureVideoFile(string filename, bool vflip = true, TextureFilter filter = TextureFilter::LINEAR, TextureWarp warp = TextureWarp::REPEAT);
	void resetTime();
	void update();

private:
	VideoCapture m_video;
};

