#include "stdafx.h"
#include "TextureKeyboard.h"
#include "TextureLightField.h"
#include "DuUtils.h"

TextureLightField::TextureLightField(string fileName, int rows, int cols, TextureFilter filter, TextureWarp warp) {
	// init(fileName, false, filter, warp);
	ids = new GLuint[rows * cols];
	glGenTextures(rows * cols, ids);
	for (int i = 0; i < rows * cols; i++) {
		glBindTexture(GL_TEXTURE_2D, ids[i]);

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
		glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);//GL_MODULATE);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB,
			m_width, m_height,
			0, GL_BGR, GL_UNSIGNED_BYTE,
			NULL);
		glBindTexture(GL_TEXTURE_2D, 0);
	}

	for (int i = 0; i < rows; ++i) {
		for (int j = 0; j < cols; ++j) {
			auto curName = string_format(fileName, rows, cols);
			cv::Mat mat = cv::imread(curName);
			flip(mat, mat, 0);
			m_mats.push_back(mat);
		}
	}

	m_mat = m_mats[0];
	info("Read light fields: " + to_string(rows * cols));
	this->type = TextureType::LightField;
	this->generateFromMat();
}
