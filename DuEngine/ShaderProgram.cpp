#include "stdafx.h"
#include "ShaderProgram.h"

void ShaderProgram::ReportShaderErrors(const GLint shader) {
	GLint length;
	glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &length);
	GLchar* log = new GLchar[length + 1];
	glGetShaderInfoLog(shader, length, &length, log);
	string s(log);
	logerror("Shader compile error, see log below\n" + s + "\n");
	delete[] log;
	onError();
}


void ShaderProgram::ReportProgramErrors(const GLint program) {
	GLint length;
	glGetProgramiv(program, GL_INFO_LOG_LENGTH, &length);
	GLchar* log = new GLchar[length + 1];
	glGetProgramInfoLog(program, length, &length, log);
	string s(log);
	logerror("Program linking error, see log below\n" + s + "\n");
	delete[] log;
	onError();
}