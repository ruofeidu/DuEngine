#include "stdafx.h"
#include "ShaderProgram.h"

ShaderProgram::ShaderProgram(ShaderFileParas &paras) {
	m_vertexShader = InitShader(GL_VERTEX_SHADER, paras);
	m_fragmentShader = InitShader(GL_FRAGMENT_SHADER, paras);
	m_shaderProgram = InitProgram(m_vertexShader, m_fragmentShader);
}

GLint ShaderProgram::getUniformLocation(string uniformName) {
	return glGetUniformLocation(m_shaderProgram, uniformName.c_str());
}

GLuint ShaderProgram::getID() {
	return m_shaderProgram;
}

void ShaderProgram::use() {
	glUseProgram(m_shaderProgram);
}

GLuint ShaderProgram::InitShader(GLenum type, ShaderFileParas &paras) {
	auto& filename = (type == GL_VERTEX_SHADER) ? paras.vert : paras.frag;
	string str = ReadTextFromFile(filename);

	if (type == GL_FRAGMENT_SHADER) {
		if (paras.uniform.size() > 0) {
			auto uniforms = ReadTextFromFile(paras.uniform);
			uniforms += paras.uniformAppendix;
			if (paras.common.size() > 0) {
				auto common = ReadTextFromFile(paras.common);
				uniforms += common;
			}
			str = uniforms + str;
		}
		if (type == GL_FRAGMENT_SHADER && paras.main.size() > 0) {
			string post = ReadTextFromFile(paras.main);
			str = str + post;
		}
	}

	//debug(uniformSampler); 

	GLchar *cstr = new GLchar[str.size() + 1];
	const GLchar *cstr2 = cstr; // Weirdness to get a const char
	strcpy(cstr, str.c_str());
	GLuint shader = glCreateShader(type);
	glShaderSource(shader, 1, &cstr2, NULL);
	glCompileShader(shader);
	GLint compiled;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
	if (!compiled) {
		ReportShaderErrors(shader);
		onError();
	}
	return shader;
}

GLuint ShaderProgram::InitProgram(GLuint vertexshader, GLuint fragmentshader) {
	GLuint program = glCreateProgram();
	GLint linked;
	glAttachShader(program, vertexshader);
	glAttachShader(program, fragmentshader);
	glLinkProgram(program);
	glGetProgramiv(program, GL_LINK_STATUS, &linked);
	if (!linked) {
		ReportProgramErrors(program);
		onError();
	}
	glUseProgram(program);
	return program;
}

string ShaderProgram::ReadTextFromFile(string filename) {
	using std::cout;
	using std::endl;
	using std::string;
	using std::ifstream;
	string str, res = "";
	ifstream in;
	in.open(filename);
	if (in.is_open()) {
		getline(in, str);
		while (in) {
			res += str + "\n";
			getline(in, str);
		}
	} else {
		warning("Unable to open file " + filename);
		onError();
	}
	in.close();
	return res;
}

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