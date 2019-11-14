// DuEngine: Real-time Rendering Engine and Shader Testbed
// Ruofei Du | http://www.duruofei.com
//
// Creative Commons Attribution-ShareAlike 3.0 License with 996 ICU clause:
//
// The above license is only granted to entities that act in concordance with
// local labor laws. In addition, the following requirements must be observed:
// The licensee must not, explicitly or implicitly, request or schedule their
// employees to work more than 45 hours in any single week. The licensee must
// not, explicitly or implicitly, request or schedule their employees to be at
// work consecutively for 10 hours. For more information about this protest, see
// http://996.icu

#include "stdafx.h"
#include "DuEngine.h"
#include "DuUtils.h"
using namespace std;
using namespace cv;

void DuEngine::initScene() {
  m_shadertoy = new ShaderToy(DuEngine::GetInstance());
  m_shadertoy->recompile(this);
}

int DuEngine::getFrameNumber() { return ShaderToyUniforms::iFrame; }

void DuEngine::render() {
  if (!m_paused) {
    m_textureManager->update();

    if (m_renderType == RendererType::SHADERTOY) m_shadertoy->render();

    glutSwapBuffers();
    glutPostRedisplay();
  }

  if (m_recording && m_recordStart <= getFrameNumber() &&
      getFrameNumber() <= m_recordEnd) {
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
