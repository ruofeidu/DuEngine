#include "stdafx.h"
#include "ShaderToy.h"

ShaderToy::ShaderToyFrameBuffer::ShaderToyFrameBuffer(DuEngine* _renderer, ShaderToyGeometry* _geometry, int numChannels) {
	renderer = _renderer;
	geometry = _geometry;
	uniforms = new ShaderToyUniforms(_geometry, numChannels);

	for (int i = 0; i < 2; ++i) {
		glGenFramebuffers(1, &FBO[i]);
		glBindFramebuffer(GL_FRAMEBUFFER, FBO[i]);
		textures[i] = new TextureFrameBuffer(FBO[i], geometry->getWidth(), geometry->getHeight());
	}

	id = 0;
	tex = textures[1 - id];
}

void ShaderToy::ShaderToyFrameBuffer::loadShadersLinkUniforms(string vertexShaderName, string fragShaderName, string uniformShaderName, string mainFileName) {
	shaderProgram = new ShaderProgram(vertexShaderName, fragShaderName, uniformShaderName, mainFileName);
	uniforms->linkShaderProgram(shaderProgram);
#if VERBOSE_OUTPUT
	debug("Frame buffer loaded: " + fragShaderName);
#endif
}

GLuint ShaderToy::ShaderToyFrameBuffer::getID() {
	return FBO[id];
}

GLuint ShaderToy::ShaderToyFrameBuffer::getTextureID() {
	return this->tex->getTextureID();
}

Texture* ShaderToy::ShaderToyFrameBuffer::getTexture() {
	return this->tex;
}

void ShaderToy::ShaderToyFrameBuffer::render() {
	uniforms->update();
	geometry->render();

#if DEBUG_MULTIPASS
	debug("Writing frame buffer " + to_string(getID()) + " and read from texture " + to_string(getTextureID()));
#endif
	//swapTextures();
}

void ShaderToy::ShaderToyFrameBuffer::swapTextures() {
	id = 1 - id;
	tex = textures[1 - id];
	for (int i = 0; i < 2; ++i) {
		textures[i]->setReadingTextureID(tex->getDirectID());
	}
}

void ShaderToy::ShaderToyFrameBuffer::reshape(int _width, int _height) {
	for (int i = 0; i < 2; ++i) {
		glBindFramebuffer(GL_FRAMEBUFFER, FBO[i]);
		glViewport(0, 0, _width, _height);
		textures[i]->reshape(_width, _height);
	}
	this->uniforms->updateResolution(_width, _height);
	this->uniforms->resetFrame();
}

