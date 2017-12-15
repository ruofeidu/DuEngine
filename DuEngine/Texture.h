#pragma once
#include "stdafx.h"
using namespace glm;
using namespace std;
using namespace cv;

#if DEBUG_TEXTURE_DEPRECATED_FILTERING
enum ETextureFiltering
{
	TEXTURE_FILTER_MAG_NEAREST = 0, // Nearest criterion for magnification
	TEXTURE_FILTER_MAG_BILINEAR, // Bilinear criterion for magnification
	TEXTURE_FILTER_MIN_NEAREST, // Nearest criterion for minification
	TEXTURE_FILTER_MIN_BILINEAR, // Bilinear criterion for minification
	TEXTURE_FILTER_MIN_NEAREST_MIPMAP, // Nearest criterion for minification, but on closest mipmap
	TEXTURE_FILTER_MIN_BILINEAR_MIPMAP, // Bilinear criterion for minification, but on closest mipmap
	TEXTURE_FILTER_MIN_TRILINEAR, // Bilinear criterion for minification on two closest mipmaps, then averaged
};
#endif

enum class TextureFilter : std::int8_t { NEAREST, LINEAR, MIPMAP };
enum class TextureWarp : std::int8_t { CLAMP, REPEAT };
enum class TextureType : std::int8_t { Unknown, RGB, VideoFile, VideoSequence, Keyboard, Font, SH, FrameBuffer, Volume, LightField };

class Texture
{
public:
	static TextureType QueryType(string str);
	static TextureFilter QueryFilter(string str);
	static TextureWarp QueryWarp(string str);
	const static unordered_map<string, TextureType> TextureMaps;
	const static unordered_map<string, string> ImageTextures;
	const static unordered_map<string, string> VideoTextures;
	const static unordered_map<string, string> FontTextures;

public:
	Texture() {};
	// Acquire the current texture unit id for reading and binding to shader uniforms
	GLuint getTextureID();
	// Acquire the binded texture unit id
	GLuint getDirectID();
	// Acquire the texture type
	TextureType getType();

protected:
	TextureType type = TextureType::Unknown;
	// The binded texture id
	GLuint id = 0;
	// The texture id for reading
	GLuint read_texture_id = 0;

	TextureFilter m_filter = TextureFilter::LINEAR;
	TextureWarp m_warp = TextureWarp::REPEAT;

	// Generate, active, bind, and set filtering, all in one!
	void genTexture2D();

	// Check filtering and generate mipmaps
	void generateMipmaps();

	// Setup filtering based on the two protected parameters, m_filter and m_warp
	void setFiltering();

private:
	GLenum m_minFilter = GL_LINEAR, m_magFilter = GL_LINEAR, m_wrapFilter = GL_CLAMP;
#if DEBUG_TEXTURE_DEPRECATED_FILTERING
private:
	GLuint m_sampler; 
	// deprecated("Not using it")
	void setFiltering(int a_tfMagnification, int a_tfMinification);
#endif
};
