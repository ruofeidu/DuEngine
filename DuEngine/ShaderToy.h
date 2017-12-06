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
		vec3 iResolution;
		float iGlobalTime;
		int iFrame;
		vec4 iMouse;
		vec4 iDate;
		vector<GLuint> iChannels;
		vector<GLuint> iVec2Buffers;

	private:
		clock_t startTime;
		GLint linkedProgram;
		GLint uResolution;
		GLint uGlobalTime;
		GLint uFrame;
		GLint uMouse;
		GLint uDate;
		vector<GLint> uChannels;
		vector<GLint> uVec2Buffers;
		float secondsOnStart;

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

		void update(int numVideoFrame = 0);

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

public:
	DuEngine* renderer;
	ShaderToyUniforms* uniforms;
	ShaderToyGeometry* geometry;
	GLuint vertexShader, fragmentShader, shaderProgram;

	ShaderToy(DuEngine* _renderer, double _width, double _height, int _x0, double _y0);

	ShaderToy(DuEngine* _renderer);

	void loadShaders(string vertexShaderName, string fragShaderName, string uniformShaderName, string mainFileName);

	void setTexture2D(cv::Mat &mat, GLuint channel);

	void reshape(int _width, int _height);

	void render();

private:
	int numChannels;
};
