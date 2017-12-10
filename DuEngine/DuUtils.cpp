#include "stdafx.h"
#include "DuUtils.h"

bool dirExists(const std::string& dirName_in) {
	DWORD ftyp = GetFileAttributesA(dirName_in.c_str());
	if (ftyp == INVALID_FILE_ATTRIBUTES)
		return false;  //something is wrong with your path!

	if (ftyp & FILE_ATTRIBUTE_DIRECTORY)
		return true;   // this is a directory!

	return false;    // this is not a directory!
}

void warning(string message) {
	cout << "! " << message << endl;
}

void info(string message) {
	cout << "~ " << message << endl;
}

void debug(string message) {
	cout << "* " << message << endl;
}

void logerror(string message) {
	cout << "!!! " << message << endl;
}


Singleton* Singleton::GetInstance() {
	return s_Instance;
}

Singleton *Singleton::s_Instance = new Singleton();
Singleton::GC Singleton::gc;
