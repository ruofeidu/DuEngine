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
#include "DuConfig.h"
#include "stdafx.h"

using namespace std;

class PathManager {
 public:
  PathManager(string executionPath, DuConfig* config);

  string getShaderPath() { return m_shadersPath; };
  string getPresetPath() { return m_presetsPath; };
  string getResourcePath() { return m_resourcesPath; };

  string getShader(string str);
  string getPreset(string str);
  string getResource(string str);
  string getVertexShader();
  string getUniformShader();
  string getMainShader();
  // replace the fragment shader name with $Name and buffer prefix / suffix
  string getFragmentShader(string bufferSuffix);
  string getCommonShader();

  void createPathIfNotExisted(const string& str);

 private:
  DuConfig* m_config;
  string m_shadersPath = "";
  string m_presetsPath = "";
  string m_resourcesPath = "";
  unordered_set<string> m_isPathCreated;
  bool isPathCreated(const string& str);

 private:
  string smartPath(string fileName, string path);
};
