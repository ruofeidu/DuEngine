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
