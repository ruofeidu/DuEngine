#pragma once
#include "TextureMat.h"

class Texture3D : public Texture
{
public:
	Texture3D() {};
	Texture3D(string filename, bool vflip = true, TextureFilter filter = TextureFilter::LINEAR, TextureWarp warp = TextureWarp::REPEAT);
	vec3 getResolution();

private:
	vector<unsigned char> m_volume;
	int m_resolution[4];
	GLuint m_openGLFormat = GL_RGBA;
	GLuint m_format = GL_BGRA;
	GLuint m_dataType = GL_UNSIGNED_BYTE;
};
