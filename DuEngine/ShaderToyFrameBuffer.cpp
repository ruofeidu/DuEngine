#include "stdafx.h"
#include "ShaderToy.h"

ShaderToyFrameBuffer::ShaderToyFrameBuffer(ShaderToyGeometry* _geometry, int numChannels) {
	m_geometry = _geometry;
	m_uniforms = new ShaderToyUniforms(_geometry, numChannels);

	for (int i = 0; i < 2; ++i) {
		glGenFramebuffers(1, &m_FBO[i]);
		glBindFramebuffer(GL_FRAMEBUFFER, m_FBO[i]);
		m_textures[i] = new TextureFrameBuffer(m_FBO[i], m_geometry->getWidth(), m_geometry->getHeight());
	}

	m_pointer = 0;
	m_pointerToTexture = m_textures[1 - m_pointer];
}

GLuint ShaderToyFrameBuffer::getID() {
	return m_FBO[m_pointer];
}

GLuint ShaderToyFrameBuffer::getTextureID() {
	return m_pointerToTexture->getTextureID();
}

Texture* ShaderToyFrameBuffer::getTexture() {
	return m_pointerToTexture;
}

void ShaderToyFrameBuffer::swapTextures() {
	m_pointer = 1 - m_pointer;
	m_pointerToTexture = m_textures[1 - m_pointer];
	for (int i = 0; i < 2; ++i) {
		m_textures[i]->setReadingTextureID(m_pointerToTexture->getDirectID());
	}
}

void ShaderToyFrameBuffer::reshape(int _width, int _height) {
	for (int i = 0; i < 2; ++i) {
		glBindFramebuffer(GL_FRAMEBUFFER, m_FBO[i]);
		glViewport(0, 0, _width, _height);
		m_textures[i]->reshape(_width, _height);
	}
	m_uniforms->reset(_width, _height); 
}

void ShaderToyFrameBuffer::reset() {
	
}

