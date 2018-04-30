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
	auto numChannels = _renderer->m_config->GetIntWithDefault("channels_count", 0);
	m_screenBuffer = new ShaderToyScreenBuffer(geometry, numChannels);

	auto buffers_count = _renderer->m_config->GetIntWithDefault("buffers_count", 0);
	for (int i = 0; i < buffers_count; ++i) {
		auto prefix = string(1, char('A' + i));
		auto numChannels = _renderer->m_config->GetIntWithDefault(prefix + "_channels_count", 0);
		auto scale = _renderer->m_config->GetFloatWithDefault(prefix + "_scale", 1.0f);
		auto filter = Texture::QueryFilter(_renderer->m_config->GetStringWithDefault(prefix + "_filter", "linear"));
		auto warp = Texture::QueryWarp(_renderer->m_config->GetStringWithDefault(prefix + "_warp", "repeat"));

		if (scale < 1.0) {
			geometry = new ShaderToyGeometry(_width * scale, _height * scale, _x0, _y0);
		}
		m_frameBuffers.push_back(new ShaderToyFrameBuffer(geometry, 1.0f, numChannels, filter, warp));
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

void ShaderToy::recompile(DuEngine * _renderer) {
	clock_t begin_time = clock();
	auto m_path = _renderer->m_path;
	auto m_config = _renderer->m_config;
	auto m_textureManager = _renderer->m_textureManager;

	ShaderFileParas paras;
	paras.vert = m_path->getVertexShader();
	paras.uniform = m_path->getUniformShader();
	paras.main = m_path->getMainShader();
	paras.common = m_path->getCommonShader();

	// iterate through buffers; 0: the main framebuffer
	for (int buffer = 0; buffer < 1 + this->getNumFrameBuffers(); ++buffer) {
		auto suffix = !buffer ? "" : string(1, char('A' + buffer - 1));
		auto prefix = !buffer ? "" : suffix + "_";
		auto fbo = this->getBuffer(buffer);
		ShaderToyUniforms* uniforms = (ShaderToyUniforms*)(fbo->getUniforms());
		paras.frag = m_path->getFragmentShader(suffix);
		auto channels_count = m_config->GetIntWithDefault(prefix + "channels_count", 0);

		paras.uniformAppendix = "";
		for (int i = 0; i < channels_count; ++i) {
			auto iPrefix = prefix + "iChannel" + to_string(i) + "_";
			auto type = toLower(m_config->GetStringWithDefault(iPrefix + "type", "unknown"));
			auto fileName = m_path->getResource(iPrefix + "tex");
			Texture::QueryFileNameByType(type, fileName, m_path->getPresetPath());
			auto textureType = Texture::QueryType(type);
			paras.uniformAppendix += "uniform " + Texture::QuerySampler(textureType) + " iChannel" + to_string(i) + "; \n";
		}
		//debug(paras.uniformAppendix); 
		fbo->loadShadersLinkUniforms(paras);

		// bind channel textures
		for (int i = 0; i < channels_count; ++i) {
			auto iPrefix = prefix + "iChannel" + to_string(i) + "_";
			auto type = toLower(m_config->GetStringWithDefault(iPrefix + "type", "unknown"));
			auto fileName = m_path->getResource(iPrefix + "tex");
			Texture::QueryFileNameByType(type, fileName, m_path->getPresetPath());
			auto textureType = Texture::QueryType(type);
			auto textureFilter = Texture::QueryFilter(m_config->GetStringWithDefault(iPrefix + "filter", "mipmap"));
			auto textureWarp = Texture::QueryWarp(m_config->GetStringWithDefault(iPrefix + "wrap", "repeat"));
			auto vFlip = m_config->GetBoolWithDefault(iPrefix + "vflip", true);
			auto fps = m_config->GetIntWithDefault(iPrefix + "fps", 25);
			auto startFrame = m_config->GetIntWithDefault(iPrefix + "startFrame", 1);
			auto endFrame = m_config->GetIntWithDefault(iPrefix + "endFrame", 100);
			auto numBands = m_config->GetIntWithDefault(iPrefix + "bands", 25);
			auto rows = 16;
			auto cols = 16;

			Texture* t = nullptr;

			switch (textureType) {
			case TextureType::Noise:
				vFlip = m_config->GetBoolWithDefault(iPrefix + "vflip", false);
			case TextureType::RGB:
				t = m_textureManager->addTexture2D(fileName, vFlip, textureFilter, textureWarp);
				break;
			case TextureType::VideoFile:
				t = m_textureManager->addVideoFile(fileName, vFlip, textureFilter, textureWarp);
				break;
			case TextureType::Camera:
				t = m_textureManager->addCamera(vFlip, textureFilter, textureWarp);
				break;
			case TextureType::VideoSequence:
				t = m_textureManager->addVideoSequence(fileName, fps, startFrame, endFrame, textureFilter, textureWarp);
				break;
			case TextureType::SH:
				t = m_textureManager->addSphericalHarmonics(fileName, fps, startFrame, endFrame, numBands);
				break;
			case TextureType::Keyboard:
				t = m_textureManager->addKeyboard();
				break;
			case TextureType::Font:
				t = m_textureManager->addFont(textureFilter, textureWarp);
				break;
			case TextureType::CubeMap:
				vFlip = m_config->GetBoolWithDefault(iPrefix + "vflip", false);
				textureWarp = Texture::QueryWarp(m_config->GetStringWithDefault(iPrefix + "wrap", "clamp"));
				t = m_textureManager->addTextureCubeMap(fileName, vFlip, textureFilter, textureWarp);
				break;
			case TextureType::LightField:
				vFlip = m_config->GetBoolWithDefault(iPrefix + "vflip", false);
				rows = m_config->GetIntWithDefault(iPrefix + "rows", rows);
				cols = m_config->GetIntWithDefault(iPrefix + "cols", cols);
				t = m_textureManager->addTextureLightField(fileName, rows, cols, textureFilter, textureWarp);
				break;
			case TextureType::FrameBuffer:
				int bufferID = (int)(type[0] - 'a');
				auto bindedFbo = this->getFrameBuffer(bufferID);
				t = bindedFbo->getTexture();
#if DEBUG_MULTIPASS
				debug("Buffer " + to_string(buffer) + to_string(i) + " bind with " + to_string(bufferID) +
					", whose texture ID is " + to_string(bindedFbo->getTextureID()));
#endif
				break;
			}

			if (t != nullptr) {
				uniforms->bindTexture(t, i);
			} else {
				logerror("Unknown texture type!");
			}
		}

		// buffer of vector 2
		auto vec2_buffers_count = m_config->GetIntWithDefault("vec2_buffers_count", 0);
		uniforms->intVec2Buffers(vec2_buffers_count);

		for (int i = 0; i < vec2_buffers_count; ++i) {
			auto fileName = m_path->getResource("vec2_buffers" + to_string(i) + "_file");
			uniforms->bindVec2Buffer(i, fileName);
		}

		// transfer function
		auto transfer_function_count = m_config->GetIntWithDefault("transfer_function_count", 0);
		for (int i = 0; i < transfer_function_count; ++i) {
			auto color = m_config->GetString("transfer_" + to_string(i) + "_color");
			auto pos = m_config->GetFloat("transfer_" + to_string(i) + "_pos");
		}
		if (transfer_function_count > 0) {

		}
	}

	info("Initialization of the scene costs: " + to_string(float(clock() - begin_time) / CLOCKS_PER_SEC) + " s");
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
