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
	
	m_shadertoy = new ShaderToy(DuEngine::GetInstance());

	auto vertexShaderName = m_path->getVertexShader();
	auto uniformShaderName = m_path->getUniformShader();
	auto mainShaderName = m_path->getMainShader();

	// iterate through buffers; 0: the main framebuffer
	for (int buffer = 0; buffer < 1 + m_shadertoy->getNumFrameBuffers(); ++buffer) {
		auto suffix = !buffer ? "" : string(1, char('A' + buffer - 1));
		auto prefix = !buffer ? "" : suffix + "_";
		auto fbo = m_shadertoy->getBuffer(buffer); 
		ShaderToyUniforms* uniforms = (ShaderToyUniforms*)(fbo->getUniforms());
		auto fragmentShaderName = m_path->getFragmentShader(suffix);
		auto channels_count = m_config->GetIntWithDefault(prefix + "channels_count", 0);

		string uniformSampler = "";
		for (int i = 0; i < channels_count; ++i) {
			auto iPrefix = prefix + "iChannel" + to_string(i) + "_";
			auto type = toLower(m_config->GetStringWithDefault(iPrefix + "type", "unknown"));
			auto fileName = m_path->getResource(iPrefix + "tex");
			Texture::QueryFileNameByType(type, fileName, m_path->getPresetPath());
			auto textureType = Texture::QueryType(type);
			uniformSampler += "uniform " + Texture::QuerySampler(textureType) + " iChannel" + to_string(i) + "; \n";
		}
		debug(uniformSampler); 
		fbo->loadShadersLinkUniforms(vertexShaderName, fragmentShaderName, uniformShaderName, mainShaderName, uniformSampler);

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
			case TextureType::FrameBuffer:
				int bufferID = (int)(type[0] - 'a');
				auto bindedFbo = m_shadertoy->getFrameBuffer(bufferID);
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

		auto vec2_buffers_count = m_config->GetIntWithDefault("vec2_buffers_count", 0);
		uniforms->intVec2Buffers(vec2_buffers_count);

		for (int i = 0; i < vec2_buffers_count; ++i) {
			auto fileName = m_path->getResource("vec2_buffers" + to_string(i) + "_file");
			uniforms->bindVec2Buffer(i, fileName);
		}
	}

	info("Initialization of the scene costs: " + to_string(float(clock() - begin_time) / CLOCKS_PER_SEC) + " s");
}

int DuEngine::getFrameNumber() {
	return ShaderToyUniforms::iFrame;
}

void DuEngine::render() {
	if (!m_paused) {
		m_textureManager->update(); 
		m_shadertoy->render();

		glutSwapBuffers();
		glutPostRedisplay();
	}

	if (m_recording && m_recordStart <= getFrameNumber() && getFrameNumber() <= m_recordEnd) {
		this->takeScreenshot(m_recordPath);
	}
	if (m_takeSingleScreenShot) {
		m_takeSingleScreenShot = false; 
		this->takeScreenshot();
	}
}

void DuEngine::updateFPS(float timeDelta, float averageTimeDelta) {
	ShaderToyUniforms::UpdateFPS(timeDelta, averageTimeDelta);
}