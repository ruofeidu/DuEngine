#include "stdafx.h"
#include "TextureKeyboard.h"
#include "TextureLightField.h"
#include "DuUtils.h"

TextureLightField::TextureLightField(string fileName, int rows, int cols, TextureFilter filter, TextureWarp warp) {
	init(fileName, false, filter, warp);
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
