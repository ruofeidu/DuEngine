#pragma once
#include "TextureVideoSequence.h"

#if COMPILE_WITH_SH
class TextureSH : public TextureVideoSequence
{
public:
	TextureSH(string fileName, int fps, int startFrame, int endFrame, int numBands);
private:
	int m_numBands = 25;
	int m_numCoefficients = m_numBands * m_numBands; 
};
#endif
