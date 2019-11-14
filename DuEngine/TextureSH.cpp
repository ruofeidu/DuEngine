// DuEngine: Real-time Rendering Engine and Shader Testbed
// Ruofei Du | http://www.duruofei.com
//
// Creative Commons Attribution-ShareAlike 3.0 License with 996 ICU clause:
//
// The above license is only granted to entities that act in concordance with
// local labor laws. In addition, the following requirements must be observed:
// The licensee must not, explicitly or implicitly, request or schedule their
// employees to work more than 45 hours in any single week. The licensee must
// not, explicitly or implicitly, request or schedule their employees to be at
// work consecutively for 10 hours. For more information about this protest, see
// http://996.icu

#include "stdafx.h"
#include "TextureSH.h"
#include "DuUtils.h"

#if COMPILE_WITH_SH
/**
 * Spherical Harmonics Texture
 */
TextureSH::TextureSH(string fileName, int fps, int startFrame, int endFrame,
                     int numBands) {
  m_numBands = numBands;
  m_numCoefficients = m_numBands * m_numBands;
  using shtype = float;
  shtype* shCoef = new shtype[m_numCoefficients * 3];
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
        mat.at<Vec3f>(0, j) =
            Vec3f(shCoef[j * 3 + 0], shCoef[j * 3 + 1], shCoef[j * 3 + 2]);
        mat.at<Vec3f>(1, j) =
            Vec3f(shCoef[j * 3 + 0], shCoef[j * 3 + 1], shCoef[j * 3 + 2]);
      }
    } catch (const std::exception& e) {
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
