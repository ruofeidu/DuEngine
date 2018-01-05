#pragma once
#include "stdafx.h"
#include "DuUtils.h"

class ShaderProgram
{
private:
	GLuint m_vertexShader = 0, m_fragmentShader = 0, m_shaderProgram = 0;

public:
	ShaderProgram(string vertexFileName, string fragmentFileName, string uniformFileName, string mainFileName, string uniformAppendix = "");

	GLint getUniformLocation(string uniformName);

	GLuint getID();

	void use();

private:
	static GLuint InitShader(GLenum type, string filename, string uniformFileName = "", string mainFileName = "", string uniformAppendix = "");

	static GLuint InitProgram(GLuint vertexshader, GLuint fragmentshader);

	static string ReadTextFromFile(string filename);

	static void ReportShaderErrors(const GLint shader);

	static void ReportProgramErrors(const GLint shader);
};