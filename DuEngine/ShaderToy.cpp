#include "stdafx.h"
#include "ShaderToy.h"
#include "DuUtils.h"

ShaderToy::ShaderToy(DuEngine * _renderer, double _width, double _height, int _x0, double _y0) {
	renderer = _renderer;
	geometry = new ShaderToyGeometry(_width, _height, _x0, _y0);
	vertexShader = 0;
	fragmentShader = 0;
	shaderProgram = 0;
	numChannels = _renderer->config->GetIntWithDefault("channels_count", 0);
	uniforms = new ShaderToyUniforms(geometry, numChannels);
	auto buffers_count = _renderer->config->GetIntWithDefault("buffers_count", 0); 
	for (int i = 0; i < buffers_count; ++i) {
		auto prefix = string(1, char('A' + i));
		m_frameBuffers.push_back(new ShaderToyFrameBuffer(renderer, geometry, _renderer->config->GetIntWithDefault(prefix + "_channels_count", 0)));
	}
#if VERBOSE_OUTPUT
	info("ShaderToy is inited.");
#endif
}

ShaderToy::ShaderToy(DuEngine * _renderer) : ShaderToy(_renderer, _renderer->window->width, _renderer->window->height, 0, 0) {
}

void ShaderToy::loadShaders(string vertexShaderName, string fragShaderName, string uniformShaderName, string mainFileName = "") {
	vertexShader = renderer->initShaders(GL_VERTEX_SHADER, vertexShaderName);
	fragmentShader = renderer->initShaders(GL_FRAGMENT_SHADER, fragShaderName, uniformShaderName, mainFileName);
	shaderProgram = renderer->initProgram(vertexShader, fragmentShader);
	uniforms->linkShader(shaderProgram);
	debug("Main buffer load: " + fragShaderName); 
}

void ShaderToy::setTexture2D(cv::Mat &mat, GLuint channel) {

}

void ShaderToy::reshape(int _width, int _height) {
	uniforms->updateResolution(_width, _height); 
	uniforms->resetFrame();

	for (auto& frameBuffer : m_frameBuffers) {
		frameBuffer->reshape(_width, _height); 
	}
}

ShaderToy::ShaderToyGeometry::ShaderToyGeometry(double _width, double _height, double _x0, double _y0) {
	reset(_width, _height, _x0, _y0);

	GLuint posLength = sizeof(vertexBuffer);

	layoutPosition = 0;
	layoutTexCoord = 1;
	layoutFragCoord = 2;

	int scale = 2;
	glGenBuffers(1, &VBO);
	vertexBuffer[0] = Vertex(vec3(0.5f * scale, 0.5f * scale, 0.0f));
	vertexBuffer[1] = Vertex(vec3(-0.5f * scale, 0.5f * scale, 0.0f));
	vertexBuffer[2] = Vertex(vec3(-0.5f * scale, -0.5f * scale, 0.0f));
	vertexBuffer[3] = Vertex(vec3(0.5f * scale, -0.5f * scale, 0.0f));

	glGenBuffers(1, &EBO);
	elements[0] = 0;	elements[1] = 1;	elements[2] = 3;
	elements[3] = 1;	elements[4] = 2;	elements[5] = 3;

	glGenBuffers(1, &VBO);
	glBindBuffer(GL_ARRAY_BUFFER, VBO);
	glBufferData(GL_ARRAY_BUFFER, posLength, vertexBuffer, GL_STATIC_DRAW);

	glGenVertexArrays(1, &VAO);
	glBindVertexArray(VAO);
	glEnableVertexAttribArray(layoutPosition);
	glVertexAttribPointer(layoutPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), NULL);
	//glEnableVertexAttribArray(layoutTexCoord);
	//glVertexAttribPointer(layoutTexCoord, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void*)(sizeof(vec3)));

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(elements), elements, GL_STATIC_DRAW);
}

void ShaderToy::ShaderToyGeometry::reset(double _width, double _height) {
	geometry[0] = _width;
	geometry[1] = _height;
}

void ShaderToy::ShaderToyGeometry::reset(double _width, double _height, double _x0, double _y0) {
	geometry[0] = _width;
	geometry[1] = _height;
	geometry[2] = _x0;
	geometry[3] = _y0;
}

void ShaderToy::ShaderToyGeometry::render() {
	glBindVertexArray(VAO);
	glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
}

ShaderToy::ShaderToyUniforms::ShaderToyUniforms(ShaderToyGeometry* geom, int numChannels) {
	reset(geom);
	iChannels = vector<Texture*>(numChannels);
	uChannels = vector<GLint>(numChannels);
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
		string uName = "iChannel" + to_string(i);
		uChannels[i] = glGetUniformLocation(shaderProgram, uName.c_str());
	}
	for (int i = 0; i < iVec2Buffers.size(); ++i) {
		string uName = "iVec2" + to_string(i);
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
		auto id = tex->GetTextureID();
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
		auto id = iChannels[i]->GetTextureID();
		glActiveTexture(GL_TEXTURE0 + id); 
		glBindTexture(GL_TEXTURE_2D, id);
		glUniform1i(uChannels[i], id);
#if DEBUG_MULTIPASS
		debug("Updated channel " + to_string(i) + " with texture " + to_string(iChannels[i]->GetTextureID())
			+ " at location " + to_string(uChannels[i])
			); 
#endif
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

void ShaderToy::render() {
	for (auto& frameBuffer : m_frameBuffers) {
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, frameBuffer->getID());
		frameBuffer->render();
	}

	for (auto& frameBuffer : m_frameBuffers) {
		frameBuffer->swapTextures();
	}

	glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
	uniforms->update();

#if DEBUG_MULTIPASS
	glUniform1i(uniforms->uChannels[this->renderer->config->GetIntWithDefault("debug_channel", 2)], this->renderer->config->GetIntWithDefault("debug_channel_val", 6));
#endif
	geometry->render();
}

ShaderToy::ShaderToyFrameBuffer::ShaderToyFrameBuffer(DuEngine* _renderer, ShaderToyGeometry* _geometry, int numChannels) {
	renderer = _renderer;
	geometry = _geometry;
	uniforms = new ShaderToyUniforms(_geometry, numChannels);

	for (int i = 0; i < 2; ++i) {
		glGenFramebuffers(1, &FBO[i]);
		glBindFramebuffer(GL_FRAMEBUFFER, FBO[i]);
		textures[i] = new FrameBufferTexture(FBO[i], geometry->getWidth(), geometry->getHeight()); 
	}

	id = 0;
	tex = textures[1 - id];  
}

void ShaderToy::ShaderToyFrameBuffer::loadShaders(string vertexShaderName, string fragShaderName, string uniformShaderName, string mainFileName) {
	vertexShader = renderer->initShaders(GL_VERTEX_SHADER, vertexShaderName);
	fragmentShader = renderer->initShaders(GL_FRAGMENT_SHADER, fragShaderName, uniformShaderName, mainFileName);
	shaderProgram = renderer->initProgram(vertexShader, fragmentShader);
	uniforms->linkShader(shaderProgram);
#if VERBOSE_OUTPUT
	debug("Frame buffer loaded: " + fragShaderName);
#endif
}

GLuint ShaderToy::ShaderToyFrameBuffer::getID() {
	return FBO[id];
}

GLuint ShaderToy::ShaderToyFrameBuffer::getTextureID() {
	return this->tex->GetTextureID();
}

Texture* ShaderToy::ShaderToyFrameBuffer::getTexture() {
	return this->tex;
}

void ShaderToy::ShaderToyFrameBuffer::render() {
	uniforms->update();
	geometry->render();

#if DEBUG_MULTIPASS
	debug("Writing frame buffer " + to_string(getID()) + " and read from texture " + to_string(getTextureID())); 
#endif
	//swapTextures();
}

void ShaderToy::ShaderToyFrameBuffer::swapTextures() {
	id = 1 - id;
	tex = textures[1 - id];
	for (int i = 0; i < 2; ++i) {
		textures[i]->setReadingTextureID(tex->GetDirectID());
	}
}

void ShaderToy::ShaderToyFrameBuffer::reshape(int _width, int _height) {
	for (int i = 0; i < 2; ++i) {
		glBindFramebuffer(GL_FRAMEBUFFER, FBO[i]);
		glViewport(0, 0, _width, _height);
		textures[i]->reshape(_width, _height);
	}
	this->uniforms->updateResolution(_width, _height);
	this->uniforms->resetFrame();
}

