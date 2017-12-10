#include "stdafx.h"
#include "ShaderToy.h"
#include "DuUtils.h"

ShaderToy::ShaderToy(DuEngine * _renderer, double _width, double _height, int _x0, double _y0) {
	renderer = _renderer;
	geometry = new ShaderToyGeometry(_width, _height, _x0, _y0);
	vertexShader = 0;
	fragmentShader = 0;
	shaderProgram = 0;
	numChannels = 4;
	uniforms = new ShaderToyUniforms(geometry, numChannels);
	
//	auto buffers_count = 

	auto buffers_count = _renderer->config->GetIntWithDefault("buffers_count", 0); 
	for (int i = 0; i < buffers_count; ++i) {
		m_frameBuffers.push_back(ShaderToyFrameBuffer(renderer, geometry, numChannels));
	}
	info("ShaderToy is inited.");
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
	uniforms->iResolution = vec3(_width, _height, uniforms->iResolution.z);
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
	iFrame = 0;
	iMouse = vec4(0.0f);
	// z is ratio of pixel shapes: https://shadertoyunofficial.wordpress.com/2016/07/20/special-shadertoy-features/
	iResolution = vec3(geom->geometry[0], geom->geometry[1], 1.0);
	resetTime();
	lastFrame = -1;
	// 
	iNumBands = 4;
}

void ShaderToy::ShaderToyUniforms::resetTime() {
	using namespace std;
	using namespace std::chrono;
	iFrame = 0;
	system_clock::time_point now = system_clock::now();
	time_t tt = system_clock::to_time_t(now);
	// tm utc_tm = *gmtime(&tt);
	tm local_tm = *localtime(&tt);
	secondsOnStart = (float)local_tm.tm_hour * 3600.0f + (float)local_tm.tm_min * 60.0f + (float)local_tm.tm_sec;
	iDate = vec4(local_tm.tm_year + 1900, local_tm.tm_mon, local_tm.tm_mday, secondsOnStart);

	startTime = clock();
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
}

void ShaderToy::ShaderToyUniforms::bindTexture2D(Texture* tex, GLuint channel) {
	if (uChannels[channel] >= 0) {
		iChannels[channel] = tex; 
		auto id = tex->GetTextureID(); 
		glActiveTexture(GL_TEXTURE0 + id);
		glBindTexture(GL_TEXTURE_2D, id);
		glUniform1i(uChannels[channel], id);
	} else {
		cout << "! Channel " << channel << " is not used in the shader." << endl;
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
			cout << "! Cannot open " + fileName << endl;
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
		std::cout << "* Read vec2 buffer " << buffer.size() << endl;
	} else {
		cout << "! Vec2 Buffer " << channel << " is not used in the shader." << endl;
	}
}

void ShaderToy::ShaderToyUniforms::update() {
	glUseProgram(linkedProgram);
	iFrame++;
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
		glUniform1i(uChannels[i], iChannels[i]->GetTextureID());
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
	//iMouse.z = 0;
	//iMouse.w = 0;
}

string ShaderToy::ShaderToyUniforms::getMouseString() {
	return to_string((float)iMouse.x / iResolution.x) + "\t" + to_string((float)iMouse.y / iResolution.y);
}

void ShaderToy::render() {
	for (auto& frameBuffer : m_frameBuffers) {
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, frameBuffer.getID());
		frameBuffer.render(); 
		// in which we:
		// uniforms->update();
		// geometry->render();
		    // use program
		    // draw the triangles
	}

	glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
	uniforms->update();
	geometry->render();
}

ShaderToy::ShaderToyFrameBuffer::ShaderToyFrameBuffer(DuEngine* _renderer, ShaderToyGeometry* _geometry, int numChannels) {
	renderer = _renderer;
	geometry = _geometry;
	uniforms = new ShaderToyUniforms(_geometry, numChannels);

	glGenFramebuffers(2, FBO);

	for (int i = 0; i < 2; ++i) {
		glBindFramebuffer(GL_FRAMEBUFFER, FBO[i]);
		textures[i] = new FrameBufferTexture(FBO[i], geometry->getWidth(), geometry->getHeight()); 
		info("Mipmap generated for framgebuffer " + to_string(FBO[i]) + ", with texture ID " + to_string(textures[i]->GetTextureID()));
#if COMPILE_CHECK_GL_ERROR
		GLenum err = glGetError();
		if (err != GL_NO_ERROR)
			logerror("Texturing error: " + to_string(err));
#endif
	}
	
	id = 0;
	tex = textures[1 - id];  
}

void ShaderToy::ShaderToyFrameBuffer::loadShaders(string vertexShaderName, string fragShaderName, string uniformShaderName, string mainFileName) {
	vertexShader = renderer->initShaders(GL_VERTEX_SHADER, vertexShaderName);
	fragmentShader = renderer->initShaders(GL_FRAGMENT_SHADER, fragShaderName, uniformShaderName, mainFileName);
	shaderProgram = renderer->initProgram(vertexShader, fragmentShader);
	uniforms->linkShader(shaderProgram);
	debug("Frame buffer load: " + fragShaderName);
}

GLuint ShaderToy::ShaderToyFrameBuffer::getID() {
	return id;
}

void ShaderToy::ShaderToyFrameBuffer::render() {
	uniforms->update();
	geometry->render();

	// passthrough shader ~ glCopyTexSubImage2D > glBlitFramebuffer >> glCopyPixels
	// another approach is to use two FBOs
	//glBindFramebuffer(GL_FRAMEBUFFER, id);
	// update your own texture
	//glActiveTexture(GL_TEXTURE0 + readTexture);
	//glBindTexture(GL_TEXTURE_2D, writeTexture);
	//glCopyTexSubImage2D(readTexture, 0, 0, 0, 0, 0, geometry->getWidth(), geometry->getHeight());
	//glGenerateMipmap(GL_TEXTURE_2D);
	id = 1 - id;
	tex = textures[1 - id];
	debug("Writing frame buffer " + to_string(id) + " and read from frame buffer " + to_string(tex->GetTextureID())); 
}
