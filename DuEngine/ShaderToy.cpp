/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
* 12/6/2017
*/
#include "stdafx.h"
#include "ShaderToy.h"
#include "DuUtils.h"

ShaderToy::ShaderToy(DuEngine * _renderer, double _width, double _height, int _x0, double _y0) {
	renderer = _renderer;
	geometry = new ShaderToyGeometry(_width, _height, _x0, _y0);
	shaderProgram = nullptr;
	numChannels = _renderer->config->GetIntWithDefault("channels_count", 0);
	uniforms = new ShaderToyUniforms(geometry, numChannels);
	auto buffers_count = _renderer->config->GetIntWithDefault("buffers_count", 0); 
	for (int i = 0; i < buffers_count; ++i) {
		auto prefix = string(1, char('A' + i));
		m_frameBuffers.push_back(new ShaderToyFrameBuffer(renderer, geometry, _renderer->config->GetIntWithDefault(prefix + "_channels_count", 0)));
	}
#if VERBOSE_OUTPUT
	info("ShaderToy is inited.");
#endif
}

ShaderToy::ShaderToy(DuEngine *_renderer) : ShaderToy(_renderer, _renderer->window->width, _renderer->window->height, 0, 0) {
}

void ShaderToy::loadShadersLinkUniforms(string vertexShaderName, string fragShaderName, string uniformShaderName, string mainFileName = "") {
	shaderProgram = new ShaderProgram(vertexShaderName, fragShaderName, uniformShaderName, mainFileName);
	uniforms->linkShaderProgram(shaderProgram);
#if VERBOSE_OUTPUT
	info("Main fragment shader loaded: " + fragShaderName);
#endif
}

void ShaderToy::reshape(int _width, int _height) {
	uniforms->updateResolution(_width, _height); 
	uniforms->resetFrame();

	for (auto& frameBuffer : m_frameBuffers) {
		frameBuffer->reshape(_width, _height); 
	}
}

void ShaderToy::render() {
	for (auto& frameBuffer : m_frameBuffers) {
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, frameBuffer->getID());
		frameBuffer->render();
	}

	for (auto& frameBuffer : m_frameBuffers) {
		frameBuffer->swapTextures();
	}

	glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
	uniforms->update();

#if DEBUG_MULTIPASS
	glUniform1i(uniforms->uChannels[this->renderer->config->GetIntWithDefault("debug_channel", 2)], this->renderer->config->GetIntWithDefault("debug_channel_val", 6));
#endif
	geometry->render();
}
