#include "PathManager.h"
#include "DuUtils.h"
#include "stdafx.h"

PathManager::PathManager(string executionPath, DuConfig* config) {
  // setup shaders path and presets path
  m_shadersPath = executionPath;
  m_config = config;

  // automatically search the default shader path from the upper-level folders
  for (int i = 3; i >= 0; --i) {
    if (i == 0) {
      m_shadersPath = "";
    } else {
      auto keywords = repeatstring("../", i) + "DuEngine/";
      if (m_shadersPath.find(keywords) != string::npos) {
        m_shadersPath = keywords;
        break;
      }
    }
  }
  m_shadersPath = config->GetStringWithDefault("shaders_path", m_shadersPath);
#if VERBOSE_OUTPUT
  if (m_shadersPath.size() > 0) {
    info("Relative Path: " + m_shadersPath);
  }
#endif
  m_presetsPath =
      config->GetStringWithDefault("presets_path", m_shadersPath + "presets/");
  m_resourcesPath =
      config->GetStringWithDefault("resources_path", m_presetsPath);
}

string PathManager::getShader(string str) { return m_shadersPath + str; }

string PathManager::getPreset(string str) { return m_presetsPath + str; }

string PathManager::getResource(string str) {
  auto fileName = m_config->GetStringWithDefault(str, "");
  debug(fileName);
  return smartPath(m_resourcesPath, fileName);
}

string PathManager::getVertexShader() {
  return m_config->GetStringWithDefault("shader_vert",
                                        m_shadersPath + "shadertoy.vert.glsl");
}

string PathManager::getUniformShader() {
  return m_config->GetStringWithDefault(
      "shader_uniform", m_shadersPath + "shadertoy.uniforms.glsl");
}

string PathManager::getMainShader() {
  return m_config->GetStringWithDefault("shader_main",
                                        m_shadersPath + "shadertoy.main.glsl");
}

string PathManager::getFragmentShader(string bufferSuffix) {
  auto res = m_config->GetStringWithDefault(
      "shader_frag", m_shadersPath + "shadertoy.default.glsl");
  if (res.find("$Name") != string::npos) {
    res.replace(res.find("$Name"), 5, m_config->GetName());
  }
  if (res.find(".glsl") != string::npos) {
    // add framebuffer suffix for multipass rendering
    res.replace(res.find(".glsl"), 5, bufferSuffix + ".glsl");
  } else {
    res += bufferSuffix + ".glsl";
  }
  return res;
}

string PathManager::getCommonShader() {
  auto res = m_config->GetStringWithDefault(
      "shader_common", m_config->GetName() + "Common.glsl");
  ifstream in;
  in.open(res);
  if (!in.is_open()) res = "";
  in.close();
  return res;
}

void PathManager::createPathIfNotExisted(const string& str) {
  if (isPathCreated(str)) return;
  CreateDirectory(str.c_str(), NULL);
  m_isPathCreated.insert(str);
}

bool PathManager::isPathCreated(const string& str) {
  return m_isPathCreated.find(str) != m_isPathCreated.end();
}

string PathManager::smartPath(string path, string fileName) {
  if (fileName.size() > 2 && fileName[1] == ':') {
    return fileName;
  } else {
    return path + fileName;
  }
}
