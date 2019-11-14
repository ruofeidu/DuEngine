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

#pragma once
#include "Texture.h"

class TextureMat : public Texture {
 public:
  TextureMat(){};
  TextureMat(string filename, bool vflip = true,
             TextureFilter filter = TextureFilter::LINEAR,
             TextureWarp warp = TextureWarp::REPEAT);
  void init(string filename, bool vflip = true,
            TextureFilter filter = TextureFilter::LINEAR,
            TextureWarp warp = TextureWarp::REPEAT);
  vec3 getResolution();

 protected:
  Mat m_mat = Mat();
  string m_filename = "";
  bool m_vFlip = true;
  // Input image format (i.e. GL_RGB, GL_RGBA, GL_BGR etc.)
  GLuint m_format = GL_BGR;
  // Image data type [GL_UNSIGNED_BYTE]
  GLuint m_dataType = GL_UNSIGNED_BYTE;
  // Internal color format to convert to, [GL_RGB]
  GLuint m_openGLFormat = GL_RGB;

 protected:
  // Generate, active, bind, and set filtering,
  // Update date type format of the mat
  // TexImage2D from the mat
  // Generate mipmaps
  void generateFromMat();

  // Update the texture from Mat
  void updateFromMat();

  // Update the datatype format
  void updateDataTypeFormat();

  // Create the texture
  void texImage(cv::Mat& mat, uchar* pointer = nullptr);

 private:
  // https://www.khronos.org/registry/OpenGL-Refpages/es2.0/xhtml/glTexParameter.xml
  // minFilters: GL_NEAREST, GL_LINEAR, GL_NEAREST_MIPMAP_NEAREST,
  // GL_LINEAR_MIPMAP_NEAREST, GL_NEAREST_MIPMAP_LINEAR, GL_LINEAR_MIPMAP_LINEAR
  // magFilters: GL_NEAREST, GL_LINEAR
  // GL_TEXTURE_WRAP_S: GL_CLAMP_TO_EDGE, GL_MIRRORED_REPEAT, GL_REPEAT
  void generateFromMat(cv::Mat& mat);

  void updateDatatypeFromMat(cv::Mat& mat);
  void updateFormatFromMat(cv::Mat& mat);
  void updateOpenGLInternalFormat(cv::Mat& mat);
};
