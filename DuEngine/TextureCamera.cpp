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
#include "TextureCamera.h"
#include "DuEngine.h"

TextureCamera::TextureCamera(bool vflip, TextureFilter filter,
                             TextureWarp warp) {
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
  // if (!m_distribution[iFrame % m_distribution.size()]) return;

  m_prevTime = clock();
  m_video >> m_mat;
  m_numVideoFrames++;

  if (m_mat.empty()) {
    this->error();
  }
  if (m_vFlip) flip(m_mat, m_mat, 0);

  this->updateFromMat();

#if DEBUG_VIDEO
  info("video texture " + to_string(id) + " updated for the frame #" +
       to_string(frames));
#endif
}

TextureCamera::~TextureCamera() { m_video.release(); }

void TextureCamera::resetTime() { m_numVideoFrames = 0; }
