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
