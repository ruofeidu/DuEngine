#pragma once
/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
* 12/6/2017
*/
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