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
#include "TextureCubeMap.h"
#include "TextureCamera.h"
#include "DuUtils.h"

class TexturesManager
{
public:
	TexturesManager() {};
	static TexturesManager *GetInstance();
	void update(); 
	void reset();
	void togglePause(); 
	void updateKeyboard(unsigned char key, bool up); 

	Texture* addKeyboard();
	Texture* addFont(TextureFilter filter, TextureWarp warp);
	Texture* addVideoFile(string fileName, bool vFlip, TextureFilter filter, TextureWarp warp);
	Texture* addCamera(bool vFlip, TextureFilter filter, TextureWarp warp);
	Texture* addVideoSequence(string fileName, int fps, int startFrame, int endFrame, TextureFilter filter, TextureWarp warp);
	Texture* addSphericalHarmonics(string fileName, int fps, int startFrame, int endFrame, int numBands);
	Texture* addTexture2D(string fileName, bool vFlip, TextureFilter filter, TextureWarp warp);
	Texture* addTexture3D(string fileName, TextureFilter filter, TextureWarp warp);
	Texture* addTextureCubeMap(string fileName, bool vFlip, TextureFilter filter, TextureWarp warp);
	Texture* addTextureLightField(string fileName, int rows, int cols, TextureFilter filter, TextureWarp warp);

private:
	void addVideoTexture(TextureVideo* tex);
	vector<TextureVideo*> m_videos;
	TextureKeyboard* m_keyboard;
	Texture* m_font;
	vector<Texture*> m_textures;

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
