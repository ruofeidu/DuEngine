/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
* 12/6/2017
*/
#include "stdafx.h"
#include "TextureCamera.h"
#include "DuEngine.h"

TextureCamera::TextureCamera(bool vflip, TextureFilter filter, TextureWarp warp) {
	init("", vflip, filter, warp);

	m_video.open(0);
	if (!m_video.isOpened()) this->error();
	m_video >> m_mat;
	if (m_mat.empty()) this->error();
	this->generateFromMat();

	m_fps = m_video.get(CV_CAP_PROP_FPS);

	this->initDistribution();
	type = TextureType::VideoFile;
}

void TextureCamera::update() {
	if (m_paused) return;
	int iFrame = DuEngine::GetInstance()->getFrameNumber();
	//if (!m_distribution[iFrame % m_distribution.size()]) return;

	m_prevTime = clock();
	m_video >> m_mat;
	m_numVideoFrames++;

	if (m_mat.empty()) {
		this->error();
	}
	if (m_vFlip) flip(m_mat, m_mat, 0);

	this->updateFromMat();

#if DEBUG_VIDEO
	info("video texture " + to_string(id) + " updated for the frame #" + to_string(frames));
#endif
}

TextureCamera::~TextureCamera() {
	m_video.release(); 
}

void TextureCamera::resetTime() {
	m_numVideoFrames = 0;
}
