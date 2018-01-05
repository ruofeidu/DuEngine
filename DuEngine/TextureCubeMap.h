#pragma once
/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
* 12/6/2017
*/
#include "TextureMat.h"

class TextureCubeMap : public TextureMat
{
public:
	TextureCubeMap() {};
	TextureCubeMap(string filename, bool vflip = true, TextureFilter filter = TextureFilter::LINEAR, TextureWarp warp = TextureWarp::REPEAT);

private:
	cv::Mat m_cubes[6];
	// front, back, top, bottom, left, right
	GLenum m_cubeTypes[6] = { GL_TEXTURE_CUBE_MAP_NEGATIVE_Z,  GL_TEXTURE_CUBE_MAP_POSITIVE_Z, GL_TEXTURE_CUBE_MAP_POSITIVE_Y, GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, GL_TEXTURE_CUBE_MAP_NEGATIVE_X, GL_TEXTURE_CUBE_MAP_POSITIVE_X };
};

