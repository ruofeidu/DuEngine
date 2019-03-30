/**
 * DuRenderer is a basic OpenGL-based renderer which implements most of the
 * ShaderToy functionality Ruofei Du | Augmentarium Lab | UMIACS Computer
 * Science Department | University of Maryland, College Park me [at] duruofei
 * [dot] com 12/6/2017
 */
#include "TextureVideoSequence.h"
#include "DuEngine.h"
#include "DuUtils.h"
#include "stdafx.h"

TextureVideoSequence::TextureVideoSequence(string fileName, int fps,
                                           int startFrame, int endFrame,
                                           TextureFilter filter,
                                           TextureWarp warp) {
  init(fileName, false, filter, warp);
  for (int i = startFrame; i < endFrame; ++i) {
    string ithName = fileName;
    if (fileName.find("%d") != string::npos) {
      ithName.replace(ithName.find("%d"), 2, to_string(i));
    }
    cv::Mat mat = cv::imread(ithName);
    if (mat.empty()) {
      logerror("TextureVideoSequence cannot read " + ithName);
    }
    // prepare the vflip before the run time.
    flip(mat, mat, 0);
    m_videoseq.push_back(mat);
  }
  m_mat = m_videoseq[0];
  m_fps = fps;
  info("Read video seq: " + to_string(m_videoseq.size()));
  this->type = TextureType::VideoSequence;
  this->generateFromMat();
  this->initDistribution();
}

void TextureVideoSequence::resetTime() { m_numVideoFrames = 0; }

void TextureVideoSequence::update() {
  if (m_paused) return;
  int iFrame = DuEngine::GetInstance()->getFrameNumber();
  if (!m_distribution[iFrame % m_distribution.size()]) return;

  m_prevTime = clock();
  m_mat = m_videoseq[m_numVideoFrames % m_videoseq.size()];
  ++m_numVideoFrames;

  this->updateFromMat();
}
