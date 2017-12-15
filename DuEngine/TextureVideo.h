#pragma once
/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
*/
#include "Texture2D.h"

class TextureVideo : public Texture2D
{
public:
	int getNumFrame() { return m_numFrames; }
	int getNumVideoFrame() { return m_numVideoFrames; }
	void togglePaused();

public:
	virtual void resetTime() = 0;
	virtual void update() = 0;

protected:
	int m_numVideoFrames = 0;
	int m_numFrames = 0;
	double m_fps = DEFAULT_VIDEO_FPS;

protected:
	void error();
	void initDistribution();
	bool m_paused;
	// distribution of one frame
	vector<bool> m_distribution;
	clock_t m_prevTime = 0;
	Mat smallerMat;
	TextureFilter m_filter;
};
