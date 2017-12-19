/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
* 12/6/2017
*/
#include "stdafx.h"
#include "TextureVideoFile.h"
#include "DuEngine.h"

TextureVideoFile::TextureVideoFile(string filename, bool vflip, TextureFilter filter, TextureWarp warp) {
	init(filename, vflip, filter, warp);

	m_video.open(filename);
	if (!m_video.isOpened()) this->error();
	m_video >> m_mat;
	if (m_mat.empty()) this->error();
	this->generateFromMat();

	m_fps = m_video.get(CV_CAP_PROP_FPS);

	this->initDistribution();
	type = TextureType::VideoFile;
}

void TextureVideoFile::update() {
	if (m_paused) return; 
	int iFrame = DuEngine::GetInstance()->getFrameNumber();
	if (!m_distribution[iFrame % m_distribution.size()]) return;

	m_prevTime = clock();
	m_video >> m_mat;
	m_numVideoFrames++;

	// loop the video
	if (m_mat.empty()) {
		resetTime();
		m_video >> m_mat;
	}
	if (m_vFlip) flip(m_mat, m_mat, 0);

	this->updateFromMat();

#if DEBUG_VIDEO
	info("video texture " + to_string(id) + " updated for the frame #" + to_string(frames));
#endif
}

void TextureVideoFile::resetTime() {
	m_video.set(CV_CAP_PROP_POS_FRAMES, 0);
	m_numVideoFrames = 0;
}
