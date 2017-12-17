#pragma once
#include "stdafx.h"
#include "TexturesManager.h"

TexturesManager* TexturesManager::GetInstance() {
	return s_Instance;
}

void TexturesManager::reset() {

}

TexturesManager *TexturesManager::s_Instance = new TexturesManager();
TexturesManager::GC TexturesManager::gc;
