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
	// Input image format (i.e. GL_RGB, GL_RGBA, GL_BGR etc.)
	GLuint m_format = GL_BGR;
	// Image data type
	GLuint m_dataType = GL_UNSIGNED_BYTE;
	// Internal color format to convert to
	GLuint m_openGLFormat = GL_RGB;

protected:
	// Generate, active, bind, and set filtering, 
	// Update date type format of the mat
	// TexImage2D from the mat
	// Generate mipmaps
	void generateFromMat();

	// Update the texture from Mat
	void updateFromMat();

	// Update the datatype format
	void updateDataTypeFormat();

	// Create the texture
	void texImage(cv::Mat &mat, uchar* pointer = nullptr);

private:
	// https://www.khronos.org/registry/OpenGL-Refpages/es2.0/xhtml/glTexParameter.xml
	// minFilters: GL_NEAREST, GL_LINEAR, GL_NEAREST_MIPMAP_NEAREST, GL_LINEAR_MIPMAP_NEAREST, GL_NEAREST_MIPMAP_LINEAR, GL_LINEAR_MIPMAP_LINEAR
	// magFilters: GL_NEAREST, GL_LINEAR
	// GL_TEXTURE_WRAP_S: GL_CLAMP_TO_EDGE, GL_MIRRORED_REPEAT, GL_REPEAT
	void generateFromMat(cv::Mat& mat);

	void updateDatatypeFromMat(cv::Mat& mat);
	void updateFormatFromMat(cv::Mat& mat);
	void updateOpenGLInternalFormat(cv::Mat& mat);
};
