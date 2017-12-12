#include "stdafx.h"
#include "Window.h"
#include "DuUtils.h"

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
