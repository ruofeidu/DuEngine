/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
* 12/6/2017
*/
#include "stdafx.h"
#include "DuEngine.h"
#include "DuUtils.h"
using namespace std;
using namespace cv;

void DuEngine::initScene() {
	m_shadertoy = new ShaderToy(DuEngine::GetInstance());
	m_shadertoy->recompile(this); 
}

int DuEngine::getFrameNumber() {
	return ShaderToyUniforms::iFrame;
}

void DuEngine::render() {
	if (!m_paused) {
		m_textureManager->update(); 

		if (m_renderType == RendererType::SHADERTOY)
			m_shadertoy->render();

		glutSwapBuffers();
		glutPostRedisplay();
	}

	if (m_recording && m_recordStart <= getFrameNumber() && getFrameNumber() <= m_recordEnd) {
		this->takeScreenshot(m_recordPath);
	}
	if (m_takeSingleScreenShot) {
		m_takeSingleScreenShot = false; 
		this->takeScreenshot();
	}
}

void DuEngine::updateFPS(float timeDelta, float averageTimeDelta) {
	ShaderToyUniforms::UpdateFPS(timeDelta, averageTimeDelta);
}