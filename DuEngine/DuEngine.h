#pragma once
#include "stdafx.h"
#include "ShaderToy.h"
#include "DuConfig.h"
#include "Texture.h"

using namespace glm;
using namespace cv;
using namespace std;

class Singleton
{
public:
	static Singleton *GetInstance();

private:
	static Singleton *s_Instance;

	class GC
	{
	public:
		~GC() {
			if (s_Instance != NULL) {
				delete s_Instance;
				s_Instance = NULL;
			}
		}
	};
	static GC gc;
};

class Camera
{
public:
	Camera();
	void reset();
	vec3 eye, up, center;

private:
	static Camera *s_Instance;
};

class Window
{
public:
	static Window *GetInstance();
	void init(int argc, char* argv[], int width, int height, string _windowTitle);
	void reshape(int _width, int _height);
	int width, height;

private:
	static Window *s_Instance;
	class GC
	{
	public:
		~GC() {
			if (s_Instance != NULL) {
				delete s_Instance;
				s_Instance = NULL;
			}
		}
	};
	static GC gc;
};

void g_render();
void g_mousePress(int button, int state, int x, int y);
void g_mouseMove(int x, int y);
void g_reshape(int width, int height);

class DuEngine
{
	friend class ShaderToy;
	friend class Texture;
	friend class VideoTexture;
	friend class KeyboardTexture;
	friend class SHTexture;

public:
	static DuEngine *GetInstance();
	void start(int argc, char* argv[]);
	void initScene();

protected:
	vector<VideoTexture*> videoTextures;
	KeyboardTexture* keyboardTexture;
	Texture* fontTexture;
	vector<Texture*> textures;

public:
	void render();
	void updateFPS(float timeDelta, float averageTimeDelta);
	void takeScreenshot(string folderName = "snapshots");
	void keyboard(unsigned char key, int x, int y, bool up = false);
	void special(int key, int x, int y, bool up = false);
	void mousePress(int button, int state, int x, int y);
	void mouseMove(int x, int y);
	void reshape(int width, int height);

private:
	DuEngine();

	int getFrameNumber();
	static DuEngine *s_Instance;
	clock_t beginTime;
	Camera* camera;
	Window* window;
	ShaderToy* shadertoy;
	DuConfig* config;
	string configName;
	string m_sceneName;
	bool m_fullscreen = false;
	bool m_recording = false;
	string m_recordPath = "";
	string m_relativePath = "";

	int m_recordStart = 0;
	int m_recordEnd = 100;
	int m_defaultWidth = 1920;
	int m_defaultHeight = 1080;
	unordered_set<string> m_is_created; 

	unordered_map<string, string> m_common_tex {
		{ "pano", "panorama.png" },
		{ "abstract1", "tex07.jpg" },
		{ "abstract2", "tex08.jpg" },
		{ "abstract3", "tex20.jpg" },
		{ "bayer", "tex15.png" },
		{ "gnm", "tex12.png" },
		{ "gns", "tex10.png" },
		{ "lichen", "tex06.png" },
		{ "london", "tex04.jpg" },
		{ "nyancat", "tex14.png" },
		{ "organic1", "tex01.jpg" },
		{ "organic2", "tex03.jpg" },
		{ "organic3", "tex18.jpg" },
		{ "organic4", "tex17.jpg" },
		{ "pebbles", "tex19.png" },
		{ "rgbanm", "tex16.png" },
		{ "rgbans", "tex11.png" },
		{ "rocktiles", "tex00.jpg" },
		{ "rustymetal", "tex02.jpg" },
		{ "stars", "tex03.jpg" },
		{ "wood", "tex05.jpg" },
		//{ "font", "tex21.png" },
	};

	int getNumFrameFromVideos();

	string readTextFromFile(string filename);

	void reportShaderErrors(const GLint shader);

	void reportProgramErrors(const GLint shader);

	GLuint initShaders(GLenum type, string filename, string uniformFileName = "", string mainFileName = "");

	GLuint initProgram(GLuint vertexshader, GLuint fragmentshader);

	GLuint matToTexture2D(cv::Mat & mat, GLuint format, GLenum minFilter, GLenum magFilter, GLenum wrapFilter, GLuint datatype = GL_UNSIGNED_BYTE);

	class GC
	{
	public:
		~GC() {
			if (s_Instance != NULL) {
				delete s_Instance;
				s_Instance = NULL;
			}
		}
	};
	static GC gc;
};
