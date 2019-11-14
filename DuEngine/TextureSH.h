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
#include "TextureVideoSequence.h"

#if COMPILE_WITH_SH
class TextureSH : public TextureVideoSequence {
 public:
  TextureSH(string fileName, int fps, int startFrame, int endFrame,
            int numBands);

 private:
  int m_numBands = 25;
  int m_numCoefficients = m_numBands * m_numBands;
};
#endif
