#pragma once
/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
*/
#include "TextureVideo.h"

class TextureVideoSequence : public TextureVideo
{
public:
	TextureVideoSequence(string fileName, int fps, int startFrame, int endFrame, TextureFilter filter = TextureFilter::LINEAR, TextureWarp warp = TextureWarp::REPEAT);
	void resetTime();
	void update();

private:
	vector<Mat> m_videoseq;
};
