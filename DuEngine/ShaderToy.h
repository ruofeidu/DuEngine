#pragma once;
#include "stdafx.h"
#include "DuEngine.h"

using namespace glm;
using namespace std;

class ShaderToy
{
#if COMPILE_WITH_SH
#define NUM_BANDS_SHADER (25)
#define NUM_COEF_SHADER (NUM_BANDS_SHADER * NUM_BANDS_SHADER)
#endif

	struct Vertex
	{
		vec3 position;
		Vertex() {}
		Vertex(glm::vec3 pos) {
			position = pos;
		}
	};

	struct TexVertex
	{
		vec3 position;
		vec2 texCoord;
		TexVertex() {}
		TexVertex(glm::vec3 pos, glm::vec2 tex) {
			position = pos;
			texCoord = tex;
		}
	};

	class ShaderToyGeometry
	{
	public:
		double geometry[4]; /* width, height, x0, y0 (top left) */

	public:
		GLuint	VBO;
		GLuint	VAO;
		GLuint	EBO;
		GLuint	FBO;
		GLuint	layoutPosition, layoutTexCoord, layoutFragCoord;
		Vertex  vertexBuffer[4];
		GLuint	elements[6];

		ShaderToyGeometry(double _width, double _height, double _x0, double _y0);

		void reset(double _width, double _height);

		void reset(double _width, double _height, double _x0, double _y0);

		void render();
	};

	class ShaderToyUniforms
	{
	public:
		// viewport resolution (in pixels)
		vec3 iResolution;
		// shader playback time (in seconds)
		float iGlobalTime;
		// shader playback frame
		int iFrame;
		// mouse pixel coords. xy: current (if MLB down), zw: click
		vec4 iMouse;
		// (year, month, day, time in seconds)
		vec4 iDate;
		// render time (in seconds)
		float iTimeDelta = 1000.0f / 60.0f;
		// the frame rate as int
		int iFrameRate = 60;
		// input channel. XX = 2D/Cube
		vector<GLuint> iChannels;
		// buffers of vector2
		vector<GLuint> iVec2Buffers;

	private:
		clock_t startTime;
		GLint linkedProgram;
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
		// render time (in seconds)
		GLint uTimeDelta;
		// the frame rate as int
		GLint uFrameRate;
		// input channel. XX = 2D/Cube
		vector<GLint> uChannels;
		// channel resolution (in pixels)
		vector<GLint> uChannelResolution;
		// channel playback time (in seconds)
		vector<GLint> uChannelTimes;
		// buffers of vector2
		vector<GLint> uVec2Buffers;

	private:
		bool mouseDown = false; 

	private:
		vector<vector<vec2>> vec2_buffers;

	public:
		ShaderToyUniforms(ShaderToyGeometry* geom, int numChannels);

		void reset(ShaderToyGeometry* geom);
		void resetTime();

		void linkShader(GLuint shaderProgram);

		void bindTexture2D(GLuint tex, GLuint channel);

		void bindVec2Buffer(GLuint channel, string fileName);

		void intVec2Buffers(int numBuffers);

		void update();

		void updateFPS(float timeDelta, float averageTimeDelta); 

		void onMouseMove(float x, float y);

		void onMouseDown(float x, float y);

		void onMouseUp(float x, float y);

		string getMouseString();


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

	friend class DuEngine;

	class ShaderToyFrameBuffer
	{
	public:
		DuEngine* renderer;
		ShaderToyUniforms* uniforms;
		ShaderToyGeometry* geometry;
		GLuint vertexShader, fragmentShader, shaderProgram;
		// FBO, frame buffer object ID
		GLuint id; 
		// texture object
		GLuint textureID;

	public:
		ShaderToyFrameBuffer(DuEngine* _renderer, ShaderToyGeometry* _geometry, int numChannels);
		void loadShaders(string vertexShaderName, string fragShaderName, string uniformShaderName, string mainFileName);
		GLuint getID() const;
		void render() const;
	};

public:
	DuEngine* renderer;
	ShaderToyUniforms* uniforms;
	ShaderToyGeometry* geometry;
	GLuint vertexShader, fragmentShader, shaderProgram;
	vector<ShaderToyFrameBuffer> m_frameBuffers;

	ShaderToy(DuEngine* _renderer, double _width, double _height, int _x0, double _y0);

	ShaderToy(DuEngine* _renderer);

	void loadShaders(string vertexShaderName, string fragShaderName, string uniformShaderName, string mainFileName);

	void setTexture2D(cv::Mat &mat, GLuint channel);

	void reshape(int _width, int _height);

	void render();

public:


private:
	int numChannels;
};
