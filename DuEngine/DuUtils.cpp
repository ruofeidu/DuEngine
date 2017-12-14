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


Singleton* Singleton::GetInstance() {
	return s_Instance;
}

Singleton *Singleton::s_Instance = new Singleton();
Singleton::GC Singleton::gc;
