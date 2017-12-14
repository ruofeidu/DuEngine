#include "stdafx.h"
#include "DuEngine.h"
#include "DuUtils.h"
using namespace std;
using namespace cv;

void DuEngine::initScene() {
	clock_t begin_time = clock();
	
	shadertoy = new ShaderToy(DuEngine::GetInstance());

	auto vertexShaderName = config->GetStringWithDefault("shader_vert", m_shadersPath + "shadertoy.vert.glsl");
	auto uniformShaderName = config->GetStringWithDefault("shader_uniform", m_shadersPath + "shadertoy.uniforms.glsl");
	auto mainShaderName = config->GetStringWithDefault("shader_main", m_shadersPath + "shadertoy.main.glsl");

	for (int buffer = 0; buffer < 1 + shadertoy->m_frameBuffers.size(); ++buffer) {
		auto suffix = !buffer ? "" : string(1, char('A' + buffer - 1));
		auto prefix = !buffer ? "" : suffix + "_";
		auto fbo = !buffer ? nullptr : shadertoy->m_frameBuffers[buffer - 1];
		auto uniforms = !buffer ? shadertoy->uniforms : fbo->uniforms; 

		// replace the fragment shader name with $Name and buffer prefix / suffix
		auto fragmentShaderName = config->GetStringWithDefault("shader_frag", m_shadersPath + "shadertoy.default.glsl");
		if (fragmentShaderName.find("$Name") != string::npos) {
			fragmentShaderName.replace(fragmentShaderName.find("$Name"), 5, m_sceneName); 
		}
		if (fragmentShaderName.find(".glsl") != string::npos) {
			// add framebuffer suffix for multipass rendering
			fragmentShaderName.replace(fragmentShaderName.find(".glsl"), 5, suffix + ".glsl");
		} else {
			fragmentShaderName += suffix + ".glsl";
		}

		// load the shader
		if (!buffer) {
			shadertoy->loadShadersLinkUniforms(vertexShaderName, fragmentShaderName, uniformShaderName, mainShaderName);
		} else {
			fbo->loadShadersLinkUniforms(vertexShaderName, fragmentShaderName, uniformShaderName, mainShaderName);
		}

		// bind channel textures
		auto channels_count = config->GetIntWithDefault(prefix + "channels_count", 0);
		for (int i = 0; i < channels_count; ++i) {
			string iPrefix = prefix + "iChannel" + to_string(i);
			auto type = config->GetStringWithDefault(iPrefix + "_type", "rgb");
			std::transform(type.begin(), type.end(), type.begin(), ::tolower);
			auto fileName = config->GetStringWithDefault(iPrefix + "_tex", "");
			if (fileName.size() > 2 && fileName[1] == ':') {
				// use absolute path
				fileName = fileName; 
			} else {
				fileName = m_shadersPath + fileName;
			}

			// replace the predefined textures into the real file names
			for (const auto& key : Texture::ImageTextures) {
				if (!type.compare(key.first)) {
					type = "rgb";
					fileName = m_presetsPath + key.second;
					break;
				}
			}
			for (const auto& key : Texture::VideoTextures) {
				if (!type.compare(key.first)) {
					type = "video";
					fileName = m_presetsPath + key.second;
					break;
				}
			}

			auto textureType = Texture::QueryType(type);
			auto textureFilter = Texture::QueryFilter(config->GetStringWithDefault(iPrefix + "_filter", "mipmap"));
			auto textureWarp = Texture::QueryWarp(config->GetStringWithDefault(iPrefix + "_wrap", "repeat"));
			auto vFlip = config->GetBoolWithDefault(iPrefix + "_vflip", true);
			Texture* t = nullptr; 

			switch (textureType) {
			case TextureType::RGB:
				t = new Texture2D(fileName, vFlip, textureFilter, textureWarp); 
				break;
			case TextureType::VideoFile:
				t = new VideoFileTexture(fileName, vFlip, textureFilter, textureWarp);
				videoTextures.push_back((VideoTexture*)t);
				break;
			case TextureType::VideoSequence:
				break; 
			case TextureType::Keyboard:
				if (!keyboardTexture)
					keyboardTexture = new KeyboardTexture();
				t = keyboardTexture;
			case TextureType::Font:
				if (!fontTexture) {
					fontTexture = new FontTexture(textureFilter, textureWarp);
				}
				t = fontTexture;
			case TextureType::FrameBuffer:
				int bufferID = (int)(type[0] - 'a');
				auto bindedFbo = shadertoy->m_frameBuffers[bufferID];
				t = bindedFbo->getTexture();
#if DEBUG_MULTIPASS
				debug("Buffer " + to_string(buffer) + to_string(i) + " bind with " + to_string(bufferID) +
					", whose texture ID is " + to_string(bindedFbo->getTextureID()));
#endif
			}
			uniforms->bindTexture2D(t, i);
		}

		auto vec2_buffers_count = config->GetIntWithDefault("vec2_buffers_count", 0);
		shadertoy->uniforms->intVec2Buffers(vec2_buffers_count);

		for (int i = 0; i < vec2_buffers_count; ++i) {
			string s = "vec2_buffers" + to_string(i) + "_file";
			auto fileName = config->GetString(s);
			shadertoy->uniforms->bindVec2Buffer(i, fileName);
		}
	}

	info("Initialization of the scene costs: " + to_string(float(clock() - begin_time) / CLOCKS_PER_SEC) + " s");
}

int DuEngine::getFrameNumber() {
	return this->shadertoy->uniforms->iFrame;
}

void DuEngine::render() {
	if (!m_paused) {
		for (const auto& v : videoTextures) v->update();
		shadertoy->render();

		glutSwapBuffers();
		glutPostRedisplay();
	}

	if (m_recording && m_recordStart <= getFrameNumber() && getFrameNumber() <= m_recordEnd) {
		this->takeScreenshot(m_recordPath);
	}
}

void DuEngine::updateFPS(float timeDelta, float averageTimeDelta) {
	shadertoy->uniforms->updateFPS(timeDelta, averageTimeDelta);
}