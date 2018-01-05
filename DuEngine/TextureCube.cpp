#include "stdafx.h"
#include "TextureCube.h"

TextureCube::TextureCube(string filename, bool vflip, TextureFilter filter, TextureWarp warp) {
	init(filename, vflip, filter, warp);
	m_mat = imread(filename, cv::IMREAD_UNCHANGED);

	m_texType = GL_TEXTURE_CUBE_MAP;

	this->genTexture2D();
	this->updateDataTypeFormat();

	int n = m_mat.rows, m = m_mat.cols; 
	for (int i = 0; i < 6; ++i) {
		m_cubes[i] = m_mat(cv::Rect(0, i*n, m, n));
		// OpenCV has reversed Y coordinates
		if (m_vFlip) flip(m_cubes[i], m_cubes[i], 0);
		m_texType = m_cubeTypes[i]; 
		this->texImage(m_cubes[i]); 
	}

	m_texType = GL_TEXTURE_CUBE_MAP;
	type = TextureType::CubeMap;
}

