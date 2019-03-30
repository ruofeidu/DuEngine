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
