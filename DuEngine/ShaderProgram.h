#pragma once
#include "stdafx.h"
#include "DuUtils.h"

class ShaderProgram
{
private:
	GLuint m_vertexShader = 0, m_fragmentShader = 0, m_shaderProgram = 0;

public:
	ShaderProgram(string vertexFileName, string fragmentFileName, string uniformFileName, string mainFileName) {
		m_vertexShader = InitShader(GL_VERTEX_SHADER, vertexFileName);
		m_fragmentShader = InitShader(GL_FRAGMENT_SHADER, fragmentFileName, uniformFileName, mainFileName);
		m_shaderProgram = InitProgram(m_vertexShader, m_fragmentShader);
	}

	GLint getUniformLocation(string uniformName) {
		return glGetUniformLocation(m_shaderProgram, uniformName.c_str());
	}

	GLuint getID() {
		return m_shaderProgram;
	}

	void use() {
		glUseProgram(m_shaderProgram);
	}

private:
	static GLuint InitShader(GLenum type, string filename, string uniformFileName = "", string mainFileName = "") {
		GLuint shader = glCreateShader(type);
		GLint compiled;
		string str = ReadTextFromFile(filename);
		if (uniformFileName.size() > 0) {
			string pre = ReadTextFromFile(uniformFileName);
			str = pre + str;
		}
		if (mainFileName.size() > 0) {
			string post = ReadTextFromFile(mainFileName);
			str = str + post;
		}
		GLchar *cstr = new GLchar[str.size() + 1];
		const GLchar *cstr2 = cstr; // Weirdness to get a const char
		strcpy(cstr, str.c_str());
		glShaderSource(shader, 1, &cstr2, NULL);
		glCompileShader(shader);
		glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
		if (!compiled) {
			ReportShaderErrors(shader);
			onError();
		}
		return shader;
	}

	static GLuint InitProgram(GLuint vertexshader, GLuint fragmentshader) {
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

	static string ReadTextFromFile(string filename) {
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
		return res;
	}


	static void ReportShaderErrors(const GLint shader);

	static void ReportProgramErrors(const GLint shader);
};