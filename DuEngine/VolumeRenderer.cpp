/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
* 12/6/2017
*/
#include "stdafx.h"
#include "VolumeRenderer.h"
#include "BoxGeometry.h"
#include "DuUtils.h"

VolumeRenderer::VolumeRenderer(DuEngine * _engine, double _width, double _height, int _x0, double _y0) {
	auto geometry = new BoxGeometry(_width, _height, _x0, _y0);
	auto numChannels = _engine->m_config->GetIntWithDefault("channels_count", 0);
	m_screenBuffer = new ShaderToyScreenBuffer(geometry, numChannels);

	auto buffers_count = _engine->m_config->GetIntWithDefault("buffers_count", 0);
	for (int i = 0; i < buffers_count; ++i) {
		auto prefix = string(1, char('A' + i));
		auto numChannels = _engine->m_config->GetIntWithDefault(prefix + "_channels_count", 0);
		m_frameBuffers.push_back(new ShaderToyFrameBuffer(geometry, numChannels));
	}
#if VERBOSE_OUTPUT
	info("ShaderToy is inited.");
#endif
}

VolumeRenderer::VolumeRenderer(DuEngine *_renderer) : VolumeRenderer(_renderer, _renderer->m_window->width, _renderer->m_window->height, 0, 0) {
}

void VolumeRenderer::reshape(int _width, int _height) {
	m_screenBuffer->reshape(_width, _height);
	for (auto& frameBuffer : m_frameBuffers) {
		frameBuffer->reshape(_width, _height);
	}
}

void VolumeRenderer::reset() {
	m_screenBuffer->reset();
	for (auto& frameBuffer : m_frameBuffers) {
		frameBuffer->reset();
	}
}

void VolumeRenderer::recompile() {

}

void VolumeRenderer::render() {
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

int VolumeRenderer::getNumFrameBuffers() {
	return (int)m_frameBuffers.size();
}

FrameBuffer* VolumeRenderer::getBuffer(int id) {
	return id == 0 ? (FrameBuffer*)m_screenBuffer : (FrameBuffer*)getFrameBuffer(id - 1);
}

ShaderToyFrameBuffer * VolumeRenderer::getFrameBuffer(int id) {
	return id >= 0 && id < m_frameBuffers.size() ? m_frameBuffers[id] : nullptr;
}
