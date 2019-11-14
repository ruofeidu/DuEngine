// DuEngine: Real-time Rendering Engine and Shader Testbed
// Ruofei Du | http://www.duruofei.com
//
// Creative Commons Attribution-ShareAlike 3.0 License with 996 ICU clause:
//
// The above license is only granted to entities that act in concordance with
// local labor laws. In addition, the following requirements must be observed:
// The licensee must not, explicitly or implicitly, request or schedule their
// employees to work more than 45 hours in any single week. The licensee must
// not, explicitly or implicitly, request or schedule their employees to be at
// work consecutively for 10 hours. For more information about this protest, see
// http://996.icu

#include "Window.h"
#include "DuUtils.h"
#include "stdafx.h"

Window* Window::GetInstance() { return s_Instance; }

void Window::init(int argc, char* argv[], int _width, int _height,
                  string _windowTitle) {
  clock_t initTime = clock();
  glutInit(&argc, argv);
  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
  glutCreateWindow(_windowTitle.c_str());
  width = _width;
  height = _height;
  GLenum err = glewInit();
  if (GLEW_OK != err) {
    std::cerr << "Error: " << glewGetString(err) << std::endl;
  }
  info("Window Creation costs: " +
       to_string(float(clock() - initTime) / CLOCKS_PER_SEC) + " s");
}
