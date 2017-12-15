/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
* 12/6/2017
*/
#include "stdafx.h"
#include "TextureMat.h"
#include "DuUtils.h"

TextureMat::TextureMat(string filename, bool vflip, TextureFilter filter, TextureWarp warp) {
	init(filename, vflip, filter, warp);
	m_mat = imread(filename);
	this->generateFromMat();
}

void TextureMat::init(string filename, bool vflip, TextureFilter filter, TextureWarp warp) {
	m_filename = filename;
	m_vFlip = vflip;
	m_filter = filter;
	m_warp = warp;
}

void TextureMat::generateFromMat() {
	return generateFromMat(m_mat);
}

void TextureMat::updateFromMat() {
	glBindTexture(GL_TEXTURE_2D, id);
	glTexSubImage2D(
		GL_TEXTURE_2D,
		0,                       // GLint level,
		0, 0,                    // GLint xoffset, GLint yoffset,
		m_mat.cols, m_mat.rows,  // GLsizei width, GLsizei height,
		m_format,                // GLenum format,
		m_dataType,              // GLenum type,
		m_mat.ptr()              // const GLvoid * pixels
		);
	generateMipmaps();
}

// https://www.khronos.org/registry/OpenGL-Refpages/es2.0/xhtml/glTexParameter.xml
// minFilters: GL_NEAREST, GL_LINEAR, GL_NEAREST_MIPMAP_NEAREST, GL_LINEAR_MIPMAP_NEAREST, GL_NEAREST_MIPMAP_LINEAR, GL_LINEAR_MIPMAP_LINEAR
// magFilters: GL_NEAREST, GL_LINEAR
// GL_TEXTURE_WRAP_S: GL_CLAMP_TO_EDGE, GL_MIRRORED_REPEAT, GL_REPEAT
void TextureMat::generateFromMat(cv::Mat & mat) {
	this->genTexture2D();
	this->updateDataTypeFormat();

	// Create the texture
	glTexImage2D(GL_TEXTURE_2D,  // Type of texture
		0,					     // Pyramid level (for mip-mapping) - 0 is the top level
		m_openGLFormat,		     // Internal colour format to convert to
		mat.cols,			     // Image width  i.e. 640 for Kinect in standard mode
		mat.rows,			     // Image height i.e. 480 for Kinect in standard mode
		0,					     // Border width in pixels (can either be 1 or 0)
		m_format,	             // Input image format (i.e. GL_RGB, GL_RGBA, GL_BGR etc.)
		m_dataType,	             // Image data type
		mat.ptr());			     // The actual image data itself

	generateMipmaps();
}

void TextureMat::updateDataTypeFormat() {
	// OpenCV has reversed Y coordinates
	if (m_vFlip) flip(m_mat, m_mat, 0);
	updateDatatypeFromMat(m_mat);
	updateFormatFromMat(m_mat);
	updateOpenGLInternalFormat(m_mat);
}

void TextureMat::updateDatatypeFromMat(cv::Mat & mat) {
	string r; // 8UC3 for example
	auto type = mat.type();
	uchar depth = type & CV_MAT_DEPTH_MASK;
	uchar chans = 1 + (type >> CV_CN_SHIFT);
	switch (depth) {
	case CV_8U:  r = "8U"; m_dataType = GL_UNSIGNED_BYTE;  break;
	case CV_8S:  r = "8S"; m_dataType = GL_BYTE; break;
	case CV_16U: r = "16U"; m_dataType = GL_UNSIGNED_SHORT; break;
	case CV_16S: r = "16S"; m_dataType = GL_SHORT; break;
	case CV_32S: r = "32S"; m_dataType = GL_INT; break;
	case CV_32F: r = "32F"; m_dataType = GL_FLOAT; break;
	case CV_64F: r = "64F"; m_dataType = GL_DOUBLE; break;
	default:     r = "User"; break;
	}

	r += "C";
	r += (chans + '0');
}

// Set incoming texture format to:
// GL_BGR       for CV_CAP_OPENNI_BGR_IMAGE,
// GL_LUMINANCE for CV_CAP_OPENNI_DISPARITY_MAP,
void TextureMat::updateFormatFromMat(cv::Mat & mat) {
	switch (mat.channels()) {
	case 1:
		m_format = GL_RED;
		break;
	case 2:
		m_format = GL_RG;
		break;
	case 3:
		m_format = GL_BGR;
		break;
	case 4:
		m_format = GL_BGRA;
		break;
	default:
		logerror("Unknown channels of mat");
	}
}

void TextureMat::updateOpenGLInternalFormat(cv::Mat & mat) {
	switch (mat.channels()) {
	case 1:
		m_openGLFormat = GL_R8;
		break;
	case 2:
		m_openGLFormat = GL_RG16;
		break;
	case 3:
		m_openGLFormat = GL_RGB;
		break;
	case 4:
		m_openGLFormat = GL_RGBA;
		break;
	default:
		logerror("Unknown channels of mat");
	}
}
