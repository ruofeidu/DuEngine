#pragma once
#include "stdafx.h"

bool dirExists(const std::string& dirName_in);
void warning(string message);
void info(string message);
void debug(string message);
void logerror(string message);

class Singleton
{
public:
	static Singleton *GetInstance();

private:
	static Singleton *s_Instance;

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

string getTimeForFileName();