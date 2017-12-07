#include "stdafx.h"
#include "DuEngine.h"
using namespace std;
using namespace cv;

void DuEngine::initScene() {
	clock_t begin_time = clock();

	shadertoy = new ShaderToy(DuEngine::GetInstance());

	auto vertexShaderName = config->GetStringWithDefault("shader_vert", m_relativePath + "shadertoy.vert.glsl");
	auto fragmentShaderName = config->GetStringWithDefault("shader_frag", m_relativePath + "shadertoy.default.glsl");
	auto uniformShaderName = config->GetStringWithDefault("shader_uniform", m_relativePath + "shadertoy.uniforms.glsl");
	auto mainShaderName = config->GetStringWithDefault("shader_main", m_relativePath + "shadertoy.main.glsl");
	if (fragmentShaderName.find("$Name") != string::npos) {
		fragmentShaderName.replace(fragmentShaderName.find("$Name"), 5, m_sceneName); 
	}
	shadertoy->loadShaders(vertexShaderName, fragmentShaderName, uniformShaderName, mainShaderName);

	auto channels_count = config->GetIntWithDefault("channels_count", 0);
	for (int i = 0; i < channels_count; ++i) {
		string s = "iChannel" + to_string(i) + "_type";
		auto type = config->GetStringWithDefault(s, "rgb");
		s = "iChannel" + to_string(i) + "_tex";
		auto fileName = config->GetStringWithDefault(s, "");
		cout << fileName << endl;
		s = "iChannel" + to_string(i) + "_mm";
		auto filter = config->GetStringWithDefault(s, "linear");

		if (!type.compare("rgb")) {
			auto t = filter == "mipmap" ? new Texture(fileName, true, TextureFilter::MIPMAP, TextureWrap::REPEAT) : new Texture(fileName);
			shadertoy->uniforms->bindTexture2D(t->id, i);
		} else
		if (!type.compare("video")) {
			auto t = new VideoTexture(fileName);
			videoTextures.push_back(t);
			shadertoy->uniforms->bindTexture2D(t->GetTextureID(), i);
		} else
		if (!type.compare("key")) {
			if (!keyboardTexture) {
				keyboardTexture = new KeyboardTexture();
			}
			shadertoy->uniforms->bindTexture2D(keyboardTexture->GetTextureID(), i);
		} else
		if (!type.compare("font")) {
			if (!fontTexture) {
				fontTexture = new Texture(m_relativePath + "presets/tex21.png", true, TextureFilter::MIPMAP, TextureWrap::REPEAT);
			}
			shadertoy->uniforms->bindTexture2D(fontTexture->GetTextureID(), i);
		}
	}

	auto vec2_buffers_count = config->GetIntWithDefault("vec2_buffers_count", 0);
	shadertoy->uniforms->intVec2Buffers(vec2_buffers_count);

	for (int i = 0; i < vec2_buffers_count; ++i) {
		string s = "vec2_buffers" + to_string(i) + "_file";
		auto fileName = config->GetString(s);
		shadertoy->uniforms->bindVec2Buffer(i, fileName);
	}

	std::cout << "* Initialization scene costs: " << float(clock() - begin_time) / CLOCKS_PER_SEC << " s" << std::endl;
}

int DuEngine::getFrameNumber() {
	return this->shadertoy->uniforms->iFrame;
}

void DuEngine::render() {
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(-1, 1, -1, 1, -1, 1);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	for (int i = 0; i < videoTextures.size(); ++i) videoTextures[i]->update();
	shadertoy->uniforms->update(getNumFrameFromVideos());

	shadertoy->render();
	glutSwapBuffers();

	glutPostRedisplay();


	if (m_recording && m_recordStart + 1 <= getFrameNumber() && getFrameNumber() <= m_recordEnd + 1) {
		this->takeScreenshot(m_recordPath);
	}
	// glutTimerFunc(40, g_timer, 0);
}

void DuEngine::takeScreenshot(string folderName) {
	if (m_is_created.find(folderName) == m_is_created.end()) {
		CreateDirectory(folderName.c_str(), NULL);
		m_is_created.insert(folderName); 
	}
	cv::Mat img(window->height, window->width, CV_8UC3);
	glPixelStorei(GL_PACK_ALIGNMENT, (img.step & 3) ? 1 : 4);
	glPixelStorei(GL_PACK_ROW_LENGTH, (GLint)img.step / (GLint)img.elemSize());
	glReadPixels(0, 0, img.cols, img.rows, GL_BGR_EXT, GL_UNSIGNED_BYTE, img.data);
	flip(img, img, 0);
	//auto t = std::time(nullptr);
	//auto tm = *std::localtime(&t);
	//std::ostringstream oss;
	//oss << std::put_time(&tm, "%d-%m-%Y_%H-%M-%S");
	//auto str = oss.str();
	cv::imwrite(folderName + "/" + this->configName.substr(0, configName.size() - 4) + "_" + to_string(getFrameNumber()) + ".png", img);
}

