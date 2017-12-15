#include "stdafx.h"
#include "TextureFont.h"
#include "DuEngine.h"

TextureFont::TextureFont(TextureFilter filter, TextureWarp warp) {
	m_filename = DuEngine::GetInstance()->getPresetsPath() + Texture::FontTextures.find("font")->second;
	init(m_filename, true, filter, warp);
	m_mat = imread(m_filename, cv::IMREAD_UNCHANGED);
	this->generateFromMat();
	this->type = TextureType::Font;
}
