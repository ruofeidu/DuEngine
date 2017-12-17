#pragma once
#include "stdafx.h"
#include "ShaderToy.h"
#include "DuConfig.h"
#include "TexturesManager.h"
#include "Camera.h"
#include "Window.h"
#include "DuUtils.h"

using namespace glm;
using namespace cv;
using namespace std;

void g_render();
void g_mousePress(int button, int state, int x, int y);
void g_mouseMove(int x, int y);
void g_reshape(int width, int height);

class DuEngine
{
	friend class ShaderToy;
	friend class Texture;
	friend class TextureVideo;
	friend class TextureKeyboard;
	friend class TextureSH;

public:
	static DuEngine *GetInstance();
	void start(int argc, char* argv[]);
	void initScene();

protected:
	vector<TextureVideo*> videoTextures;
	TextureKeyboard* keyboardTexture;
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

	int getFrameNumber();
	string getPresetsPath() { return m_presetsPath; }

private:
	DuEngine();
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
	bool m_paused = false; 

	string m_shadersPath = "";
	string m_presetsPath = "";
	string m_resourcesPath = "";
	unordered_set<string> m_isPathCreated;

	string m_recordPath = "";
	int m_recordStart = 0;
	int m_recordEnd = 100;
	bool m_recordVideo = false;
	cv::VideoWriter* m_video = nullptr;
	int m_defaultWidth = 1280;
	int m_defaultHeight = 720;

private:
	int getNumFrameFromVideos();

	void printHelp(); 

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
