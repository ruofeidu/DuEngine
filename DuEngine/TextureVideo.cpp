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
#include "TextureVideo.h"
#include "DuUtils.h"

void TextureVideo::togglePaused() { m_paused = !m_paused; }

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
