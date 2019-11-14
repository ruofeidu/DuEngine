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

#pragma once
#include "stdafx.h"
using namespace glm;
using namespace std;
using namespace cv;

#if DEBUG_TEXTURE_DEPRECATED_FILTERING
enum ETextureFiltering {
  TEXTURE_FILTER_MAG_NEAREST = 0,     // Nearest criterion for magnification
  TEXTURE_FILTER_MAG_BILINEAR,        // Bilinear criterion for magnification
  TEXTURE_FILTER_MIN_NEAREST,         // Nearest criterion for minification
  TEXTURE_FILTER_MIN_BILINEAR,        // Bilinear criterion for minification
  TEXTURE_FILTER_MIN_NEAREST_MIPMAP,  // Nearest criterion for minification, but
                                      // on closest mipmap
  TEXTURE_FILTER_MIN_BILINEAR_MIPMAP,  // Bilinear criterion for minification,
                                       // but on closest mipmap
  TEXTURE_FILTER_MIN_TRILINEAR,  // Bilinear criterion for minification on two
                                 // closest mipmaps, then averaged
};
#endif

enum class TextureFilter : std::int8_t { NEAREST, LINEAR, MIPMAP };
enum class TextureWarp : std::int8_t { CLAMP, REPEAT };
enum class TextureType : std::int8_t {
  Unknown,
  RGB,
  Noise,
  VideoFile,
  VideoSequence,
  Keyboard,
  Font,
  SH,
  FrameBuffer,
  Volume,
  Bin3D,
  LightField,
  CubeMap,
  Camera,
  Sound
};

class Texture {
 public:
  static TextureType QueryType(string str);
  static TextureFilter QueryFilter(string str);
  static TextureWarp QueryWarp(string str);
  // replace the predefined textures into the real file names
  static void QueryFileNameByType(string& type, string& fileName,
                                  string& presetsPath);
  // get sampler2D / samplerCube / sampler3D depending on the types
  static string QuerySampler(TextureType type);
  // mapping type stringss to TextureType
  const static unordered_map<string, TextureType> TextureMaps;
  // mapping strings to filenames of various sorts of textures
  const static unordered_map<string, string> ImageTextures;
  const static unordered_map<string, string> CubeMapTextures;
  const static unordered_map<string, string> VolumeTextures;
  const static unordered_map<string, string> Bin3DTextures;
  const static unordered_map<string, string> NoiseTextures;
  const static unordered_map<string, string> VideoTextures;
  const static unordered_map<string, string> FontTextures;
  const static unordered_map<string, string> CameraTextures;
  const static unordered_map<string, string> SoundTextures;

 public:
  Texture(){};
  // Acquire the current texture unit id for reading and binding to shader
  // uniforms
  GLuint getTextureID();
  // Acquire the OpenGL texture type
  GLenum getGLType();
  // Acquire the binded texture unit id
  GLuint getDirectID();
  // Acquire resolution of the binded texture
  virtual vec3 getResolution() = 0;
  // Acquire the texture type
  TextureType getType();
  // Activate and bind
  void bindUniform(int uniformId);

 protected:
  TextureType type = TextureType::Unknown;
  // The binded texture id
  GLuint id = 0;
  // The texture id for reading
  GLuint read_texture_id = 0;
  // Type of texture, GL_TEXTURE_2D by default
  GLenum m_glType = GL_TEXTURE_2D;

  TextureFilter m_filter = TextureFilter::LINEAR;
  TextureWarp m_warp = TextureWarp::REPEAT;

  // Generate, active, bind, and set filtering, all in one!
  void genTexture2D();

  // Check filtering and generate mipmaps
  void generateMipmaps();

  // Setup filtering based on the two protected parameters, m_filter and m_warp
  void setFiltering();

 private:
  GLenum m_minFilter = GL_LINEAR, m_magFilter = GL_LINEAR,
         m_wrapFilter = GL_CLAMP;
#if DEBUG_TEXTURE_DEPRECATED_FILTERING
 private:
  GLuint m_sampler;
  // deprecated("Not using it")
  void setFiltering(int a_tfMagnification, int a_tfMinification);
#endif
};
