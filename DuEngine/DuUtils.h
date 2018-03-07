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
string string_format(const std::string& format, Args ... args) {
	size_t size = snprintf(nullptr, 0, format.c_str(), args ...) + 1; // Extra space for '\0'
	unique_ptr<char[]> buf(new char[size]);
	snprintf(buf.get(), size, format.c_str(), args ...);
	return string(buf.get(), buf.get() + size - 1); // We don't want the '\0' inside
}

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
