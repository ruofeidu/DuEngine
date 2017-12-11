#include "stdafx.h"
#include "Texture.h"
#include "DuEngine.h"
#include "DuUtils.h"

Texture::Texture(string filename, bool vflip, TextureFilter filter, TextureWrap warp) {
	mat = imread(filename);
	if (vflip) flip(mat, mat, 0);
	//glGenSamplers(1, &sampler);
	GLenum warpFilter = (warp == TextureWrap::REPEAT) ? GL_REPEAT : GL_CLAMP;

	switch (filter) {
	case TextureFilter::NEAREST:
		id = this->generateFromMat(mat, GL_BGR, GL_NEAREST, GL_NEAREST, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_NEAREST, TEXTURE_FILTER_MIN_NEAREST);
		break;
	case TextureFilter::LINEAR:
		id = this->generateFromMat(mat, GL_BGR, GL_LINEAR, GL_LINEAR, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_BILINEAR, TEXTURE_FILTER_MIN_NEAREST_MIPMAP);
		break;
	case TextureFilter::MIPMAP:
		id = this->generateFromMat(mat, GL_BGR, GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_BILINEAR, TEXTURE_FILTER_MIN_TRILINEAR);
		break;
	}
	GLenum err = glGetError();
	if (err != GL_NO_ERROR) cout << "Texture" << err << endl;
}

void Texture::setFiltering(int a_tfMagnification, int a_tfMinification) {
	// Set magnification filter
	if (a_tfMagnification == TEXTURE_FILTER_MAG_NEAREST)
		glSamplerParameteri(sampler, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	else if (a_tfMagnification == TEXTURE_FILTER_MAG_BILINEAR)
		glSamplerParameteri(sampler, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	// Set minification filter
	if (a_tfMinification == TEXTURE_FILTER_MIN_NEAREST)
		glSamplerParameteri(sampler, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	else if (a_tfMinification == TEXTURE_FILTER_MIN_BILINEAR)
		glSamplerParameteri(sampler, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	else if (a_tfMinification == TEXTURE_FILTER_MIN_NEAREST_MIPMAP)
		glSamplerParameteri(sampler, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
	else if (a_tfMinification == TEXTURE_FILTER_MIN_BILINEAR_MIPMAP)
		glSamplerParameteri(sampler, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
	else if (a_tfMinification == TEXTURE_FILTER_MIN_TRILINEAR)
		glSamplerParameteri(sampler, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
}

// https://www.khronos.org/registry/OpenGL-Refpages/es2.0/xhtml/glTexParameter.xml
// minFilters: GL_NEAREST, GL_LINEAR, GL_NEAREST_MIPMAP_NEAREST, GL_LINEAR_MIPMAP_NEAREST, GL_NEAREST_MIPMAP_LINEAR, GL_LINEAR_MIPMAP_LINEAR
// magFilters: GL_NEAREST, GL_LINEAR
// GL_TEXTURE_WRAP_S: GL_CLAMP_TO_EDGE, GL_MIRRORED_REPEAT, GL_REPEAT
GLuint Texture::generateFromMat(cv::Mat & mat, GLuint format, GLenum minFilter, GLenum magFilter, GLenum wrapFilter, GLuint datatype) {
	// Generate a number for our textureID's unique handle
	GLuint textureID;
	glGenTextures(1, &textureID);

	// Active the texture object
	glActiveTexture(GL_TEXTURE0 + textureID);

	// Bind to our texture handle
	glBindTexture(GL_TEXTURE_2D, textureID);

	// Catch silly-mistake texture interpolation method for magnification
	if (magFilter == GL_LINEAR_MIPMAP_LINEAR ||
		magFilter == GL_LINEAR_MIPMAP_NEAREST ||
		magFilter == GL_NEAREST_MIPMAP_LINEAR ||
		magFilter == GL_NEAREST_MIPMAP_NEAREST) {
		warning("! You can't use MIPMAPs for magnification - setting filter to GL_LINEAR");
		magFilter = GL_LINEAR;
	}

	// Set texture interpolation methods for minification and magnification
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);

	// Set texture clamping methodw
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapFilter);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapFilter);

	// Set incoming texture format to:
	// GL_BGR       for CV_CAP_OPENNI_BGR_IMAGE,
	// GL_LUMINANCE for CV_CAP_OPENNI_DISPARITY_MAP,
	// Work out other mappings as required ( there's a list in comments in main() )
	GLenum inputColourFormat = format;
	if (mat.channels() == 1) {
		inputColourFormat = GL_LUMINANCE;
	}

	// Create the texture
	glTexImage2D(GL_TEXTURE_2D,     // Type of texture
		0,					// Pyramid level (for mip-mapping) - 0 is the top level
		GL_RGB,				// Internal colour format to convert to
		mat.cols,			// Image width  i.e. 640 for Kinect in standard mode
		mat.rows,			// Image height i.e. 480 for Kinect in standard mode
		0,					// Border width in pixels (can either be 1 or 0)
		inputColourFormat,	// Input image format (i.e. GL_RGB, GL_RGBA, GL_BGR etc.)
		datatype,	// Image data type
		mat.ptr());			// The actual image data itself

							// If we're using mipmaps then generate them. Note: This requires OpenGL 3.0 or higher	   
	if ((
		minFilter == GL_LINEAR_MIPMAP_LINEAR ||
		minFilter == GL_LINEAR_MIPMAP_NEAREST ||
		minFilter == GL_NEAREST_MIPMAP_LINEAR ||
		minFilter == GL_NEAREST_MIPMAP_NEAREST)) {
		glGenerateMipmap(GL_TEXTURE_2D);
		info("Mipmap generated for texture" + textureID);
	}

#if COMPILE_CHECK_GL_ERROR
	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
		logerror("Texturing error: " + to_string(err));
#endif
	return textureID;
}

VideoTexture::VideoTexture(string filename, bool vflip, TextureFilter filter, TextureWrap warp) {
	cap.open(filename);
	_vflip = vflip;
	m_filter = filter;
	if (!cap.isOpened()) {
		logerror("Cannot open the video texture.");
		return;
	}
	cap >> mat;
	if (mat.empty()) {
		logerror("Cannot open the video texture.");
		return;
	}
	if (_vflip) flip(mat, mat, 0);
	frames = 0;
	//glGenSamplers(1, &sampler);
	GLenum warpFilter = (warp == TextureWrap::REPEAT) ? GL_REPEAT : GL_CLAMP;
	switch (filter) {
	case TextureFilter::NEAREST:
		id = this->generateFromMat(mat, GL_BGR, GL_NEAREST, GL_NEAREST, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_NEAREST, TEXTURE_FILTER_MIN_NEAREST);
		break;
	case TextureFilter::LINEAR:
		id = this->generateFromMat(mat, GL_BGR, GL_LINEAR, GL_LINEAR, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_BILINEAR, TEXTURE_FILTER_MIN_NEAREST_MIPMAP);
		break;
	case TextureFilter::MIPMAP:
		id = this->generateFromMat(mat, GL_BGR, GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, warpFilter);
		break;
	default:
		logerror("Cannot set unknown filters, use linear instead");
		id = this->generateFromMat(mat, GL_BGR, GL_LINEAR, GL_LINEAR, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_BILINEAR, TEXTURE_FILTER_MIN_NEAREST_MIPMAP);
		break;
	}
	prevTime = clock();
	vFrame = 0;
	distribution = vector<bool>(DEFAULT_RENDER_FPS, false);
	float p = 0.0;
	while (p < DEFAULT_RENDER_FPS) {
		distribution[(int)floor(p)] = true;
		p += (float)DEFAULT_RENDER_FPS / fps;
	}

	type = TextureType::Video; 
}

void VideoTexture::togglePaused() {
	paused = !paused;
}

void VideoTexture::update() {
	//double fps = 25;
	//if ((clock() - prevTime) < 1000.0 / fps) return; 
	const int DELTA = 2;
	int iFrame = DuEngine::GetInstance()->getFrameNumber();
	if (iFrame < DELTA) return;
	iFrame -= DELTA;
	if (!distribution[iFrame % distribution.size()]) return;

	prevTime = clock();
	cap >> mat;
	vFrame++;
	if (mat.empty()) {
		cap.set(CV_CAP_PROP_POS_FRAMES, 0);
		cap >> mat;
	}
	if (_vflip) flip(mat, mat, 0);
	++frames;

	glBindTexture(GL_TEXTURE_2D, id);
	glTexSubImage2D(
		GL_TEXTURE_2D,
		0,                   // GLint level,
		0, 0,                // GLint xoffset, GLint yoffset,
		mat.cols, mat.rows,  // GLsizei width, GLsizei height,
		GL_BGR,              // GLenum format,
		GL_UNSIGNED_BYTE,    // GLenum type,
		mat.ptr()            // const GLvoid * pixels
		);

	if (m_filter == TextureFilter::MIPMAP) {
		glGenerateMipmap(GL_TEXTURE_2D);
	}
	// info("video texture " + to_string(id) + " updated for the frame #" + to_string(frames)); 
}

void VideoTexture::resetTime() {
	cap.set(CV_CAP_PROP_POS_FRAMES, 0);
}

/**
* Keyboard Texture
*/
KeyboardTexture::KeyboardTexture() {
	mat = cv::Mat::zeros(3, 256, CV_8UC3);
	id = this->generateFromMat(mat, GL_RGB, GL_NEAREST, GL_NEAREST, GL_CLAMP);
}

// 0 is current state
// 1 is toggle
// 2 is keypress
// flipped
void KeyboardTexture::onKeyDown(unsigned char key) {
	mat.at<Vec3b>(2, key) = Vec3b(255, 255, 255);
	mat.at<Vec3b>(0, key) = Vec3b(255, 255, 255);
#if DEBUG_KEYBOARD
	cout << "key down " << key << endl;
#endif
}

void KeyboardTexture::onKeyUp(unsigned char key) {
	mat.at<Vec3b>(1, key) = Vec3b(255, 255, 255) - mat.at<Vec3b>(1, key);
	mat.at<Vec3b>(2, key) = Vec3b(0, 0, 0);
	mat.at<Vec3b>(0, key) = Vec3b(0, 0, 0);
#if DEBUG_KEYBOARD
	cout << "key up " << key << endl;
#endif
}

void KeyboardTexture::onKeyPress(unsigned char key, bool up) {
	if (up) {
		onKeyUp(key);
	} else {
		onKeyDown(key);
	}
	update();
}

void KeyboardTexture::update() {
	glActiveTexture(GL_TEXTURE0 + id);
	glBindTexture(GL_TEXTURE_2D, id);
	glTexSubImage2D(
		GL_TEXTURE_2D,
		0,                   // GLint level,
		0, 0,                // GLint xoffset, GLint yoffset,
		mat.cols, mat.rows,  // GLsizei width, GLsizei height,
		GL_BGR,              // GLenum format,
		GL_UNSIGNED_BYTE,    // GLenum type,
		mat.ptr()            // const GLvoid * pixels
		);
}


#if COMPILE_WITH_SH
/**
* Spherical Harmonics Texture
*/
SHTexture::SHTexture(int numBands, int numCoefs) {
	m_numBands = numBands;
	mat = Mat::zeros(m_numBands, m_numBands, CV_32FC3);
	id = this->generateFromMat(mat, GL_BGR, GL_NEAREST, GL_NEAREST, GL_CLAMP, GL_FLOAT);
	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
		logerror("SH Texture Error:" + to_string(err));
}

void SHTexture::update(float coef[NUM_COEF]) {
	for (int i = 0; i < mat.rows; ++i) {
		for (int j = 0; j < mat.cols; ++j) {
			mat.at<Vec3f>(mat.rows - 1 - i, j) =
				Vec3f(coef[(i * m_numBands + j) * 3 + 0],
					coef[(i * m_numBands + j) * 3 + 1],
					coef[(i * m_numBands + j) * 3 + 2]);
			//mat.at<Vec3f>(mat.rows - 1 - i, j) = Vec3f(1, 1, 1);
		}
	}

	glActiveTexture(GL_TEXTURE0 + id);
	glBindTexture(GL_TEXTURE_2D, id);
	glTexSubImage2D(
		GL_TEXTURE_2D,
		0,                   // GLint level,
		0, 0,                // GLint xoffset, GLint yoffset,
		mat.cols, mat.rows,  // GLsizei width, GLsizei height,
		GL_BGR,              // GLenum format,
		GL_FLOAT,    // GLenum type,
		mat.ptr()            // const GLvoid * pixels
		);
}
#endif

FrameBufferTexture::FrameBufferTexture(GLuint FBO, int width, int height, TextureFilter filter, TextureWrap warp) {
	type = TextureType::FrameBuffer;

	m_minFilter = GL_LINEAR_MIPMAP_LINEAR;
	m_magFilter = GL_LINEAR;
	m_wrapFilter = GL_REPEAT;

	glGenTextures(1, &id);
	glActiveTexture(GL_TEXTURE0 + id);
	reshape(width, height);

#if DEBUG_MULTIPASS
	info("Mipmap generated for framgebuffer " + to_string(FBO) + ", with texture ID " + to_string(id));
#endif
#if COMPILE_CHECK_GL_ERROR
	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
		logerror("Texturing error: " + to_string(err));
#endif
	current_id = id;
}

void FrameBufferTexture::setCommonTextureID(GLuint id) {
	current_id = id;
}

void FrameBufferTexture::reshape(int _width, int _height) {
	glBindTexture(GL_TEXTURE_2D, id);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F_ARB, _width, _height, 0, GL_RGBA, GL_FLOAT, NULL);

	// Set texture interpolation methods for minification and magnification
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, m_minFilter);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, m_magFilter);

	// Set texture clamping methodw
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, m_wrapFilter);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, m_wrapFilter);

	glFramebufferTexture2D(
		GL_FRAMEBUFFER,
		GL_COLOR_ATTACHMENT0, // Specifies the attachment point to which an image from texture should be attached. Must be one of the following symbolic constants: GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT, or GL_STENCIL_ATTACHMENT.
		GL_TEXTURE_2D,
		id, // Specifies the texture object whose image is to be attached.
		0 // Specifies the mipmap level of the texture image to be attached, which must be 0.
		);
	glGenerateMipmap(GL_TEXTURE_2D);
}
