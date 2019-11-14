/**
 * DuRenderer is an efficent OpenGL/C++ renderer which implements most of the
 * ShaderToy functionality Ruofei Du | Augmentarium Lab | UMIACS Computer
 * Science Department | University of Maryland, College Park me [at] duruofei
 * [dot] com
 */
#include "DuEngine.h"
#include <fstream>
#include <iostream>
#include <string>
#include <thread>
#include "DuUtils.h"
#include "ShaderToy.h"
#include "stdafx.h"
using namespace std;

Window* Window::s_Instance = new Window();
Window::GC Window::gc;
DuEngine* DuEngine::s_Instance = new DuEngine();
DuEngine::GC DuEngine::gc;

DuEngine::DuEngine() {
  m_camera = new Camera();
  m_window = Window::GetInstance();
  m_textureManager = new TexturesManager();
}

DuEngine* DuEngine::GetInstance() { return s_Instance; }

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

void g_timer(int id) { glutPostRedisplay(); }

// https://stackoverflow.com/questions/12619107/opengl-glut-m_window-very-slow-why
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

void g_mouseMove(int x, int y) { DuEngine::GetInstance()->mouseMove(x, y); }
void g_reshape(int width, int height) {
  DuEngine::GetInstance()->reshape(width, height);
}

void DuEngine::start(int argc, char* argv[]) {
  // setup configuration files and the scene name
  m_config = argc > 1 ? new DuConfig(std::string(argv[1])) : new DuConfig();
  m_path = new PathManager(std::string(argv[0]), m_config);

  // setup the default m_window width and height
  m_defaultWidth = m_config->GetIntWithDefault(
      "window_width", m_config->GetIntWithDefault("width", m_defaultWidth));
  m_defaultHeight = m_config->GetIntWithDefault(
      "window_height", m_config->GetIntWithDefault("height", m_defaultHeight));
  string _windowTitle = m_config->GetStringWithDefault(
      "window_title", m_config->GetStringWithDefault(
                          "title", "DuRenderer | " + m_config->GetName()));
  m_window->init(argc, argv, m_defaultWidth, m_defaultHeight, _windowTitle);

  // setup recording
  m_recording = m_config->GetBoolWithDefault(
      "record", m_config->GetBoolWithDefault("recording", m_recording));
  m_recordPath =
      m_config->GetStringWithDefault("record_path", m_config->GetName());
  m_recordStart = m_config->GetIntWithDefault("record_start", m_recordStart);
  m_recordEnd = m_config->GetIntWithDefault("record_end", m_recordEnd);
  m_recordVideo = m_config->GetBoolWithDefault("record_video", m_recordVideo);

  // initialize the scene, shaders, and presets
  initScene();

  // bind the glut functions
  glutReshapeWindow(m_window->width, m_window->height);
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
    }
  }
  // TODO: fix modifiers
  // auto states = glutGetModifiers();
  m_textureManager->updateKeyboard(key, up);
}

const unordered_map<int, int> DuEngine::KeyCodes{
    {GLUT_KEY_PAGE_UP, 33}, {GLUT_KEY_PAGE_DOWN, 34}, {GLUT_KEY_END, 35},
    {GLUT_KEY_HOME, 36},    {GLUT_KEY_LEFT, 37},      {GLUT_KEY_UP, 38},
    {GLUT_KEY_RIGHT, 39},   {GLUT_KEY_DOWN, 40},      {GLUT_KEY_INSERT, 45},
};

const unordered_map<int, int> DuEngine::ModifierCodes{
    {GLUT_ACTIVE_SHIFT, 16}, {GLUT_ACTIVE_CTRL, 17}, {GLUT_ACTIVE_ALT, 18},
};

/*
F1      =   Reset the time and textures;
F2      =   Take screenshot;
F5      =   Recompile the shader;
F6      =   Pause / Play all videos;
F9      =   (Debug) Print iFrame;
F10     =   (Debug) Print iMouse;
F11     =   Toggle the fullscreen mode;
*/
void DuEngine::special(int key, int x, int y, bool up) {
  if (up) {
    switch (key) {
      case GLUT_KEY_F1:
        m_shadertoy->reset();
        m_textureManager->reset();
        break;
      case GLUT_KEY_F2:
        m_takeSingleScreenShot = true;
        break;
      case GLUT_KEY_F5:
        m_shadertoy->recompile(this);
        break;
      case GLUT_KEY_F6:
        m_textureManager->togglePause();
      case GLUT_KEY_F9:
        debug(getFrameNumber());
        break;
      case GLUT_KEY_F10:
        debug(ShaderToyUniforms::GetMouseString());
        break;
      case GLUT_KEY_F11:
        this->toggleFullScreen();
        break;
    }
  }

  // Deal with special key press events
  // Reference:
  // https://www.cambiaresearch.com/articles/15/javascript-char-codes-key-codes
  auto res = KeyCodes.find(key);
  if (res != KeyCodes.end()) {
    m_textureManager->updateKeyboard(res->second, up);
  }
  m_textureManager->updateKeyboard(key, up);
}

void DuEngine::mousePress(int button, int state, int x, int y) {
  if (button != GLUT_LEFT_BUTTON) return;
  if (state == GLUT_DOWN) {
    ShaderToyUniforms::OnMouseDown((float)x, (float)y);
  }
  if (state == GLUT_UP) {
    ShaderToyUniforms::OnMouseUp((float)x, (float)y);
  }
}

void DuEngine::mouseMove(int x, int y) {
  ShaderToyUniforms::OnMouseMove((float)x, (float)y);
}

void DuEngine::reshape(int width, int height) {
  m_window->reshape(width, height);
  m_shadertoy->reshape(width, height);
}

void DuEngine::toggleFullScreen() {
  m_fullscreen = !m_fullscreen;
  if (m_fullscreen) {
    m_defaultWidth = m_window->width;
    m_defaultHeight = m_window->height;
    glutFullScreen();
  } else {
    glutReshapeWindow(m_defaultWidth, m_defaultHeight);
    glutPositionWindow(0, 0);
  }
}

void DuEngine::printHelp() {
  info(
      "Help:\n\tF1:\tReset everything.\n\tF2:\tTake Screenshot.\n\tF5:\tReset "
      "Time\n\tF6:\tPause\n\tF11:\tFullscreen.\n");
}

void DuEngine::takeScreenshot(string folderName) {
  m_path->createPathIfNotExisted(folderName);

  // read from the screen buffer
  cv::Mat img(m_window->height, m_window->width, CV_8UC3);
  glBindFramebuffer(GL_FRAMEBUFFER, 0);
  glPixelStorei(GL_PACK_ALIGNMENT, (img.step & 3) ? 1 : 4);
  glPixelStorei(GL_PACK_ROW_LENGTH, (GLint)img.step / (GLint)img.elemSize());
  glReadPixels(0, 0, img.cols, img.rows, GL_BGR_EXT, GL_UNSIGNED_BYTE,
               img.data);
  flip(img, img, 0);

  // record to video if configured
  if (m_recordVideo) {
    if (m_video == nullptr) {
      m_video = new cv::VideoWriter();
      m_video->open(folderName + "/" + getTimeForFileName() + ".avi",
                    cv::VideoWriter::fourcc('M', 'J', 'P', 'G'),
                    DEFAULT_RENDER_FPS,
                    cv::Size(m_window->width, m_window->height));
    }
    m_video->write(img);
    if (getFrameNumber() == m_recordEnd) {
      m_video->release();
    }
    return;
  }

  cv::imwrite(folderName + "/" + m_config->GetName() + "_" +
                  to_string(getFrameNumber()) + ".png",
              img);

  // create a preview image of the shader
  cv::imwrite(m_config->GetName() + ".jpg", img);
}
