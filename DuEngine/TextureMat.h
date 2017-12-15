#pragma once
/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
* 12/6/2017
*/
#include "Texture.h"

class TextureMat : public Texture
{
public:
	TextureMat() {};
	TextureMat(string filename, bool vflip = true, TextureFilter filter = TextureFilter::LINEAR, TextureWarp warp = TextureWarp::REPEAT);
	void init(string filename, bool vflip = true, TextureFilter filter = TextureFilter::LINEAR, TextureWarp warp = TextureWarp::REPEAT);
	vec3 getResolution(); 

protected:
	Mat m_mat = Mat();
	string m_filename = "";
	bool m_vFlip = true;
	GLuint m_format = GL_BGR;
	GLuint m_dataType = GL_UNSIGNED_BYTE;
	GLuint m_openGLFormat = GL_RGB;

protected:
	// Generate, active, bind, and set filtering, 
	// update date type format of the mat
	// texImage2D from the mat
	// generate mipmaps, all in one!
	void generateFromMat();
	void updateFromMat();
	void updateDataTypeFormat();

private:
	void generateFromMat(cv::Mat& mat);
	void updateDatatypeFromMat(cv::Mat& mat);
	void updateFormatFromMat(cv::Mat& mat);
	void updateOpenGLInternalFormat(cv::Mat& mat);
};
