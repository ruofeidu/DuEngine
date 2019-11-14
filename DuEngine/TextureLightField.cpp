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

#include "TextureLightField.h"
#include "DuUtils.h"
#include "TextureKeyboard.h"
#include "stdafx.h"

TextureLightField::TextureLightField(string fileName, int rows, int cols,
                                     TextureFilter filter, TextureWarp warp) {
  // init(fileName, false, filter, warp);
  ids = new GLuint[rows * cols];
  glGenTextures(rows * cols, ids);
  for (int i = 0; i < rows * cols; ++i) {
    glBindTexture(GL_TEXTURE_2D, ids[i]);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);  // GL_MODULATE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, m_width, m_height, 0, GL_BGR,
                 GL_UNSIGNED_BYTE, NULL);
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
