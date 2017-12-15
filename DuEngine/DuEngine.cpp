/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
* 12/6/2017
*/
#include "stdafx.h"
#include <iostream>
#include <fstream>
#include <string>
#include <thread>
#include "DuEngine.h"
#include "ShaderToy.h"
#include "DuUtils.h"
using namespace std;

Window *Window::s_Instance = new Window();
Window::GC Window::gc;
DuEngine *DuEngine::s_Instance = new DuEngine();
DuEngine::GC DuEngine::gc;

DuEngine::DuEngine() {
	camera = new Camera();
	window = Window::GetInstance();
}

DuEngine* DuEngine::GetInstance() {
	return s_Instance;
}

void Window::reshape(int _width, int _height) {
	width = _width;
	height = _height;
	glViewport(0, 0, width, height);
}

void g_keyboard_up_handler(unsigned char key, int x, int y) {
	DuEngine::GetInstance()->keyboard(key, x, y, true);
}

void g_keyboard_handler(unsigned char key, int x, int y) {
	DuEngine::GetInstance()->keyboard(key, x, y, false);
}

void g_special_up_handler(int key, int x, int y) {
	DuEngine::GetInstance()->special(key, x, y, true);
}

void g_special_handler(int key, int x, int y) {
	DuEngine::GetInstance()->special(key, x, y, false);
}

void g_timer(int id) {
	glutPostRedisplay();
}

// https://stackoverflow.com/questions/12619107/opengl-glut-window-very-slow-why
void g_render() {
	Sleep(1);
#if COMPILE_WITH_TIMER
	DebugTimer::Start("timeDelta");
	DebugTimer::StartAverageWindow("Render");
#endif

	DuEngine::GetInstance()->render();

#if COMPILE_WITH_TIMER
	auto timeDelta = DebugTimer::End("timeDelta", true);
	auto averageTimeDelta = DebugTimer::EndAverageWindow("Render");
	DuEngine::GetInstance()->updateFPS((float)timeDelta, (float)averageTimeDelta);
#endif
};

void g_mousePress(int button, int state, int x, int y) {
	DuEngine::GetInstance()->mousePress(button, state, x, y);
}

void g_mouseMove(int x, int y) {
	DuEngine::GetInstance()->mouseMove(x, y);

}
void g_reshape(int width, int height) {
	DuEngine::GetInstance()->reshape(width, height);
}

void DuEngine::start(int argc, char* argv[]) {
	// setup configuration files and the scene name
	if (argc > 1) {
		configName = std::string(argv[1]);
		config = new DuConfig(configName);
		m_sceneName = configName.substr(0, configName.size() - 4);
	} else {
		config = new DuConfig(DuConfig::DefaultName);
		m_sceneName = "default";
	}

	// setup shaders path and presets path
	m_shadersPath = std::string(argv[0]);

	// automatically search the default shader path from the upper-level folders
	for (int i = 3; i >= 0; --i) {
		if (i == 0) {
			m_shadersPath = ""; 
		} else {
			auto keywords = repeatstring("../", i) + "DuEngine/";
			if (m_shadersPath.find(keywords) != std::string::npos) {
				m_shadersPath = keywords; 
				break; 
			}
		}
	}
	m_shadersPath = config->GetStringWithDefault("shaders_path", m_shadersPath);
#if VERBOSE_OUTPUT
	if (m_shadersPath.size() > 0) {
		info("Relative Path: " + m_shadersPath);
	}
#endif
	m_presetsPath = config->GetStringWithDefault("presets_path", m_shadersPath + "presets/");
	m_resourcesPath = config->GetStringWithDefault("resources_path", m_presetsPath);

	// setup the default window width and height
	m_defaultWidth = config->GetIntWithDefault("window_width", m_defaultWidth);
	m_defaultHeight = config->GetIntWithDefault("window_height", m_defaultHeight);
	string _windowTitle = config->GetStringWithDefault("window_title", "DuRenderer | " + m_sceneName);
	window->init(argc, argv, m_defaultWidth, m_defaultHeight, _windowTitle);

	// setup recording
	m_recording = config->GetBoolWithDefault("recording", m_recording);
	m_recordPath = config->GetStringWithDefault("record_path", m_sceneName);
	m_recordStart = config->GetIntWithDefault("record_start", m_recordStart);
	m_recordEnd = config->GetIntWithDefault("record_end", m_recordEnd);
	m_recordVideo = config->GetBoolWithDefault("record_video", m_recordVideo);

	// initialize the scene, shaders, and presets
	initScene();

	// bind the glut functions
	glutReshapeWindow(window->width, window->height);
	glutDisplayFunc(g_render);
	glutMouseFunc(g_mousePress);
	glutMotionFunc(g_mouseMove);
	glutSpecialFunc(g_special_handler);
	glutSpecialUpFunc(g_special_up_handler);
	glutKeyboardFunc(g_keyboard_handler);
	glutKeyboardUpFunc(g_keyboard_up_handler);
	glutReshapeFunc(g_reshape);
	glutMainLoop();
	exit(EXIT_SUCCESS);
}

void DuEngine::keyboard(unsigned char key, int x, int y, bool up) {
	if (up) {
		switch (key) {
		case GLUT_KEY_ESC:
			exit(EXIT_SUCCESS);
			break;
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			break;
		case '-':
		case '_':
#if COMPILE_WITH_SH
			shadertoy->uniforms->iNumBands--;
			if (shadertoy->uniforms->iNumBands < 0)
				shadertoy->uniforms->iNumBands = 0;
#endif
			break;
		case '=':
		case '+':
#if COMPILE_WITH_SH
			shadertoy->uniforms->iNumBands++;
			if (shadertoy->uniforms->iNumBands >= NUM_BANDS)
				shadertoy->uniforms->iNumBands = NUM_BANDS - 1;
#endif
			break;
		default:
			break;
		}
	}

	if (keyboardTexture) {
		keyboardTexture->onKeyPress(key, up);
	}
}

void DuEngine::special(int key, int x, int y, bool up) {
	if (up) {
		switch (key) {
		case GLUT_KEY_F1:
			// Reset everything
			this->shadertoy->uniforms->reset(this->shadertoy->geometry);
			shadertoy->uniforms->resetTime();
			for (const auto& t : videoTextures) {
				t->resetTime();
			}
			break;

		case GLUT_KEY_F2:
			// Take screenshot
			this->takeScreenshot();
			break;

		case GLUT_KEY_F5:
			// All Reset
			shadertoy->uniforms->resetTime();
			for (const auto& t : videoTextures) {
				t->resetTime();
			}
			break; 
		case GLUT_KEY_F6:
			// Video Pause
			for (const auto& t : videoTextures) {
				t->togglePaused(); 
			}
		case GLUT_KEY_F10:
			// Debug Mouse
			debug(this->shadertoy->uniforms->getMouseString());
			break;

		case GLUT_KEY_F11:
			// Full screen
			m_fullscreen = !m_fullscreen;
			if (m_fullscreen) {
				m_defaultWidth = window->width;
				m_defaultHeight = window->height;
				glutFullScreen();
			} else {
				glutReshapeWindow(m_defaultWidth, m_defaultHeight);
				glutPositionWindow(0, 0);
			}
			break;
		}
	}
	if (keyboardTexture) {
		keyboardTexture->onKeyPress(key, up);
		// hack the four arrows for ShaderToy
		if (100 <= key && key <= 103) {
			key -= 63;
		}
		keyboardTexture->onKeyPress(key, up);
	}
}

void DuEngine::mousePress(int button, int state, int x, int y) {
	if (button != GLUT_LEFT_BUTTON) return;
	if (state == GLUT_DOWN) {
		shadertoy->uniforms->onMouseDown((float)x, (float)y);
	}
	if (state == GLUT_UP) {
		shadertoy->uniforms->onMouseUp((float)x, (float)y);
	}
}

void DuEngine::mouseMove(int x, int y) {
	shadertoy->uniforms->onMouseMove((float)x, (float)y);
}

void DuEngine::reshape(int width, int height) {
	window->reshape(width, height);
	shadertoy->reshape(width, height);
}

int DuEngine::getNumFrameFromVideos() {
	int ans = 0;
	for (const auto &v : videoTextures) {
		ans = std::max(ans, v->getNumVideoFrame());
	}
	return ans;
}

string DuEngine::readTextFromFile(string filename) {
	using std::cout;
	using std::endl;
	using std::string;
	using std::ifstream;
	string str, res = "";
	ifstream in;
	in.open(filename);
	if (in.is_open()) {
		getline(in, str);
		while (in) {
			res += str + "\n";
			getline(in, str);
		}
		return res;
	} else {
		warning("Unable to open file " + filename);
		onError();
	}
}


void DuEngine::reportShaderErrors(const GLint shader) {
	GLint length;
	glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &length);
	GLchar* log = new GLchar[length + 1];
	glGetShaderInfoLog(shader, length, &length, log);
	string s(log);
	logerror("Shader compile error, see log below\n" + s + "\n");
	delete[] log;
	onError();
}


void DuEngine::reportProgramErrors(const GLint program) {
	GLint length;
	glGetProgramiv(program, GL_INFO_LOG_LENGTH, &length);
	GLchar* log = new GLchar[length + 1];
	glGetProgramInfoLog(program, length, &length, log);
	string s(log);
	logerror("Program linking error, see log below\n" + s + "\n");
	delete[] log;
	onError();
}

void DuEngine::onError() {
	system("pause");
	exit(EXIT_FAILURE);
}

void DuEngine::printHelp() {
	info("Help:\n\tF1:\tReset everything.\n\tF2:\tTake Screenshot.\n\tF5:\tReset Time\n\tF6:\tPause\n\tF11:\tFullscreen.\n");
}

GLuint DuEngine::initShaders(GLenum type, string filename, string uniformFileName, string mainFileName) {
	GLuint shader = glCreateShader(type);
	GLint compiled;
	string str = readTextFromFile(filename);
	if (uniformFileName.size() > 0) {
		string pre = readTextFromFile(uniformFileName);
		str = pre + str;
	}
	if (mainFileName.size() > 0) {
		string post = readTextFromFile(mainFileName);
		str = str + post;
	}
	GLchar *cstr = new GLchar[str.size() + 1];
	const GLchar *cstr2 = cstr; // Weirdness to get a const char
	strcpy(cstr, str.c_str());
	glShaderSource(shader, 1, &cstr2, NULL);
	glCompileShader(shader);
	glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
	if (!compiled) {
		reportShaderErrors(shader);
		onError();
	}
	return shader;
}


GLuint DuEngine::initProgram(GLuint vertexshader, GLuint fragmentshader) {
	GLuint program = glCreateProgram();
	GLint linked;
	glAttachShader(program, vertexshader);
	glAttachShader(program, fragmentshader);
	glLinkProgram(program);
	glGetProgramiv(program, GL_LINK_STATUS, &linked);
	if (!linked) {
		reportProgramErrors(program); 
		onError();
	}
	glUseProgram(program);
	return program;
}

void DuEngine::takeScreenshot(string folderName) {
	if (m_isPathCreated.find(folderName) == m_isPathCreated.end()) {
		CreateDirectory(folderName.c_str(), NULL);
		m_isPathCreated.insert(folderName);
	}

	if (m_recordVideo) {
		if (m_video == nullptr) {
			m_video = new cv::VideoWriter();
			m_video->open(folderName + "/" + getTimeForFileName() + ".avi", cv::VideoWriter::fourcc('M', 'J', 'P', 'G'),
				DEFAULT_RENDER_FPS, cv::Size(window->width, window->height));
		} 
	}

	cv::Mat img(window->height, window->width, CV_8UC3);
	glPixelStorei(GL_PACK_ALIGNMENT, (img.step & 3) ? 1 : 4);
	glPixelStorei(GL_PACK_ROW_LENGTH, (GLint)img.step / (GLint)img.elemSize());
	glReadPixels(0, 0, img.cols, img.rows, GL_BGR_EXT, GL_UNSIGNED_BYTE, img.data);
	flip(img, img, 0);


	if (m_recordVideo) {
		m_video->write(img);
		if (getFrameNumber() == m_recordEnd) {
			m_video->release(); 
		}
	} else {
		cv::imwrite(folderName + "/" + this->configName.substr(0, configName.size() - 4) + "_" + to_string(getFrameNumber()) + ".png", img);
	}
}

