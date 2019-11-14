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

#include "stdafx.h"
#include "ShaderToy.h"

vec3 ShaderToyUniforms::iResolution;
float ShaderToyUniforms::iGlobalTime;
int ShaderToyUniforms::iFrame;
vec4 ShaderToyUniforms::iMouse;
vec4 ShaderToyUniforms::iDate;
float ShaderToyUniforms::iTimeDelta = 1000.0f / 60.0f;
int ShaderToyUniforms::iFrameRate = 60;
bool ShaderToyUniforms::MouseDown = false;

ShaderToyUniforms::ShaderToyUniforms(ShaderToyGeometry* geom, int numChannels) {
  reset(geom);
  iChannels = vector<Texture*>(numChannels);
  uChannels = vector<GLint>(numChannels);
  uChannelResolutions = vector<GLint>(numChannels);
  uChannelTimes = vector<GLint>(numChannels);
  iVec2Buffers = vector<GLuint>(numChannels);
  uVec2Buffers = vector<GLint>(numChannels);
}

void ShaderToyUniforms::reset(int _width, int _height) {
  iMouse = vec4(0.0f);
  resetTime();
#if COMPILE_WITH_SH
  lastFrame = -1;
  iNumBands = 4;
#endif
  // z is ratio of pixel shapes:
  // https://shadertoyunofficial.wordpress.com/2016/07/20/special-shadertoy-features/
  iResolution = vec3(_width, _height, 1.0);
}

void ShaderToyUniforms::reset(ShaderToyGeometry* geom) {
  reset((int)geom->geometry[0], (int)geom->geometry[1]);
}

void ShaderToyUniforms::resetTime() {
  using namespace std;
  using namespace std::chrono;
  system_clock::time_point now = system_clock::now();
  time_t tt = system_clock::to_time_t(now);
  // tm utc_tm = *gmtime(&tt);
  tm local_tm = *localtime(&tt);
  secondsOnStart = (float)local_tm.tm_hour * 3600.0f +
                   (float)local_tm.tm_min * 60.0f + (float)local_tm.tm_sec;
  iDate = vec4(local_tm.tm_year + 1900, local_tm.tm_mon, local_tm.tm_mday,
               secondsOnStart);

  startTime = clock();
  resetFrame();
}

void ShaderToyUniforms::resetFrame() {
  iFrame = 0;
  iSkip = SKIP_FIRST_FRAMES;
}

void ShaderToyUniforms::linkShaderProgram(ShaderProgram* shaderProgram) {
  m_program = shaderProgram;
  uGlobalTime = m_program->getUniformLocation("iTime");
  uFrame = m_program->getUniformLocation("iFrame");
  uMouse = m_program->getUniformLocation("iMouse");
  uDate = m_program->getUniformLocation("iDate");
  uResolution = m_program->getUniformLocation("iResolution");
  uFrameRate = m_program->getUniformLocation("iFrameRate");
  uTimeDelta = m_program->getUniformLocation("iTimeDelta");
  for (size_t i = 0; i < iChannels.size(); ++i) {
    uChannels[i] = m_program->getUniformLocation("iChannel" + to_string(i));
    uChannelResolutions[i] = m_program->getUniformLocation(
        "iChannelResolution[" + to_string(i) + "]");
    uChannelTimes[i] =
        m_program->getUniformLocation("iChannelTime[" + to_string(i) + "]");
  }
  for (int i = 0; i < iVec2Buffers.size(); ++i) {
    uVec2Buffers[i] = m_program->getUniformLocation("iVec2" + to_string(i));
  }
#if COMPILE_WITH_SH
  uSHCoefs = m_program->getUniformLocation("vSHCoefs");
  uSph = m_program->getUniformLocation("vSph");
  uNumBands = m_program->getUniformLocation("iNumBands");
  uK = m_program->getUniformLocation("vK");
#endif
  // debug("Linked with shader " + to_string(m_program->getID()));
}

void ShaderToyUniforms::bindTexture(Texture* tex, GLuint channel) {
  if (uChannels[channel] >= 0) {
    iChannels[channel] = tex;
    tex->bindUniform(uChannels[channel]);
  } else {
    warning("Channel " + to_string(channel) + " is not used in the shader.");
  }
}

void ShaderToyUniforms::intVec2Buffers(int numBuffers) {
  vec2_buffers = vector<vector<vec2>>(numBuffers);
}

void ShaderToyUniforms::bindVec2Buffer(GLuint channel, string fileName) {
  auto& buffer = vec2_buffers[channel];

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
    warning("! Vec2 Buffer of channel " + to_string(channel) +
            " is not used in the shader.");
  }
}

void ShaderToyUniforms::update() {
  m_program->use();
  if (iSkip-- < 0) {
    iFrame++;
    iSkip = -1;
  } else {
    iFrame = 0;
    startTime = clock();
  }
  iGlobalTime = float(clock() - startTime) / CLOCKS_PER_SEC;
  iDate.w = secondsOnStart + iGlobalTime;  // being lazy here, suppose that the
                                           // month and day does not change

  // Set(uResolution, iFrame > 0 ? iResolution : vec3(0, 0, 0));
  Set(uResolution, iResolution);
  Set(uGlobalTime, iGlobalTime);
  Set(uTimeDelta, iTimeDelta);
  Set(uFrameRate, iFrameRate);
  Set(uFrameRate, iFrameRate);
  Set(uFrame, iFrame);
  Set(uMouse, iMouse);
  Set(uDate, iDate);

  for (int i = 0; i < iChannels.size(); ++i)
    if (uChannels[i] >= 0) {
      Set(uChannels[i], iChannels[i]);
#if DEBUG_MULTIPASS
      debug("Updated channel " + to_string(i) + " with texture " +
            to_string(iChannels[i]->getTextureID()) + " at location " +
            to_string(uChannels[i]));
#endif
      Set(uChannelResolutions[i], iChannels[i]->getResolution());
      Set(uChannelTimes[i], iGlobalTime);
    }

  for (int i = 0; i < vec2_buffers.size(); ++i) {
    Set(uVec2Buffers[i], vec2_buffers[i][iFrame % vec2_buffers[i].size()]);
  }
}

void ShaderToyUniforms::UpdateFPS(float timeDelta, float averageTimeDelta) {
  iTimeDelta = timeDelta / 1e3f;
  if (averageTimeDelta > 0) iFrameRate = int(1000.0f / averageTimeDelta);
}

void ShaderToyUniforms::updateResolution(int _width, int _height) {
  this->iResolution = vec3(_width, _height, this->iResolution.z);
}

void ShaderToyUniforms::OnMouseMove(float x, float y) {
  if (MouseDown) {
    iMouse.x = x;
    iMouse.y = iResolution.y - y;
  }
}

void ShaderToyUniforms::OnMouseDown(float x, float y) {
  MouseDown = true;
  iMouse.x = x;
  iMouse.y = iResolution.y - y;
  iMouse.z = x;
  iMouse.w = iResolution.y - y;
}

void ShaderToyUniforms::OnMouseUp(float x, float y) {
  MouseDown = false;
  iMouse.x = x;
  iMouse.y = iResolution.y - y;
  iMouse.z = -abs(iMouse.z);
  iMouse.w = -abs(iMouse.w);
}

string ShaderToyUniforms::GetMouseString() {
  return to_string((float)iMouse.x / iResolution.x) + "\t" +
         to_string((float)iMouse.y / iResolution.y);
}

void ShaderToyUniforms::Set(GLint location, Texture* texture) {
  if (location >= 0) {
    texture->bindUniform(location);
  }
}

void ShaderToyUniforms::Set(GLint location, vec4& v) {
  if (location >= 0) {
    glUniform4f(location, v.x, v.y, v.z, v.w);
  }
}

void ShaderToyUniforms::Set(GLint location, vec3& v) {
  if (location >= 0) {
    glUniform3f(location, v.x, v.y, v.z);
  }
}

void ShaderToyUniforms::Set(GLint location, vec2& v) {
  if (location >= 0) {
    glUniform2f(location, v.x, v.y);
  }
}

void ShaderToyUniforms::Set(GLint location, float value) {
  if (location >= 0) {
    glUniform1f(location, value);
  }
}

void ShaderToyUniforms::Set(GLint location, int value) {
  if (location >= 0) {
    glUniform1i(location, value);
  }
}
