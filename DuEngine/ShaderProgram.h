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
