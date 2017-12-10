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
		id = DuEngine::GetInstance()->matToTexture2D(mat, GL_BGR, GL_NEAREST, GL_NEAREST, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_NEAREST, TEXTURE_FILTER_MIN_NEAREST);
		break;
	case TextureFilter::LINEAR:
		id = DuEngine::GetInstance()->matToTexture2D(mat, GL_BGR, GL_LINEAR, GL_LINEAR, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_BILINEAR, TEXTURE_FILTER_MIN_NEAREST_MIPMAP);
		break;
	case TextureFilter::MIPMAP:
		id = DuEngine::GetInstance()->matToTexture2D(mat, GL_BGR, GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, warpFilter);
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
		id = DuEngine::GetInstance()->matToTexture2D(mat, GL_BGR, GL_NEAREST, GL_NEAREST, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_NEAREST, TEXTURE_FILTER_MIN_NEAREST);
		break;
	case TextureFilter::LINEAR:
		id = DuEngine::GetInstance()->matToTexture2D(mat, GL_BGR, GL_LINEAR, GL_LINEAR, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_BILINEAR, TEXTURE_FILTER_MIN_NEAREST_MIPMAP);
		break;
	case TextureFilter::MIPMAP:
		id = DuEngine::GetInstance()->matToTexture2D(mat, GL_BGR, GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, warpFilter);
		break;
	default:
		logerror("Cannot set unknown filters, use linear instead");
		id = DuEngine::GetInstance()->matToTexture2D(mat, GL_BGR, GL_LINEAR, GL_LINEAR, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_BILINEAR, TEXTURE_FILTER_MIN_NEAREST_MIPMAP);
		break;
	}
	prevTime = clock();
	vFrame = 0;
	const int RENDER_FPS = 60;
	distribution = vector<bool>(RENDER_FPS, false);
	float video_fps = 25.0;
	float p = 0.0;
	while (p < RENDER_FPS) {
		distribution[(int)floor(p)] = true;
		p += (float)RENDER_FPS / video_fps;
	}
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
	id = DuEngine::GetInstance()->matToTexture2D(mat, GL_RGB, GL_NEAREST, GL_NEAREST, GL_CLAMP);
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

/**
* Spherical Harmonics Texture
*/
SHTexture::SHTexture(int numBands, int numCoefs) {
	m_numBands = numBands;
	mat = Mat::zeros(m_numBands, m_numBands, CV_32FC3);
	id = DuEngine::GetInstance()->matToTexture2D(mat, GL_BGR, GL_NEAREST, GL_NEAREST, GL_CLAMP, GL_FLOAT);
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

FrameBufferTexture::FrameBufferTexture(GLuint FBO, int width, int height, TextureFilter filter, TextureWrap warp) {
	glGenTextures(1, &id);

	GLenum minFilter = GL_LINEAR_MIPMAP_LINEAR;
	GLenum magFilter = GL_LINEAR;
	GLenum wrapFilter = GL_REPEAT;

	glActiveTexture(GL_TEXTURE0 + id);
	glBindTexture(GL_TEXTURE_2D, id);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F_ARB, width, height, 0, GL_RGBA, GL_FLOAT, NULL);


	// Set texture interpolation methods for minification and magnification
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);

	// Set texture clamping methodw
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapFilter);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapFilter);

	glFramebufferTexture2D(
		GL_FRAMEBUFFER,
		GL_COLOR_ATTACHMENT0, // Specifies the attachment point to which an image from texture should be attached. Must be one of the following symbolic constants: GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT, or GL_STENCIL_ATTACHMENT.
		GL_TEXTURE_2D,
		id, // Specifies the texture object whose image is to be attached.
		0 // Specifies the mipmap level of the texture image to be attached, which must be 0.
		);
	glGenerateMipmap(GL_TEXTURE_2D);
	info("Mipmap generated for framgebuffer " + to_string(FBO) + ", with texture ID " + to_string(id));

	current_id = id; 
	frameBuffer = true; 
}

GLuint FrameBufferTexture::GetTextureID() {
	return this->current_id;
}

void FrameBufferTexture::setCommonTextureID(GLuint id) {
	current_id = id;
}
