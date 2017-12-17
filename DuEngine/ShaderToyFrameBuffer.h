#pragma once
#include "stdafx.h"
#include "FrameBuffer.h"

class ShaderToyFrameBuffer : public FrameBuffer
{
private:
	GLuint m_pointer;
	// id of the FBO array
	TextureFrameBuffer* m_pointerToTexture;

	// two frame buffer objects
	GLuint m_FBO[2];
	// two texture objects
	TextureFrameBuffer* m_textures[2];

public:
	ShaderToyFrameBuffer(ShaderToyGeometry* _geometry, int numChannels);
	
	GLuint getTextureID();
	Texture* getTexture();

	void swapTextures();

public:
	GLuint getID() override;
	void reshape(int _width, int _height) override;
	void reset() override;
};