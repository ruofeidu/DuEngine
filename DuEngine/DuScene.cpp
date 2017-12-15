/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
* 12/6/2017
*/
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
			string iPrefix = prefix + "iChannel" + to_string(i) + "_";
			auto type = config->GetStringWithDefault(iPrefix + "type", "unknown");
			std::transform(type.begin(), type.end(), type.begin(), ::tolower);
			auto fileName = smartFilePath(config->GetStringWithDefault(iPrefix + "tex", ""), m_resourcesPath);
			Texture::QueryFileNameByType(type, fileName, m_presetsPath);
			auto textureType = Texture::QueryType(type);
			auto textureFilter = Texture::QueryFilter(config->GetStringWithDefault(iPrefix + "filter", "mipmap"));
			auto textureWarp = Texture::QueryWarp(config->GetStringWithDefault(iPrefix + "wrap", "repeat"));
			auto vFlip = config->GetBoolWithDefault(iPrefix + "vflip", true);
			auto fps = config->GetIntWithDefault(iPrefix + "fps", 25);
			auto startFrame = config->GetIntWithDefault(iPrefix + "startFrame", 1);
			auto endFrame = config->GetIntWithDefault(iPrefix + "endFrame", 100);

			Texture* t = nullptr; 

			switch (textureType) {
			case TextureType::RGB:
				t = new Texture2D(fileName, vFlip, textureFilter, textureWarp); 
				break;
			case TextureType::VideoFile:
				t = new TextureVideoFile(fileName, vFlip, textureFilter, textureWarp);
				videoTextures.push_back((TextureVideo*)t);
				break;
			case TextureType::VideoSequence:
				t = new TextureVideoSequence(fileName, fps, startFrame, endFrame, textureFilter, textureWarp);
				videoTextures.push_back((TextureVideo*)t);
				break;
			case TextureType::Keyboard:
				if (!keyboardTexture)
					keyboardTexture = new TextureKeyboard();
				t = keyboardTexture;
				break; 
			case TextureType::Font:
				if (!fontTexture) {
					fontTexture = new TextureFont(textureFilter, textureWarp);
				}
				t = fontTexture;
				break; 
			case TextureType::FrameBuffer:
				int bufferID = (int)(type[0] - 'a');
				auto bindedFbo = shadertoy->m_frameBuffers[bufferID];
				t = bindedFbo->getTexture();
#if DEBUG_MULTIPASS
				debug("Buffer " + to_string(buffer) + to_string(i) + " bind with " + to_string(bufferID) +
					", whose texture ID is " + to_string(bindedFbo->getTextureID()));
#endif
				break; 
			}

			if (t != nullptr) {
				uniforms->bindTexture2D(t, i);
			} else {
				logerror("Unknown texture type!");
			}
		}

		auto vec2_buffers_count = config->GetIntWithDefault("vec2_buffers_count", 0);
		shadertoy->uniforms->intVec2Buffers(vec2_buffers_count);

		for (int i = 0; i < vec2_buffers_count; ++i) {
			string s = "vec2_buffers" + to_string(i) + "_file";
			auto fileName = smartFilePath(config->GetString(s), m_resourcesPath);
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