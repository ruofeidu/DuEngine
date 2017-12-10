#pragma once
#include "stdafx.h"
using namespace glm;
using namespace std;

enum ETextureFiltering
{
	TEXTURE_FILTER_MAG_NEAREST = 0, // Nearest criterion for magnification
	TEXTURE_FILTER_MAG_BILINEAR, // Bilinear criterion for magnification
	TEXTURE_FILTER_MIN_NEAREST, // Nearest criterion for minification
	TEXTURE_FILTER_MIN_BILINEAR, // Bilinear criterion for minification
	TEXTURE_FILTER_MIN_NEAREST_MIPMAP, // Nearest criterion for minification, but on closest mipmap
	TEXTURE_FILTER_MIN_BILINEAR_MIPMAP, // Bilinear criterion for minification, but on closest mipmap
	TEXTURE_FILTER_MIN_TRILINEAR, // Bilinear criterion for minification on two closest mipmaps, then averaged
};

enum class TextureFilter : std::int8_t { NEAREST = 0, LINEAR = 1, MIPMAP = 2 };
enum class TextureWrap : std::int8_t { CLAMP = 0, REPEAT = 1 };

class Texture
{
public:
	GLuint current_id = 0;
	GLuint id;
	GLuint sampler;
	bool frameBuffer = false; 
	Mat mat;

	Texture() {}
	GLuint GetTextureID() { 
		return !frameBuffer ? this->id : this->current_id;
	}
	Texture(string filename, bool vflip = true, TextureFilter filter = TextureFilter::LINEAR, TextureWrap warp = TextureWrap::REPEAT);

protected:
	bool _vflip;
	void setFiltering(int a_tfMagnification, int a_tfMinification);
};

class VideoTexture : public Texture
{
public:
	int vFrame;
	VideoTexture(string filename, bool vflip = true, TextureFilter filter = TextureFilter::LINEAR, TextureWrap warp = TextureWrap::REPEAT);
	void togglePaused();
	void update();
	void resetTime();
	int getNumFrame() { return frames; }
private:
	bool paused;
	int frames;
	vector<bool> distribution;
	clock_t prevTime;
	VideoCapture cap;
	Mat smallerMat;
	TextureFilter m_filter;
};

class SHTexture : public Texture
{
public:
	SHTexture(int numBands, int numCoef);
	void update(float coef[NUM_COEF]);
private:
	int m_numBands;
};

class KeyboardTexture : public Texture
{
public:
	KeyboardTexture();
	void onKeyPress(unsigned char key, bool up);

private:
	void onKeyDown(unsigned char key);
	void onKeyUp(unsigned char key);
	void update();
};


class FrameBufferTexture : public Texture
{
public:

	FrameBufferTexture(GLuint FBO, int width, int height, TextureFilter filter = TextureFilter::LINEAR, TextureWrap warp = TextureWrap::REPEAT);
	GLuint GetTextureID();
	void setCommonTextureID(GLuint id); 
private:
};