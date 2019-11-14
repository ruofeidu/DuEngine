// DuEngine: Real-time Rendering Engine and Shader Testbed
// Ruofei Du | http://www.duruofei.com
//
// Creative Commons Attribution-ShareAlike 3.0 License with 996 ICU clause:
//
// The above license is only granted to entities that act in concordance with
// local labor laws. In addition, the following requirements must be observed:
// The licensee must not, explicitly or implicitly, request or schedule their
// employees to work more than 45 hours in any single week. The licensee must
// not, explicitly or implicitly, request or schedule their employees to be at
// work consecutively for 10 hours. For more information about this protest, see
// http://996.icu

#include "VolumeRenderer.h"
#include "BoxGeometry.h"
#include "DuUtils.h"
#include "ShaderToyGeometry.h"
#include "stdafx.h"

VolumeRenderer::VolumeRenderer(DuEngine* _engine, double _width, double _height,
                               float scale, int _x0, double _y0) {
  auto geometry = new BoxGeometry(_width, _height, _x0, _y0);
  auto rectGeometry = new ShaderToyGeometry(_width, _height, _x0, _y0);
  auto numChannels = _engine->m_config->GetIntWithDefault("channels_count", 0);
  m_screenBuffer = new ShaderToyScreenBuffer(rectGeometry, numChannels);

  auto buffers_count = _engine->m_config->GetIntWithDefault("buffers_count", 0);
  for (int i = 0; i < buffers_count; ++i) {
    auto prefix = string(1, char('A' + i));
    auto numChannels =
        _engine->m_config->GetIntWithDefault(prefix + "_channels_count", 0);
    auto scale =
        _engine->m_config->GetFloatWithDefault(prefix + "_scale", 1.00);
    auto filter = Texture::QueryFilter(
        _engine->m_config->GetStringWithDefault(prefix + "_filter", "linear"));
    auto warp = Texture::QueryWarp(
        _engine->m_config->GetStringWithDefault(prefix + "_warp", "repeat"));
    m_frameBuffers.push_back(new ShaderToyFrameBuffer(
        rectGeometry, scale, numChannels, filter, warp));
  }
#if VERBOSE_OUTPUT
  info("ShaderToy is inited.");
#endif
}

VolumeRenderer::VolumeRenderer(DuEngine* _renderer)
    : VolumeRenderer(_renderer, _renderer->m_window->width,
                     _renderer->m_window->height, 1.0f, 0, 0) {}

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

void VolumeRenderer::recompile() {}

void VolumeRenderer::render() {
  for (auto& frameBuffer : m_frameBuffers) {
    frameBuffer->render();
  }
  for (auto& frameBuffer : m_frameBuffers) {
    frameBuffer->swapTextures();
  }
#if DEBUG_MULTIPASS
  glUniform1i(
      uniforms->uChannels[this->renderer->config->GetIntWithDefault(
          "debug_channel", 2)],
      this->renderer->config->GetIntWithDefault("debug_channel_val", 6));
#endif
  m_screenBuffer->render();
}

int VolumeRenderer::getNumFrameBuffers() { return (int)m_frameBuffers.size(); }

FrameBuffer* VolumeRenderer::getBuffer(int id) {
  return id == 0 ? (FrameBuffer*)m_screenBuffer
                 : (FrameBuffer*)getFrameBuffer(id - 1);
}

ShaderToyFrameBuffer* VolumeRenderer::getFrameBuffer(int id) {
  return id >= 0 && id < m_frameBuffers.size() ? m_frameBuffers[id] : nullptr;
}
