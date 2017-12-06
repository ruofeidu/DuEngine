#pragma once
// stdafx.h is a common header used by every other cpp file to accelerate the compilation speed

#define _CRT_SECURE_NO_WARNINGS
#pragma warning(disable:4996)

#ifdef _DEBUG 
#pragma comment(lib, "opencv_world330d.lib")
#else 
#pragma comment(lib, "opencv_world330.lib")
#endif
#pragma comment(lib, "glew32.lib")

#include <iostream>
#include <fstream>
#include <chrono>
#include <iomanip>
#include <string>
#include <ctime>
#include <vector>
#include <thread>
#include <map>
#include <unordered_map>
#include <unordered_set>
#include <algorithm>

#include <cstdlib>
#include <cstdarg>
#include <cstdio>
#include <cstring>
#include <ctime>

#include <opencv2/opencv.hpp>
#include <opencv2/videoio.hpp>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <GL/glew.h>
#include <GL/glut.h>

#define COMPILE_WITH_SH 1
#define COMPILE_WITH_TIMER 1
#define DEBUG_KEYBOARD 0

const float PI = 3.14159265359f;
#if COMPILE_WITH_SH
#include "SHUtils.h"
#endif
#if COMPILE_WITH_TIMER
#include "DebugTimer.h"
#endif

#define GLUT_KEY_ESC '\x1b'
