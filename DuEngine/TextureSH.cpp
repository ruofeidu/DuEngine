/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
* 12/6/2017
*/
#include "stdafx.h"
#include "TextureSH.h"

#if COMPILE_WITH_SH
/**
* Spherical Harmonics Texture
*/
TextureSH::TextureSH(int numBands, int numCoefs) {
	m_numBands = numBands;
	m_mat = Mat::zeros(m_numBands, m_numBands, CV_32FC3);
	m_filter = TextureFilter::NEAREST;
	m_warp = TextureWarp::CLAMP;
	generateFromMat();
}

void TextureSH::update(float coef[NUM_COEF]) {
	for (int i = 0; i < m_mat.rows; ++i) {
		for (int j = 0; j < m_mat.cols; ++j) {
			m_mat.at<Vec3f>(m_mat.rows - 1 - i, j) =
				Vec3f(coef[(i * m_numBands + j) * 3 + 0],
					coef[(i * m_numBands + j) * 3 + 1],
					coef[(i * m_numBands + j) * 3 + 2]);
			//mat.at<Vec3f>(mat.rows - 1 - i, j) = Vec3f(1, 1, 1);
		}
	}
	this->updateFromMat();
}
#endif
