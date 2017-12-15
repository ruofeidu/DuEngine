#pragma once
#include "TextureMat.h"

#if COMPILE_WITH_SH
class TextureSH : public TextureMat
{
public:
	TextureSH(int numBands, int numCoef);
	void update(float coef[NUM_COEF]);
private:
	int m_numBands;
};
#endif
