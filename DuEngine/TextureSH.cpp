/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
* 12/6/2017
*/
#include "stdafx.h"
#include "TextureSH.h"
#include "DuUtils.h"

#if COMPILE_WITH_SH
/**
 * Spherical Harmonics Texture
 */
TextureSH::TextureSH(string fileName, int fps, int startFrame, int endFrame, int numBands) {
	m_numBands = numBands;
	m_numCoefficients = m_numBands * m_numBands;
	using shtype = float; 
	shtype *shCoef = new shtype[m_numCoefficients * 3];
	init(fileName, false, TextureFilter::NEAREST, TextureWarp::CLAMP);

	for (int i = startFrame; i < endFrame; ++i) {
		string ithName = fileName;
		if (fileName.find("%d") != string::npos) {
			ithName.replace(ithName.find("%d"), 2, to_string(i));
		}
		cv::Mat mat = Mat::zeros(2, m_numCoefficients, CV_32FC3);
		try {
			auto pFile = fopen(ithName.c_str(), "rb");
			fread(shCoef, sizeof(shtype), m_numCoefficients * 3, pFile);
			fclose(pFile);
			for (int j = 0; j < m_numCoefficients; ++j) {
				mat.at<Vec3f>(0, j) = Vec3f(shCoef[j * 3 + 0], shCoef[j * 3 + 1], shCoef[j * 3 + 2]);
				mat.at<Vec3f>(1, j) = Vec3f(shCoef[j * 3 + 0], shCoef[j * 3 + 1], shCoef[j * 3 + 2]);
			}
		}
		catch (const std::exception& e) {
			logerror("TextureSH cannot read " + ithName + e.what());
		}
		m_videoseq.push_back(mat);
	}

	m_mat = m_videoseq[0];
	m_fps = fps;
	this->type = TextureType::SH;
	this->generateFromMat();
	this->initDistribution();
	info("Read and generated SH Sequences: " + to_string(m_videoseq.size()));
	for (int i = 0; i < 9; ++i) {
		cout << shCoef[i] << endl;
	}
	delete[] shCoef;
}
#endif
