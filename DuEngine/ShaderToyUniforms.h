#pragma once
#include "stdafx.h"
#include "Texture.h"
#include "Uniforms.h"
#include "ShaderProgram.h"
#include "ShaderToyGeometry.h"

#if COMPILE_WITH_SH
#define NUM_BANDS_SHADER (25)
#define NUM_COEF_SHADER (NUM_BANDS_SHADER * NUM_BANDS_SHADER)
#endif

class ShaderToyUniforms : public Uniforms
{
public:
	// viewport resolution (in pixels)
	static vec3 iResolution;
	// shader playback time (in seconds)
	static float iGlobalTime;
	// shader playback frame
	static int iFrame;
	// let the first three frames the same
	int iSkip = SKIP_FIRST_FRAMES;
	// mouse pixel coords. xy: current (if MLB down), zw: click
	static vec4 iMouse;
	// (year, month, day, time in seconds)
	static vec4 iDate;
	// rendering time (in seconds)
	static float iTimeDelta;
	// the frame rate as int
	static int iFrameRate;
	// input channel. XX = 2D/Cube
	vector<Texture*> iChannels;
	// buffers of vector2
	vector<GLuint> iVec2Buffers;

private:
	clock_t startTime;
	float secondsOnStart;

	// location of uniforms
private:
	// viewport resolution (in pixels)
	GLint uResolution;
	// shader playback time (in seconds)
	GLint uGlobalTime;
	// shader playback frame
	GLint uFrame;
	// mouse pixel coords. xy: current (if MLB down), zw: click
	GLint uMouse;
	// (year, month, day, time in seconds)
	GLint uDate;
	// rendering time (in seconds)
	GLint uTimeDelta;
	// the frame rate as int
	GLint uFrameRate;

public:
	// input channel. XX = 2D/Cube
	vector<GLint> uChannels;
	// channel resolution (in pixels)
	vector<GLint> uChannelResolutions;
	// channel playback time (in seconds)
	vector<GLint> uChannelTimes;
	// buffers of vector2
	vector<GLint> uVec2Buffers;

private:
	static bool MouseDown;

private:
	vector<vector<vec2>> vec2_buffers;

public:
	ShaderToyUniforms(ShaderToyGeometry* geom, int numChannels);

	void reset(int _width, int _height) override;

	void reset(ShaderToyGeometry* geom) override;

	void resetTime();

	void resetFrame();

	void linkShaderProgram(ShaderProgram* shaderProgram);

	void bindTexture2D(Texture* texture, GLuint channel);

	void bindVec2Buffer(GLuint channel, string fileName);

	void intVec2Buffers(int numBuffers);

	void update();

	void updateResolution(int _width, int _height);

	static void UpdateFPS(float timeDelta, float averageTimeDelta);

	static void OnMouseMove(float x, float y);

	static void OnMouseDown(float x, float y);

	static void OnMouseUp(float x, float y);

public:
	static string GetMouseString();

private:
	static void Set(GLint location, vec4 &v);
	static void Set(GLint location, vec3 &v);
	static void Set(GLint location, vec2 &v);
	static void Set(GLint location, float value);
	static void Set(GLint location, int value);
	static void Set(GLint location, Texture* texture);

#if COMPILE_WITH_SH
private:
	GLint uSHCoefs;
	GLint uSph;
	GLint uNumBands;
	GLint uK;

public:
	vec2 vSph;
	GLfloat shCoef[NUM_COEF_SHADER * 3];
	GLfloat vK[NUM_COEF_SHADER];
	int iNumBands;
	int lastFrame;
	void updateSHCoefficients(vector<cv::Vec3d> &shCoefficients);
	bool updateSHCoefficientsFromFile(int numFrame);
	void updateK(vector<float> &vK);
#endif
};

