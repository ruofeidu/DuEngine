/**
* Thelia Renderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab
* 5/9/2017
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

Singleton *Singleton::s_Instance = new Singleton();
Singleton::GC Singleton::gc;
Window *Window::s_Instance = new Window();
Window::GC Window::gc;
DuEngine *DuEngine::s_Instance = new DuEngine();
DuEngine::GC DuEngine::gc;

Singleton* Singleton::GetInstance() {
	return s_Instance;
}

Camera::Camera() {
	reset();
}

void Camera::reset() {
	eye = vec3(0.0, 0.0, 1.0);
	up = vec3(0.0, 1.0, 0.0);
	center = vec3(0.0);
}

DuEngine::DuEngine() {
	camera = new Camera();
	window = Window::GetInstance();
}

DuEngine* DuEngine::GetInstance() {
	return s_Instance;
}

Window* Window::GetInstance() {
	return s_Instance;
}

void Window::init(int argc, char* argv[], int _width, int _height, string _windowTitle) {
	clock_t beginTime = clock();
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
	glutCreateWindow(_windowTitle.c_str());
	width = _width;
	height = _height;
	GLenum err = glewInit();
	if (GLEW_OK != err) {
		std::cerr << "Error: " << glewGetString(err) << std::endl;
	}
	info("Window Creation costs: " + to_string(float(clock() - beginTime) / CLOCKS_PER_SEC) + " s");
}

void Window::reshape(int _width, int _height) {
	width = _width;
	height = _height;
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(90, width / (float)height, 0.1, 99);
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
	if (argc > 1) {
		configName = std::string(argv[1]);
		config = new DuConfig(configName);
		m_sceneName = configName.substr(0, configName.size() - 4);
	} else {
		config = new DuConfig(DuConfig::DefaultName);
		m_sceneName = "default";
	}

	m_relativePath = std::string(argv[0]);
	if (m_relativePath.find("../../DuEngine/") != std::string::npos) {
		m_relativePath = "../../DuEngine/";
	} else if (m_relativePath.find("../DuEngine/") != std::string::npos) {
		m_relativePath = "../DuEngine/";
	} else {
		m_relativePath = ""; 
	}
	m_relativePath = config->GetStringWithDefault("shader_default", m_relativePath);
	if (m_relativePath.size() > 0) {
		info("Relative Path: " + m_relativePath);
	}

	m_defaultWidth = config->GetIntWithDefault("window_width", m_defaultWidth);
	m_defaultHeight = config->GetIntWithDefault("window_height", m_defaultHeight);
	string _windowTitle = config->GetStringWithDefault("window_title", "DuRenderer | " + m_sceneName);
	window->init(argc, argv, m_defaultWidth, m_defaultHeight, _windowTitle);

	m_recording = config->GetBoolWithDefault("recording", m_recording);
	m_recordPath = config->GetStringWithDefault("record_path", m_recordPath);
	m_recordStart = config->GetIntWithDefault("record_start", m_recordStart);
	m_recordEnd = config->GetIntWithDefault("record_end", m_recordEnd);

	initScene();

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
		case GLUT_KEY_ESC:
			exit(EXIT_SUCCESS);
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
	}
}

void DuEngine::mousePress(int button, int state, int x, int y) {
	if (button != GLUT_LEFT_BUTTON) return;

	if (state == GLUT_DOWN) {
		shadertoy->uniforms->onMouseDown((float)x, (float)y);
	} else
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
		ans = std::max(ans, v->vFrame);
	}
	return ans;
}

string DuEngine::readTextFromFile(string filename) {
	using std::cout;
	using std::endl;
	using std::string;
	using std::ifstream;
	string str, ret = "";
	ifstream in;
	in.open(filename);
	if (in.is_open()) {
		getline(in, str);
		while (in) {
			ret += str + "\n";
			getline(in, str);
		}
		//    cout << "Shader below\n" << ret << "\n"; 
		return ret;
	} else {
		warning("Unable to open file " + filename);
		throw 2;
	}
}


void DuEngine::reportShaderErrors(const GLint shader) {
	GLint length;
	GLchar * log;
	glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &length);
	log = new GLchar[length + 1];
	glGetShaderInfoLog(shader, length, &length, log);
	cout << "Compile Error,Log Below\n" << log << "\n";
	delete[] log;
}


void DuEngine::reportProgramErrors(const GLint program) {
	GLint length;
	GLchar * log;
	glGetProgramiv(program, GL_INFO_LOG_LENGTH, &length);
	log = new GLchar[length + 1];
	glGetProgramInfoLog(program, length, &length, log);
	string s(log);
	error("Compile Error, see log Below\n" + s + "\n");
	delete[] log;
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

	GLchar * cstr = new GLchar[str.size() + 1];
	const GLchar * cstr2 = cstr; // Weirdness to get a const char
	strcpy(cstr, str.c_str());
	glShaderSource(shader, 1, &cstr2, NULL);
	glCompileShader(shader);
	glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
	if (!compiled) {
		reportShaderErrors(shader);
		system("pause");
		throw 3;
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
	if (linked) glUseProgram(program);
	else {
		reportProgramErrors(program);
		system("pause");
		throw 4;
	}
	return program;
}

// https://www.khronos.org/registry/OpenGL-Refpages/es2.0/xhtml/glTexParameter.xml
// minFilters: GL_NEAREST, GL_LINEAR, GL_NEAREST_MIPMAP_NEAREST, GL_LINEAR_MIPMAP_NEAREST, GL_NEAREST_MIPMAP_LINEAR, GL_LINEAR_MIPMAP_LINEAR
// magFilters: GL_NEAREST, GL_LINEAR
// GL_TEXTURE_WRAP_S: GL_CLAMP_TO_EDGE, GL_MIRRORED_REPEAT, GL_REPEAT
GLuint DuEngine::matToTexture2D(cv::Mat &mat, GLuint format, GLenum minFilter, GLenum magFilter, GLenum wrapFilter, GLuint datatype) {
	// Generate a number for our textureID's unique handle
	GLuint textureID;
	glGenTextures(1, &textureID);
	glActiveTexture(GL_TEXTURE0 + textureID);
	// Bind to our texture handle
	glBindTexture(GL_TEXTURE_2D, textureID);

	// Catch silly-mistake texture interpolation method for magnification
	if (magFilter == GL_LINEAR_MIPMAP_LINEAR ||
		magFilter == GL_LINEAR_MIPMAP_NEAREST ||
		magFilter == GL_NEAREST_MIPMAP_LINEAR ||
		magFilter == GL_NEAREST_MIPMAP_NEAREST) {
		warning("! You can't use MIPMAPs for magnification - setting filter to GL_LINEAR"); 
		magFilter = GL_LINEAR;
	}

	// Set texture interpolation methods for minification and magnification
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);

	// Set texture clamping methodw
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapFilter);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapFilter);

	// Set incoming texture format to:
	// GL_BGR       for CV_CAP_OPENNI_BGR_IMAGE,
	// GL_LUMINANCE for CV_CAP_OPENNI_DISPARITY_MAP,
	// Work out other mappings as required ( there's a list in comments in main() )
	GLenum inputColourFormat = format;
	if (mat.channels() == 1) {
		inputColourFormat = GL_LUMINANCE;
	}

	// Create the texture
	glTexImage2D(GL_TEXTURE_2D,     // Type of texture
		0,					// Pyramid level (for mip-mapping) - 0 is the top level
		GL_RGB,				// Internal colour format to convert to
		mat.cols,			// Image width  i.e. 640 for Kinect in standard mode
		mat.rows,			// Image height i.e. 480 for Kinect in standard mode
		0,					// Border width in pixels (can either be 1 or 0)
		inputColourFormat,	// Input image format (i.e. GL_RGB, GL_RGBA, GL_BGR etc.)
		datatype,	// Image data type
		mat.ptr());			// The actual image data itself

							// If we're using mipmaps then generate them. Note: This requires OpenGL 3.0 or higher	   
	if ((
		minFilter == GL_LINEAR_MIPMAP_LINEAR ||
		minFilter == GL_LINEAR_MIPMAP_NEAREST ||
		minFilter == GL_NEAREST_MIPMAP_LINEAR ||
		minFilter == GL_NEAREST_MIPMAP_NEAREST)) {
		glGenerateMipmap(GL_TEXTURE_2D);
		info("Mipmap generated for " + textureID);
	}

	GLenum err = glGetError();
	if (err != GL_NO_ERROR) cout << "Texture" << err << endl;

	return textureID;
}

Texture::Texture(string filename, bool vflip, TextureFilter filter, TextureWrap warp) {
	mat = imread(filename);
	if (vflip) flip(mat, mat, 0);
	//glGenSamplers(1, &sampler);
	GLenum warpFilter = (warp == TextureWrap::REPEAT) ? GL_REPEAT : GL_CLAMP;

	switch (filter) {
	case TextureFilter::NEAREST:
		id = DuEngine::GetInstance()->matToTexture2D(mat, GL_BGR, GL_NEAREST, GL_NEAREST, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_NEAREST, TEXTURE_FILTER_MIN_NEAREST);
		break;
	case TextureFilter::LINEAR:
		id = DuEngine::GetInstance()->matToTexture2D(mat, GL_BGR, GL_LINEAR, GL_LINEAR, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_BILINEAR, TEXTURE_FILTER_MIN_NEAREST_MIPMAP);
		break;
	case TextureFilter::MIPMAP:
		id = DuEngine::GetInstance()->matToTexture2D(mat, GL_BGR, GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_BILINEAR, TEXTURE_FILTER_MIN_TRILINEAR);
		break;
	}
	GLenum err = glGetError();
	if (err != GL_NO_ERROR) cout << "Texture" << err << endl;
}

void Texture::setFiltering(int a_tfMagnification, int a_tfMinification) {
	// Set magnification filter
	if (a_tfMagnification == TEXTURE_FILTER_MAG_NEAREST)
		glSamplerParameteri(sampler, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	else if (a_tfMagnification == TEXTURE_FILTER_MAG_BILINEAR)
		glSamplerParameteri(sampler, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	// Set minification filter
	if (a_tfMinification == TEXTURE_FILTER_MIN_NEAREST)
		glSamplerParameteri(sampler, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	else if (a_tfMinification == TEXTURE_FILTER_MIN_BILINEAR)
		glSamplerParameteri(sampler, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	else if (a_tfMinification == TEXTURE_FILTER_MIN_NEAREST_MIPMAP)
		glSamplerParameteri(sampler, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
	else if (a_tfMinification == TEXTURE_FILTER_MIN_BILINEAR_MIPMAP)
		glSamplerParameteri(sampler, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
	else if (a_tfMinification == TEXTURE_FILTER_MIN_TRILINEAR)
		glSamplerParameteri(sampler, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
}

VideoTexture::VideoTexture(string filename, bool vflip, TextureFilter filter, TextureWrap warp) {
	cap.open(filename);
	_vflip = vflip;
	if (!cap.isOpened()) {
		error("Cannot open the video texture."); 
		return;
	}
	cap >> mat;
	if (mat.empty()) {
		error("Cannot open the video texture.");
		return; 
	}
	if (_vflip) flip(mat, mat, 0);
	frames = 0;
	//glGenSamplers(1, &sampler);
	GLenum warpFilter = (warp == TextureWrap::REPEAT) ? GL_REPEAT : GL_CLAMP;
	switch (filter) {
	case TextureFilter::NEAREST:
		id = DuEngine::GetInstance()->matToTexture2D(mat, GL_BGR, GL_NEAREST, GL_NEAREST, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_NEAREST, TEXTURE_FILTER_MIN_NEAREST);
		break;
	case TextureFilter::LINEAR:
		id = DuEngine::GetInstance()->matToTexture2D(mat, GL_BGR, GL_LINEAR, GL_LINEAR, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_BILINEAR, TEXTURE_FILTER_MIN_NEAREST_MIPMAP);
		break;
	case TextureFilter::MIPMAP:
		id = DuEngine::GetInstance()->matToTexture2D(mat, GL_BGR, GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, warpFilter);
		break;
	default:
		error("Cannot set unknown filters, use linear instead");
		id = DuEngine::GetInstance()->matToTexture2D(mat, GL_BGR, GL_LINEAR, GL_LINEAR, warpFilter);
		//setFiltering(TEXTURE_FILTER_MAG_BILINEAR, TEXTURE_FILTER_MIN_NEAREST_MIPMAP);
		break;
	}
	prevTime = clock();
	vFrame = 0;
	const int RENDER_FPS = 60;
	distribution = vector<bool>(RENDER_FPS, false);
	float video_fps = 25.0;
	float p = 0.0;
	while (p < RENDER_FPS) {
		distribution[(int)floor(p)] = true;
		p += (float)RENDER_FPS / video_fps;
	}
}

void VideoTexture::togglePaused() {
	paused = !paused;
}

void VideoTexture::update() {
	//double fps = 25;
	//if ((clock() - prevTime) < 1000.0 / fps) return; 
	const int DELTA = 2;
	int iFrame = DuEngine::GetInstance()->getFrameNumber();
	if (iFrame < DELTA) return;
	iFrame -= DELTA;
	if (!distribution[iFrame % distribution.size()]) return;

	prevTime = clock();
	cap >> mat;
	vFrame++;
	if (mat.empty()) {
		cap.set(CV_CAP_PROP_POS_FRAMES, 0);
		cap >> mat;
	}
	if (_vflip) flip(mat, mat, 0);
	++frames;

	glBindTexture(GL_TEXTURE_2D, id);
	glTexSubImage2D(
		GL_TEXTURE_2D,
		0,                   // GLint level,
		0, 0,                // GLint xoffset, GLint yoffset,
		mat.cols, mat.rows,  // GLsizei width, GLsizei height,
		GL_BGR,              // GLenum format,
		GL_UNSIGNED_BYTE,    // GLenum type,
		mat.ptr()            // const GLvoid * pixels
		);
	// info("video texture " + to_string(id) + " updated for the frame #" + to_string(frames)); 
}

void VideoTexture::resetTime() {
	cap.set(CV_CAP_PROP_POS_FRAMES, 0);
}

/**
* Keyboard Texture
*/
KeyboardTexture::KeyboardTexture() {
	mat = cv::Mat::zeros(3, 256, CV_8UC3);
	id = DuEngine::GetInstance()->matToTexture2D(mat, GL_RGB, GL_NEAREST, GL_NEAREST, GL_CLAMP);
}

// 0 is current state
// 1 is toggle
// 2 is keypress
// flipped
void KeyboardTexture::onKeyDown(unsigned char key) {
	mat.at<Vec3b>(2, key) = Vec3b(255, 255, 255);
	mat.at<Vec3b>(0, key) = Vec3b(255, 255, 255);
#if DEBUG_KEYBOARD
	cout << "key down " << key << endl;
#endif
}

void KeyboardTexture::onKeyUp(unsigned char key) {
	mat.at<Vec3b>(1, key) = Vec3b(255, 255, 255) - mat.at<Vec3b>(1, key);
	mat.at<Vec3b>(2, key) = Vec3b(0, 0, 0);
	mat.at<Vec3b>(0, key) = Vec3b(0, 0, 0);
#if DEBUG_KEYBOARD
	cout << "key up " << key << endl;
#endif
}

void KeyboardTexture::onKeyPress(unsigned char key, bool up) {
	if (up) {
		onKeyUp(key);
	} else {
		onKeyDown(key);
	}
	update();
}

void KeyboardTexture::update() {
	glActiveTexture(GL_TEXTURE0 + id);
	glBindTexture(GL_TEXTURE_2D, id);
	glTexSubImage2D(
		GL_TEXTURE_2D,
		0,                   // GLint level,
		0, 0,                // GLint xoffset, GLint yoffset,
		mat.cols, mat.rows,  // GLsizei width, GLsizei height,
		GL_BGR,              // GLenum format,
		GL_UNSIGNED_BYTE,    // GLenum type,
		mat.ptr()            // const GLvoid * pixels
		);
}

/**
* Spherical Harmonics Texture
*/
SHTexture::SHTexture(int numBands, int numCoefs) {
	m_numBands = numBands;
	mat = Mat::zeros(m_numBands, m_numBands, CV_32FC3);
	id = DuEngine::GetInstance()->matToTexture2D(mat, GL_BGR, GL_NEAREST, GL_NEAREST, GL_CLAMP, GL_FLOAT);
	GLenum err = glGetError();
	if (err != GL_NO_ERROR) 
		error("SH Texture Error:" + to_string(err));
}

void SHTexture::update(float coef[NUM_COEF]) {
	for (int i = 0; i < mat.rows; ++i) {
		for (int j = 0; j < mat.cols; ++j) {
			mat.at<Vec3f>(mat.rows - 1 - i, j) =
				Vec3f(coef[(i * m_numBands + j) * 3 + 0],
					coef[(i * m_numBands + j) * 3 + 1],
					coef[(i * m_numBands + j) * 3 + 2]);
			//mat.at<Vec3f>(mat.rows - 1 - i, j) = Vec3f(1, 1, 1);
		}
	}

	glActiveTexture(GL_TEXTURE0 + id);
	glBindTexture(GL_TEXTURE_2D, id);
	glTexSubImage2D(
		GL_TEXTURE_2D,
		0,                   // GLint level,
		0, 0,                // GLint xoffset, GLint yoffset,
		mat.cols, mat.rows,  // GLsizei width, GLsizei height,
		GL_BGR,              // GLenum format,
		GL_FLOAT,    // GLenum type,
		mat.ptr()            // const GLvoid * pixels
		);
}


