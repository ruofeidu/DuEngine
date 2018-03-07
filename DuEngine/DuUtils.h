#pragma once
#include "stdafx.h"

// debug utilities
void debug(string message);
void debug(int message);
void debug(unsigned int message);
void debug(float message);

void warning(string message);
void info(string message);
void logerror(string message);

void dump(char* pszFormat, ...);
void onError();

// file systems
bool dirExists(const string& dirName_in);
string getTimeForFileName();

// string utilities
string repeatstring(string s, int cnt);

string toLower(const string &value);
bool toBool(const string &str);
int toInt(const string &str);
unsigned int toUInt(const string &str);
float toFloat(const string &str);

template<typename ... Args>
string string_format(const std::string& format, Args ... args);

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
