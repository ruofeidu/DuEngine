#pragma once
#include "stdafx.h"

// debug utilities
void warning(string message);
void info(string message);
void debug(string message);
void logerror(string message);
void dump(char* pszFormat, ...);
void onError();

// file systems
bool dirExists(const std::string& dirName_in);
string getTimeForFileName();

// string utilities
string repeatstring(string s, int cnt);

// design pattern utilities
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
