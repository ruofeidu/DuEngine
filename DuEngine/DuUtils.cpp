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

#include "stdafx.h"
#include "DuUtils.h"

bool dirExists(const string &dirName_in) {
  DWORD ftyp = GetFileAttributesA(dirName_in.c_str());
  if (ftyp == INVALID_FILE_ATTRIBUTES)
    return false;  // something is wrong with your path!

  if (ftyp & FILE_ATTRIBUTE_DIRECTORY) return true;  // this is a directory!

  return false;  // this is not a directory!
}

void debug(string message) { cout << "* " << message << endl; }

void debug(int message) { cout << "* " << message << endl; }

void debug(unsigned int message) { cout << "* " << message << endl; }

void debug(float message) { cout << "* " << message << endl; }

void warning(string message) { cout << "! " << message << endl; }

void info(string message) { cout << "~ " << message << endl; }

void dump(char *pszFormat, ...) {
  static char s_acBuf[2048];  // this here is a caveat!
  va_list args;
  va_start(args, pszFormat);
  vsprintf(s_acBuf, pszFormat, args);
  OutputDebugString(s_acBuf);
  va_end(args);
}

void logerror(string message) {
  cout << "!!! " << message << endl;
  system("pause");
  exit(EXIT_FAILURE);
}

string getTimeForFileName() {
  auto t = std::time(nullptr);
  auto tm = *std::localtime(&t);
  std::ostringstream oss;
  oss << std::put_time(&tm, "%d-%m-%Y_%H-%M-%S");
  auto str = oss.str();
  return str;
}

string repeatstring(string s, int cnt) {
  string res = "";
  for (int i = 0; i < cnt; ++i) res += s;
  return res;
}

string toLower(const string &value) {
  string result;
  result.resize(value.size());
  std::transform(value.begin(), value.end(), result.begin(), ::tolower);
  return result;
}

bool toBool(const string &str) {
  string value = toLower(str);
  if (value == "false")
    return false;
  else if (value == "true")
    return true;
  warning("Could not parse boolean value " + str);
  return false;
}

int toInt(const string &str) {
  char *end_ptr = nullptr;
  int result = (int)strtol(str.c_str(), &end_ptr, 10);
  if (*end_ptr != '\0') warning("Could not parse integer value \"%s\"" + str);
  return result;
}

unsigned int toUInt(const string &str) {
  char *end_ptr = nullptr;
  unsigned int result = (int)strtoul(str.c_str(), &end_ptr, 10);
  if (*end_ptr != '\0') warning("Could not parse integer value \"%s\"" + str);
  return result;
}

float toFloat(const string &str) {
  char *end_ptr = nullptr;
  float result = (float)strtof(str.c_str(), &end_ptr);
  if (*end_ptr != '\0')
    warning("Could not parse floating point value \"%s\"" + str);
  ;
  return result;
}

void onError() {
  system("pause");
  exit(EXIT_FAILURE);
}

Singleton *Singleton::GetInstance() { return s_Instance; }

Singleton *Singleton::s_Instance = new Singleton();
Singleton::GC Singleton::gc;
