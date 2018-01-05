#include "stdafx.h"
#include "TextureCubeMap.h"
#include "DuUtils.h"

TextureCubeMap::TextureCubeMap(string filename, bool vflip, TextureFilter filter, TextureWarp warp) {
	init(filename, vflip, filter, warp);
	type = TextureType::CubeMap;
	m_glType = GL_TEXTURE_CUBE_MAP;
	m_mat = imread(filename, cv::IMREAD_UNCHANGED);
	m_warp = TextureWarp::CLAMP;

	this->genTexture2D();
	this->updateDataTypeFormat();

	int n = m_mat.rows, m = m_mat.cols; 
	for (int i = 0; i < 6; ++i) {
		m_cubes[i] = m_mat(cv::Rect(0, i*m, m, m)).clone();
		// OpenCV has reversed Y coordinates
		if (m_vFlip) flip(m_cubes[i], m_cubes[i], 0);
		m_glType = m_cubeTypes[i]; 
		this->texImage(m_cubes[i]);
		//this->generateMipmaps(); 
#if COMPILE_CHECK_GL_ERROR
		// Check texturing errors.
		GLenum err = glGetError();
		if (err != GL_NO_ERROR)
			warning("Texturing error: " + to_string(err));
#endif
	}
	debug(this->getTextureID()); 

	m_glType = GL_TEXTURE_CUBE_MAP;
	this->setFiltering();
#if COMPILE_CHECK_GL_ERROR
	// Check texturing errors.
	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
		warning("Texturing error: " + to_string(err));
#endif
}
