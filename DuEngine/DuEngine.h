#pragma once
#include "stdafx.h"
#include "ShaderToy.h"
#include "DuConfig.h"
#include "TexturesManager.h"
#include "PathManager.h"
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

public:
	static DuEngine *GetInstance();
	void start(int argc, char* argv[]);
	void initScene();

protected:
	TexturesManager* m_textureManager; 
	PathManager* m_path;

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
	string getPresetsPath() { return m_path->getPresetPath(); }

private:
	DuEngine();
	static DuEngine *s_Instance;
	clock_t beginTime;
	Camera* camera;
	Window* m_window;
	ShaderToy* m_shadertoy;
	DuConfig* m_config;
	bool m_fullscreen = false;
	bool m_recording = false;
	bool m_paused = false; 

	string m_recordPath = "";
	int m_recordStart = 0;
	int m_recordEnd = 100;
	bool m_recordVideo = false;
	cv::VideoWriter* m_video = nullptr;
	int m_defaultWidth = 1280;
	int m_defaultHeight = 720;
	bool m_takeSingleScreenShot = false; 

private:
	void toggleFullScreen();

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
