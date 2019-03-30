#pragma once
// stdafx.h is a common header used by every other cpp file to accelerate the
// compilation speed

#define _CRT_SECURE_NO_WARNINGS
#pragma warning(disable : 4996)

#ifdef _DEBUG
#pragma comment(lib, "opencv_world331d.lib")
#else
#pragma comment(lib, "opencv_world331.lib")
#endif
#pragma comment(lib, "glew32.lib")

#include <algorithm>
#include <chrono>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <map>
#include <string>
#include <thread>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include <cstdarg>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>

#include <GL/glew.h>
#include <GL/glut.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/videoio.hpp>

#if _WIN64 | _WIN32
#include "dirent.h"
#include "windows.h"
#endif

#define GLUT_KEY_ESC '\x1b'
const float PI = 3.14159265359f;

#define DEFAULT_VIDEO_FPS 25
#define DEFAULT_RENDER_FPS 60
#define SKIP_FIRST_FRAMES 3
#define COMPILE_WITH_SH 1
#define COMPILE_WITH_TIMER 1
#define COMPILE_CHECK_GL_ERROR 1
#define COMPILE_SCREENSHOT 1
#define DEBUG_KEYBOARD 0
#define DEBUG_MULTIPASS 0
#define DEBUG_VIDEO 0
#define DEBUG_PATH 0
#define DEBUG_TEXTURE_DEPRECATED_FILTERING 0
#define VERBOSE_OUTPUT 0

#if COMPILE_WITH_SH
#include "SHUtils.h"
#endif
#if COMPILE_WITH_TIMER
#include "DebugTimer.h"
#endif
