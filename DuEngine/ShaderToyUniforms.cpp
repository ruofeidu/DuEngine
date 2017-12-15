#include "stdafx.h"
#include "ShaderToy.h"

vec3 ShaderToy::ShaderToyUniforms::iResolution;
float ShaderToy::ShaderToyUniforms::iGlobalTime;
int ShaderToy::ShaderToyUniforms::iFrame;
vec4 ShaderToy::ShaderToyUniforms::iMouse;
vec4 ShaderToy::ShaderToyUniforms::iDate;
float ShaderToy::ShaderToyUniforms::iTimeDelta = 1000.0f / 60.0f;
int ShaderToy::ShaderToyUniforms::iFrameRate = 60;


ShaderToy::ShaderToyUniforms::ShaderToyUniforms(ShaderToyGeometry* geom, int numChannels) {
	reset(geom);
	iChannels = vector<Texture*>(numChannels);
	uChannels = vector<GLint>(numChannels);
	uChannelResolutions = vector<GLint>(numChannels);
	uChannelTimes = vector<GLint>(numChannels);
	iVec2Buffers = vector<GLuint>(numChannels);
	uVec2Buffers = vector<GLint>(numChannels);
}

void ShaderToy::ShaderToyUniforms::reset(ShaderToyGeometry* geom) {
	iMouse = vec4(0.0f);
	// z is ratio of pixel shapes: https://shadertoyunofficial.wordpress.com/2016/07/20/special-shadertoy-features/
	iResolution = vec3(geom->geometry[0], geom->geometry[1], 1.0);
	resetTime();
#if COMPILE_WITH_SH
	lastFrame = -1;
	iNumBands = 4;
#endif
}

void ShaderToy::ShaderToyUniforms::resetTime() {
	using namespace std;
	using namespace std::chrono;
	resetFrame();
	system_clock::time_point now = system_clock::now();
	time_t tt = system_clock::to_time_t(now);
	// tm utc_tm = *gmtime(&tt);
	tm local_tm = *localtime(&tt);
	secondsOnStart = (float)local_tm.tm_hour * 3600.0f + (float)local_tm.tm_min * 60.0f + (float)local_tm.tm_sec;
	iDate = vec4(local_tm.tm_year + 1900, local_tm.tm_mon, local_tm.tm_mday, secondsOnStart);

	startTime = clock();
}

void ShaderToy::ShaderToyUniforms::resetFrame() {
	iFrame = 0;
	iSkip = SKIP_FIRST_FRAMES;
}

void ShaderToy::ShaderToyUniforms::linkShader(GLuint shaderProgram) {
	linkedProgram = shaderProgram;
	uGlobalTime = glGetUniformLocation(shaderProgram, "iTime");
	uFrame = glGetUniformLocation(shaderProgram, "iFrame");
	uMouse = glGetUniformLocation(shaderProgram, "iMouse");
	uDate = glGetUniformLocation(shaderProgram, "iDate");
	uResolution = glGetUniformLocation(shaderProgram, "iResolution");
	uFrameRate = glGetUniformLocation(shaderProgram, "iFrameRate");
	uTimeDelta = glGetUniformLocation(shaderProgram, "iTimeDelta");
	for (int i = 0; i < iChannels.size(); ++i) {
		auto uName = "iChannel" + to_string(i);
		uChannels[i] = glGetUniformLocation(shaderProgram, uName.c_str());
		uName = "iChannelResolution[" + to_string(i) + "]";
		uChannelResolutions[i] = glGetUniformLocation(shaderProgram, uName.c_str());
		uName = "iChannelTime[" + to_string(i) + "]";
		uChannelTimes[i] = glGetUniformLocation(shaderProgram, uName.c_str());
	}
	for (int i = 0; i < iVec2Buffers.size(); ++i) {
		auto uName = "iVec2" + to_string(i);
		uVec2Buffers[i] = glGetUniformLocation(shaderProgram, uName.c_str());
	}
#if COMPILE_WITH_SH
	uSHCoefs = glGetUniformLocation(shaderProgram, "vSHCoefs");
	uSph = glGetUniformLocation(shaderProgram, "vSph");
	uNumBands = glGetUniformLocation(shaderProgram, "iNumBands");
	uK = glGetUniformLocation(shaderProgram, "vK");
#endif
	debug("Linked with shader " + to_string(shaderProgram));
}

void ShaderToy::ShaderToyUniforms::bindTexture2D(Texture* tex, GLuint channel) {
	if (uChannels[channel] >= 0) {
		iChannels[channel] = tex;
		auto id = tex->getTextureID();
		glActiveTexture(GL_TEXTURE0 + id);
		glBindTexture(GL_TEXTURE_2D, id);
		glUniform1i(uChannels[channel], id);
	} else {
		warning("Channel " + to_string(channel) + " is not used in the shader.");
	}
}

void ShaderToy::ShaderToyUniforms::intVec2Buffers(int numBuffers) {
	vec2_buffers = vector<vector<vec2>>(numBuffers);
}

void ShaderToy::ShaderToyUniforms::bindVec2Buffer(GLuint channel, string fileName) {
	auto &buffer = vec2_buffers[channel];

	if (uVec2Buffers[channel] >= 0) {
		FILE* file = fopen(fileName.c_str(), "r");
		if (!file) {
			logerror("Cannot open " + fileName);
			return;
		}
		while (!feof(file)) {
			float a, b;
			if (fscanf(file, "%f\t%f", &a, &b) < 2) {
				break;
			}
			buffer.push_back(vec2(a, b));
		}
		fclose(file);
		glUniform2f(uVec2Buffers[channel], buffer[0].x, buffer[0].y);
		info("! Read vec2 buffer " + to_string(buffer.size()));
	} else {
		warning("! Vec2 Buffer of channel " + to_string(channel) + " is not used in the shader.");
	}
}

void ShaderToy::ShaderToyUniforms::update() {
	glUseProgram(linkedProgram);
	if (iSkip-- < 0) {
		iFrame++;
		iSkip = -1;
	} else {
		iFrame = 0;
		startTime = clock();
	}
	iGlobalTime = float(clock() - startTime) / CLOCKS_PER_SEC;
	iDate.w = secondsOnStart + iGlobalTime; // being lazy here, suppose that the month and day does not change
	if (uResolution >= 0) glUniform3f(uResolution, iResolution.x, iResolution.y, iResolution.z);
	if (uGlobalTime >= 0) glUniform1f(uGlobalTime, iGlobalTime);
	if (uTimeDelta >= 0) glUniform1f(uTimeDelta, iTimeDelta);
	if (uFrameRate >= 0) glUniform1i(uFrameRate, iFrameRate);
	if (uFrame >= 0) glUniform1i(uFrame, iFrame);
	if (uMouse >= 0) glUniform4f(uMouse, iMouse.x, iMouse.y, iMouse.z, iMouse.w);
	if (uDate >= 0) glUniform4f(uDate, iDate.x, iDate.y, iDate.z, iDate.w);
	for (int i = 0; i < iChannels.size(); ++i) if (uChannels[i] >= 0) {
		auto id = iChannels[i]->getTextureID();
		glActiveTexture(GL_TEXTURE0 + id);
		glBindTexture(GL_TEXTURE_2D, id);
		glUniform1i(uChannels[i], id);
#if DEBUG_MULTIPASS
		debug("Updated channel " + to_string(i) + " with texture " + to_string(iChannels[i]->getTextureID())
			+ " at location " + to_string(uChannels[i])
			);
#endif		
		if (uChannelResolutions[i] >= 0) {
			auto res = iChannels[i]->getResolution(); 
			glUniform3f(uChannelResolutions[i], res.x, res.y, res.z);
		}
		if (uChannelTimes[i] >= 0) {
			glUniform1f(uChannelTimes[i], iGlobalTime);
		}
	}

	for (int i = 0; i < vec2_buffers.size(); ++i) if (uVec2Buffers[i] >= 0) {
		auto &v2 = vec2_buffers[i][iFrame % vec2_buffers[i].size()];
		glUniform2f(uVec2Buffers[i], v2.x, v2.y);
	}
}

void ShaderToy::ShaderToyUniforms::updateFPS(float timeDelta, float averageTimeDelta) {
	iTimeDelta = timeDelta / 1e3f;
	if (averageTimeDelta > 0)
		iFrameRate = int(1000.0f / averageTimeDelta);
}

void ShaderToy::ShaderToyUniforms::updateResolution(int _width, int _height) {
	this->iResolution = vec3(_width, _height, this->iResolution.z);
}

void ShaderToy::ShaderToyUniforms::onMouseMove(float x, float y) {
	if (mouseDown) {
		iMouse.x = x;
		iMouse.y = iResolution.y - y;
	}
}

void ShaderToy::ShaderToyUniforms::onMouseDown(float x, float y) {
	mouseDown = true;
	iMouse.x = x;
	iMouse.y = iResolution.y - y;
	iMouse.z = x;
	iMouse.w = iResolution.y - y;
}


void ShaderToy::ShaderToyUniforms::onMouseUp(float x, float y) {
	mouseDown = false;
	iMouse.x = x;
	iMouse.y = iResolution.y - y;
	iMouse.z = -abs(iMouse.z);
	iMouse.w = -abs(iMouse.w);
}

string ShaderToy::ShaderToyUniforms::getMouseString() {
	return to_string((float)iMouse.x / iResolution.x) + "\t" + to_string((float)iMouse.y / iResolution.y);
}