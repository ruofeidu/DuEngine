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
#include "DuUtils.h"
#include "ShaderFileParas.h"
#include "stdafx.h"

class ShaderProgram {
 private:
  GLuint m_vertexShader = 0, m_fragmentShader = 0, m_shaderProgram = 0;

 public:
  ShaderProgram(ShaderFileParas &paras);

  GLint getUniformLocation(string uniformName);

  GLuint getID();

  void use();

 private:
  static GLuint InitShader(GLenum type, ShaderFileParas &paras);

  static GLuint InitProgram(GLuint vertexshader, GLuint fragmentshader);

  static string ReadTextFromFile(string filename);

  static void ReportShaderErrors(const GLint shader);

  static void ReportProgramErrors(const GLint shader);
};
