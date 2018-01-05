#pragma once
#include "stdafx.h"
#include "TexturesManager.h"

TexturesManager* TexturesManager::GetInstance() {
	return s_Instance;
}

void TexturesManager::update() {
	for (const auto& v : m_videos) v->update();
}

void TexturesManager::reset() {

}

void TexturesManager::togglePause() {
	for (const auto& t : m_videos) {
		t->togglePaused();
	}
}

void TexturesManager::updateKeyboard(unsigned char key, bool up) {
	if (!m_keyboard) return; 

	m_keyboard->onKeyPress(key, up);
	// hack the four arrows for ShaderToy
	if (100 <= key && key <= 103) {
		key -= 63;
	} 
	else 
	// hack the capitalization of a-z
	if (65 <= key && key <= 90) {
		key += 97 - 65; 
	}
	if (97 <= key && key <= 122) {
		key -= 97 - 65;
	}

	m_keyboard->onKeyPress(key, up);
}

Texture * TexturesManager::addVideoFile(string filename, bool vflip, TextureFilter filter, TextureWarp warp) {
	auto t = new TextureVideoFile(filename, vflip, filter, warp);
	addVideoTexture((TextureVideo*)t);
	return t; 
}

Texture * TexturesManager::addVideoSequence(string fileName, int fps, int startFrame, int endFrame, TextureFilter filter, TextureWarp warp) {
	auto t = new TextureVideoSequence(fileName, fps, startFrame, endFrame, filter, warp);
	addVideoTexture((TextureVideo*)t);
	return t; 
}

Texture * TexturesManager::addSphericalHarmonics(string fileName, int fps, int startFrame, int endFrame, int numBands) {
	auto t = new TextureSH(fileName, fps, startFrame, endFrame, numBands);
	addVideoTexture((TextureVideo*)t);
	return t; 
}

Texture * TexturesManager::addTexture2D(string fileName, bool vFlip, TextureFilter filter, TextureWarp warp) {
	auto t = new Texture2D(fileName, vFlip, filter, warp);
	return t; 
}

Texture * TexturesManager::addTextureCubeMap(string fileName, bool vFlip, TextureFilter filter, TextureWarp warp) {
	auto t = new TextureCubeMap(fileName, vFlip, filter, warp);
	return t;
}

Texture * TexturesManager::addKeyboard() {
	if (!m_keyboard) m_keyboard = new TextureKeyboard();
	return m_keyboard;
}

Texture * TexturesManager::addFont(TextureFilter filter, TextureWarp warp) {
	if (!m_font) m_font = new TextureFont(filter, warp);
	return m_font;
}

void TexturesManager::addVideoTexture(TextureVideo * tex) {
	m_videos.push_back(tex);
}

TexturesManager *TexturesManager::s_Instance = new TexturesManager();
TexturesManager::GC TexturesManager::gc;
