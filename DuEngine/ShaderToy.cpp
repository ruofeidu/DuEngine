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
	auto geometry = new ShaderToyGeometry(_width, _height, _x0, _y0);
	auto numChannels = _renderer->config->GetIntWithDefault("channels_count", 0);
	m_screenBuffer = new ShaderToyScreenBuffer(geometry, numChannels);

	auto buffers_count = _renderer->config->GetIntWithDefault("buffers_count", 0); 
	for (int i = 0; i < buffers_count; ++i) {
		auto prefix = string(1, char('A' + i));
		auto numChannels = _renderer->config->GetIntWithDefault(prefix + "_channels_count", 0);
		m_frameBuffers.push_back(new ShaderToyFrameBuffer(geometry, numChannels));
	}
#if VERBOSE_OUTPUT
	info("ShaderToy is inited.");
#endif
}

ShaderToy::ShaderToy(DuEngine *_renderer) : ShaderToy(_renderer, _renderer->m_window->width, _renderer->m_window->height, 0, 0) {
}

void ShaderToy::reshape(int _width, int _height) {
	m_screenBuffer->reshape(_width, _height); 
	for (auto& frameBuffer : m_frameBuffers) {
		frameBuffer->reshape(_width, _height); 
	}
}

void ShaderToy::reset() {
	m_screenBuffer->reset(); 
	for (auto& frameBuffer : m_frameBuffers) {
		frameBuffer->reset();
	}
}

void ShaderToy::recompile() {

}

void ShaderToy::render() {
	for (auto& frameBuffer : m_frameBuffers) {
		frameBuffer->render();
	}
	for (auto& frameBuffer : m_frameBuffers) {
		frameBuffer->swapTextures();
	}
#if DEBUG_MULTIPASS
	glUniform1i(uniforms->uChannels[this->renderer->config->GetIntWithDefault("debug_channel", 2)], this->renderer->config->GetIntWithDefault("debug_channel_val", 6));
#endif
	m_screenBuffer->render();
}

int ShaderToy::getNumFrameBuffers() {
	return (int)m_frameBuffers.size();
}

FrameBuffer* ShaderToy::getBuffer(int id) {
	return id == 0 ? (FrameBuffer*)m_screenBuffer : (FrameBuffer*)getFrameBuffer(id - 1);
}

ShaderToyFrameBuffer * ShaderToy::getFrameBuffer(int id) {
	return id >= 0 && id < m_frameBuffers.size() ? m_frameBuffers[id] : nullptr; 
}
