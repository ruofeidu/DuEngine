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
#include "TextureVideo.h"

class TextureVideoSequence : public TextureVideo {
 public:
  TextureVideoSequence(){};
  TextureVideoSequence(string fileName, int fps, int startFrame, int endFrame,
                       TextureFilter filter = TextureFilter::LINEAR,
                       TextureWarp warp = TextureWarp::REPEAT);
  void resetTime();
  void update();

 protected:
  vector<Mat> m_videoseq;
};
