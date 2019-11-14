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

#pragma once
#include "stdafx.h"

// Debug utilities.
void debug(string message);
void debug(int message);
void debug(unsigned int message);
void debug(float message);

void warning(string message);
void info(string message);
void logerror(string message);

void dump(char *pszFormat, ...);
void onError();

// OS
bool dirExists(const string &dirName_in);
string getTimeForFileName();

// String utilities.
string repeatstring(string s, int cnt);

string toLower(const string &value);
bool toBool(const string &str);
int toInt(const string &str);
unsigned int toUInt(const string &str);
float toFloat(const string &str);

template <typename... Args>
string string_format(const std::string &format, Args... args) {
  size_t size = snprintf(nullptr, 0, format.c_str(), args...) +
                1;  // Extra space for '\0'
  unique_ptr<char[]> buf(new char[size]);
  snprintf(buf.get(), size, format.c_str(), args...);
  return string(buf.get(),
                buf.get() + size - 1);  // We don't want the '\0' inside
}

// Design pattern utilities.
class Singleton {
 public:
  static Singleton *GetInstance();

 private:
  static Singleton *s_Instance;

  class GC {
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
