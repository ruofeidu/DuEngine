#include "stdafx.h"
#include "Texture2D.h"

Texture2D::Texture2D(string filename, bool vflip, TextureFilter filter, TextureWarp warp) {
	init(filename, vflip, filter, warp);
	m_mat = imread(filename, cv::IMREAD_UNCHANGED);
	this->generateFromMat();
}
