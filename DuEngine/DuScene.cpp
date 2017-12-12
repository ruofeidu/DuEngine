#include "stdafx.h"
#include "DuEngine.h"
#include "DuUtils.h"
using namespace std;
using namespace cv;

void DuEngine::initScene() {
	clock_t begin_time = clock();

	shadertoy = new ShaderToy(DuEngine::GetInstance());

	for (int buffer = 0; buffer < 1 + shadertoy->m_frameBuffers.size(); ++buffer) {
		auto suffix = buffer == 0 ? "" : string(1, char('A' + buffer - 1));
		auto prefix = buffer == 0 ? "" : suffix + "_";
		auto fbo = buffer == 0 ? nullptr : shadertoy->m_frameBuffers[buffer - 1];

		auto uniforms = buffer == 0 ? shadertoy->uniforms : fbo->uniforms; 
		auto vertexShaderName = config->GetStringWithDefault("shader_vert", m_relativePath + "shadertoy.vert.glsl");
		auto fragmentShaderName = config->GetStringWithDefault("shader_frag", m_relativePath + "shadertoy.default.glsl");
		auto uniformShaderName = config->GetStringWithDefault("shader_uniform", m_relativePath + "shadertoy.uniforms.glsl");
		auto mainShaderName = config->GetStringWithDefault("shader_main", m_relativePath + "shadertoy.main.glsl");

		// replace the fragment shader name with $Name and buffer prefix / suffix
		if (fragmentShaderName.find("$Name") != string::npos) {
			fragmentShaderName.replace(fragmentShaderName.find("$Name"), 5, m_sceneName); 
		}
		if (fragmentShaderName.find(".glsl") != string::npos) {
			fragmentShaderName.replace(fragmentShaderName.find(".glsl"), 5, suffix + ".glsl");
		} else {
			fragmentShaderName += suffix + ".glsl";
		}

		if (buffer == 0) {
			shadertoy->loadShaders(vertexShaderName, fragmentShaderName, uniformShaderName, mainShaderName);
		} else {
			fbo->loadShaders(vertexShaderName, fragmentShaderName, uniformShaderName, mainShaderName);
		}

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
				fileName = m_relativePath + fileName;
			}
			// replace the common textures into the true file names
			for (const auto& key : ImageTextures) {
				if (!type.compare(key.first)) {
					type = "rgb";
					fileName = m_presetPath + key.second;
					break;
				}
			}
			for (const auto& key : VideoTextures) {
				if (!type.compare(key.first)) {
					type = "video";
					fileName = m_presetPath + key.second;
					break;
				}
			}

			// texture filters
			auto filter = config->GetStringWithDefault(iPrefix + "_filter", "mipmap");
			auto textureFilter = filter == "linear" ? TextureFilter::LINEAR : ((filter == "nearest") ? TextureFilter::NEAREST : TextureFilter::MIPMAP);

			// texture wrappers
			auto wrap = config->GetStringWithDefault(iPrefix + "_wrap", "repeat");
			auto TextureWarp = !wrap.compare("repeat") ? TextureWarp::REPEAT : TextureWarp::CLAMP;

			auto vFlip = config->GetBoolWithDefault(iPrefix + "_vflip", true);
			if (!type.compare("rgb")) {
				info("Reading texture " + fileName);
				auto t = new Texture2D(fileName, vFlip, textureFilter, TextureWarp);
				uniforms->bindTexture2D(t, i);
				debug("RGB: " + to_string(t->GetTextureID()));

			} else
			if (!type.compare("video")) {
				auto t = new VideoTexture(fileName, vFlip, textureFilter, TextureWarp);
				videoTextures.push_back(t);
				uniforms->bindTexture2D(t, i);
			} else
			if (!type.compare("key")) {
				if (!keyboardTexture) {
					keyboardTexture = new KeyboardTexture();
				}
				uniforms->bindTexture2D(keyboardTexture, i);
			} else
			if (!type.compare("font")) {
				if (!fontTexture) {
					fontTexture = new Texture2D(m_presetPath + FontTextures["font"], true, textureFilter, TextureWarp);
				}
				uniforms->bindTexture2D(fontTexture, i);
			} else
			if (type.size() == 1) {
				int bufferID = (int)(type[0] - 'a');
				auto bindedFbo = shadertoy->m_frameBuffers[bufferID];
				uniforms->bindTexture2D(bindedFbo->getTexture(), i);
				debug("Buffer " + to_string(buffer) + to_string(i) + " bind with " + to_string(bufferID) +
					", whose texture ID is " + to_string(bindedFbo->getTextureID()));
			}
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