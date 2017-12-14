#pragma once
#include "stdafx.h"
using namespace glm;
using namespace std;
using namespace cv;

#if DEBUG_TEXTURE_DEPRECATED_FILTERING
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
#endif

enum class TextureFilter : std::int8_t { NEAREST, LINEAR, MIPMAP };
enum class TextureWarp : std::int8_t { CLAMP, REPEAT };
enum class TextureType : std::int8_t { Unknown, RGB, VideoFile, VideoSequence, Keyboard, Font, SH, FrameBuffer, Volume, LightField };

class Texture
{
public:
	static TextureType QueryType(string str);
	static TextureFilter QueryFilter(string str);
	static TextureWarp QueryWarp(string str);
	const static unordered_map<string, TextureType> TextureMaps;
	const static unordered_map<string, string> ImageTextures;
	const static unordered_map<string, string> VideoTextures;
	const static unordered_map<string, string> FontTextures;

public:
	Texture() {};
	// Acquire the current texture unit id for reading and binding to shader uniforms
	GLuint getTextureID();
	// Acquire the binded texture unit id
	GLuint getDirectID();
	// Acquire the texture type
	TextureType getType();

protected:
	TextureType type = TextureType::Unknown;
	// The binded texture id
	GLuint id = 0;
	// The texture id for reading
	GLuint read_texture_id = 0;

	TextureFilter m_filter = TextureFilter::LINEAR;
	TextureWarp m_warp = TextureWarp::REPEAT;

	// Generate, active, bind, and set filtering, all in one!
	void genTexture2D();

	// Check filtering and generate mipmaps
	void generateMipmaps();

	// Setup filtering based on the two protected parameters, m_filter and m_warp
	void setFiltering();

private:
	GLenum m_minFilter = GL_LINEAR, m_magFilter = GL_LINEAR, m_wrapFilter = GL_CLAMP;
#if DEBUG_TEXTURE_DEPRECATED_FILTERING
private:
	GLuint m_sampler; 
	// deprecated("Not using it")
	void setFiltering(int a_tfMagnification, int a_tfMinification);
#endif
};

class TextureMat : public Texture
{
public:
	TextureMat() {};
	TextureMat(string filename, bool vflip = true, TextureFilter filter = TextureFilter::LINEAR, TextureWarp warp = TextureWarp::REPEAT);
	void init(string filename, bool vflip = true, TextureFilter filter = TextureFilter::LINEAR, TextureWarp warp = TextureWarp::REPEAT);

protected:
	Mat m_mat = Mat();
	string m_filename = "";
	bool m_vFlip = true;
	GLuint m_format = GL_BGR;
	GLuint m_dataType = GL_UNSIGNED_BYTE;

protected:
	// Generate, active, bind, and set filtering, 
	// update date type format of the mat
	// texImage2D from the mat
	// generate mipmaps, all in one!
	void generateFromMat();
	void updateFromMat(); 
	void updateDataTypeFormat();

private:
	void generateFromMat(cv::Mat& mat);
	void datatypeFromMat(cv::Mat& mat);
	void formatFromMat(cv::Mat& mat);
};

class Texture2D : public TextureMat
{
public:
	Texture2D() {};
	Texture2D(string filename, bool vflip = true, TextureFilter filter = TextureFilter::LINEAR, TextureWarp warp = TextureWarp::REPEAT);
};

class FontTexture : public Texture2D
{
public:
	FontTexture(TextureFilter filter, TextureWarp warp);
};

class VideoTexture : public Texture2D
{
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

class VideoFileTexture : public VideoTexture
{
public:
	VideoFileTexture(string filename, bool vflip = true, TextureFilter filter = TextureFilter::LINEAR, TextureWarp warp = TextureWarp::REPEAT);
	void resetTime();
	void update();

private:
	VideoCapture m_video;
};

class VideoSequenceTexture : public VideoTexture
{
public:
	VideoSequenceTexture(string fileName, int fps, int startFrame, int endFrame, TextureFilter filter = TextureFilter::LINEAR, TextureWarp warp = TextureWarp::REPEAT);
	void resetTime();
	void update();

private:
	vector<Mat> m_videoseq; 
};

#if COMPILE_WITH_SH
class SHTexture : public TextureMat
{
public:
	SHTexture(int numBands, int numCoef);
	void update(float coef[NUM_COEF]);
private:
	int m_numBands;
};
#endif

class KeyboardTexture : public Texture2D
{
public:
	KeyboardTexture();
	void onKeyPress(unsigned char key, bool up);

private:
	// response time for the keyPress event, by ms
	clock_t RESPONSE_TIME = 40;
	// the last time when each key is pressed
	clock_t prevTimes[256];
private:
	void onKeyDown(unsigned char key);
	void onKeyUp(unsigned char key);
};


class FrameBufferTexture : public Texture
{
public:
	FrameBufferTexture(GLuint FBO, int width, int height, TextureFilter filter = TextureFilter::LINEAR, TextureWarp warp = TextureWarp::REPEAT);
	void setReadingTextureID(GLuint id);
	void reshape(int _width, int _height);
private:
};

