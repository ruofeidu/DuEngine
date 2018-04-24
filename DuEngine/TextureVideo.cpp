/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
*/
#include "stdafx.h"
#include "TextureVideo.h"
#include "DuUtils.h"

void TextureVideo::togglePaused() {
	m_paused = !m_paused;
}

void TextureVideo::error() {
	logerror("Cannot open the video texture." + m_filename);
	exit(EXIT_FAILURE);
}

void TextureVideo::initDistribution() {
	m_prevTime = clock();
	// synchronization between videos and frame rate
	m_distribution = vector<bool>(DEFAULT_RENDER_FPS, false);
	double p = 0.0;
	int cnt = 0;
	while (p < DEFAULT_RENDER_FPS) {
		m_distribution[(int)floor(p)] = true;
		p += (double)DEFAULT_RENDER_FPS / m_fps;
		++cnt;
	}
	if (cnt != (int)round(m_fps)) {
		m_distribution[m_distribution.size() - 1] = true;
	}
	m_numVideoFrames = 0;
}
