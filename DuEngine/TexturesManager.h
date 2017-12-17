#pragma once
#include "Texture.h"
#include "TextureMat.h"
#include "Texture2D.h"
#include "Texture3D.h"
#include "TextureVideo.h"
#include "TextureVideoFile.h"
#include "TextureVideoSequence.h"
#include "TextureVideoLightField.h"
#include "TextureKeyboard.h"
#include "TextureLightField.h"
#include "TextureFrameBuffer.h"
#include "TextureFont.h"
#include "TextureSH.h"
#include "DuUtils.h"

class TexturesManager
{
public:
	static TexturesManager *GetInstance();
	void reset();

private:
	static TexturesManager *s_Instance;

	class GC
	{
	public:
		~GC() {
			if (s_Instance != NULL) {
				delete s_Instance;
				s_Instance = NULL;
			}
		}
	};
	static GC gc;
};
