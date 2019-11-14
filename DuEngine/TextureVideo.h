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

#pragma once
#include "Texture2D.h"

class TextureVideo : public Texture2D {
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
