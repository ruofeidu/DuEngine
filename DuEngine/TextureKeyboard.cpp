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
#include "TextureKeyboard.h"

/**
 * Keyboard Texture
 */
TextureKeyboard::TextureKeyboard() {
  m_mat = cv::Mat::zeros(3, 256, CV_8UC1);
  m_filter = TextureFilter::NEAREST;
  m_warp = TextureWarp::CLAMP;
  this->generateFromMat();
  memset(prevTimes, 0, 256);
  this->type = TextureType::Keyboard;
}

// 0 is current state (keydown event)
// 1 is keypress event
// 2 is toggle
void TextureKeyboard::onKeyDown(unsigned char key) {
  m_mat.at<uchar>(1, key) = 255;
  if (clock() - prevTimes[key] > RESPONSE_TIME) {
    m_mat.at<uchar>(0, key) = 255;
    prevTimes[key] = clock();
  } else {
    m_mat.at<uchar>(0, key) = 0;
  }
#if DEBUG_KEYBOARD
  info("Key down " + to_string(key));
#endif
}

void TextureKeyboard::onKeyUp(unsigned char key) {
  m_mat.at<uchar>(2, key) = 255 - m_mat.at<uchar>(2, key);
  m_mat.at<uchar>(1, key) = 0;
  m_mat.at<uchar>(0, key) = 0;
  prevTimes[key] = clock();
#if DEBUG_KEYBOARD
  info("Key up " + to_string(key));
#endif
}

void TextureKeyboard::onKeyPress(unsigned char key, bool up) {
  if (up) {
    onKeyUp(key);
  } else {
    onKeyDown(key);
  }
  this->updateFromMat();
}
