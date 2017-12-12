#pragma once
#include "stdafx.h"

class Window
{
public:
	static Window *GetInstance();
	void init(int argc, char* argv[], int width, int height, string _windowTitle);
	void reshape(int _width, int _height);
	int width, height;

private:
	static Window *s_Instance;
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