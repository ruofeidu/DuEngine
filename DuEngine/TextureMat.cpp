/**
 * DuRenderer is a basic OpenGL-based renderer which implements most of the
 * ShaderToy functionality Ruofei Du | Augmentarium Lab | UMIACS Computer
 * Science Department | University of Maryland, College Park me [at] duruofei
 * [dot] com 12/6/2017
 */
#include "TextureMat.h"
#include "DuUtils.h"
#include "stdafx.h"

TextureMat::TextureMat(string filename, bool vflip, TextureFilter filter,
                       TextureWarp warp) {
  init(filename, vflip, filter, warp);
  m_mat = imread(filename);
  this->generateFromMat();
}

void TextureMat::init(string filename, bool vflip, TextureFilter filter,
                      TextureWarp warp) {
  m_filename = filename;
  m_vFlip = vflip;
  m_filter = filter;
  m_warp = warp;
}

vec3 TextureMat::getResolution() { return vec3(m_mat.cols, m_mat.rows, 1); }

void TextureMat::generateFromMat() { return generateFromMat(m_mat); }

void TextureMat::updateFromMat() {
  glBindTexture(m_glType, id);
  glTexSubImage2D(m_glType,
                  0,                       // GLint level,
                  0, 0,                    // GLint xoffset, GLint yoffset,
                  m_mat.cols, m_mat.rows,  // GLsizei width, GLsizei height,
                  m_format,                // GLenum format,
                  m_dataType,              // GLenum type,
                  m_mat.ptr()              // const GLvoid * pixels
  );
  generateMipmaps();
}

void TextureMat::texImage(cv::Mat& mat, uchar* pointer) {
  if (pointer == nullptr) pointer = mat.ptr();

  glTexImage2D(m_glType,
               0,  // Pyramid level (for mip-mapping) - 0 is the top level
               m_openGLFormat,
               mat.cols,  // Image width
               mat.rows,  // Image height
               0,         // Border width in pixels (can either be 1 or 0)
               m_format, m_dataType,
               pointer  // The actual image data itself
  );
}

void TextureMat::generateFromMat(cv::Mat& mat) {
  this->genTexture2D();
  this->updateDataTypeFormat();

  // OpenCV has reversed Y coordinates
  if (m_vFlip) flip(mat, mat, 0);

  this->texImage(mat);

  generateMipmaps();
}

void TextureMat::updateDataTypeFormat() {
  updateDatatypeFromMat(m_mat);
  updateFormatFromMat(m_mat);
  updateOpenGLInternalFormat(m_mat);
}

void TextureMat::updateDatatypeFromMat(cv::Mat& mat) {
  // r denotes the string for the datatype, e.g., 8UC3
  string r;
  auto type = mat.type();
  uchar depth = type & CV_MAT_DEPTH_MASK;
  uchar chans = 1 + (type >> CV_CN_SHIFT);
  switch (depth) {
    case CV_8U:
      r = "8U";
      m_dataType = GL_UNSIGNED_BYTE;
      break;
    case CV_8S:
      r = "8S";
      m_dataType = GL_BYTE;
      break;
    case CV_16U:
      r = "16U";
      m_dataType = GL_UNSIGNED_SHORT;
      break;
    case CV_16S:
      r = "16S";
      m_dataType = GL_SHORT;
      break;
    case CV_32S:
      r = "32S";
      m_dataType = GL_INT;
      break;
    case CV_32F:
      r = "32F";
      m_dataType = GL_FLOAT;
      break;
    case CV_64F:
      r = "64F";
      m_dataType = GL_DOUBLE;
      break;
    default:
      r = "User";
      break;
  }

  r += "C";
  r += (chans + '0');
}

// Set incoming texture format to:
// GL_BGR       for CV_CAP_OPENNI_BGR_IMAGE,
// GL_LUMINANCE for CV_CAP_OPENNI_DISPARITY_MAP,
void TextureMat::updateFormatFromMat(cv::Mat& mat) {
  switch (mat.channels()) {
    case 1:
      m_format = GL_RED;
      break;
    case 2:
      m_format = GL_RG;
      break;
    case 3:
      m_format = GL_BGR;
      break;
    case 4:
      m_format = GL_BGRA;
      break;
    default:
      logerror("Unknown channels of mat");
  }
}

void TextureMat::updateOpenGLInternalFormat(cv::Mat& mat) {
  switch (mat.channels()) {
    case 1:
      m_openGLFormat = GL_R8;
      break;
    case 2:
      m_openGLFormat = GL_RG16;
      break;
    case 3:
      m_openGLFormat = GL_RGB;
      break;
    case 4:
      m_openGLFormat = GL_RGBA;
      break;
    default:
      logerror("Unknown channels of mat");
  }

  if (m_dataType == GL_FLOAT && mat.channels() == 3) {
    m_openGLFormat = GL_RGB32F;
  }
}
