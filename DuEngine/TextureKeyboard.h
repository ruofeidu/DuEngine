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

class TextureKeyboard : public Texture2D
{
public:
	TextureKeyboard();
	void onKeyPress(unsigned char key, bool up);

private:
	// response time for the keyPress event, by ms
	clock_t RESPONSE_TIME = 16;
	// the last time when each key is pressed
	clock_t prevTimes[256];
private:
	void onKeyDown(unsigned char key);
	void onKeyUp(unsigned char key);
};
