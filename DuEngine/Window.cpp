/**
 * DuRenderer is a basic OpenGL-based renderer which implements most of the
 * ShaderToy functionality Ruofei Du | Augmentarium Lab | UMIACS Computer
 * Science Department | University of Maryland, College Park me [at] duruofei
 * [dot] com 12/6/2017
 */
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
