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

#include "TextureSound.h"
#include "stdafx.h"

/**
 * Sound Texture
 */
TextureSound::TextureSound() {
  m_mat = cv::Mat::zeros(2, 512, CV_8UC1);
  m_filter = TextureFilter::NEAREST;
  m_warp = TextureWarp::CLAMP;
  this->generateFromMat();

  this->type = TextureType::Sound;
}
