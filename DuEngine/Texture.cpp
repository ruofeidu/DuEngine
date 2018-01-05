/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
* 12/6/2017
*/
#include "stdafx.h"
#include "Texture.h"
#include "DuEngine.h"
#include "DuUtils.h"

GLuint Texture::getTextureID() {
	if (type == TextureType::FrameBuffer) {
		return this->read_texture_id;
	}
	return this->id;
}

GLenum Texture::getGLType() {
	return m_glType; 
}

GLuint Texture::getDirectID() {
	return read_texture_id;
}


TextureType Texture::getType() {
	return type;
}

void Texture::bindUniform(int uniformId) {
	auto id = this->getTextureID();
	glActiveTexture(GL_TEXTURE0 + id);
	glBindTexture(m_glType, id);
	glUniform1i(uniformId, id);
}

TextureType Texture::QueryType(string str) {
	auto res = Texture::TextureMaps.find(str);
	if (res != Texture::TextureMaps.end()) {
		return res->second;
	}
	return TextureType::Unknown;
}

TextureFilter Texture::QueryFilter(string filter) {
	return filter == "linear" ? TextureFilter::LINEAR : ((filter == "nearest") ? TextureFilter::NEAREST : TextureFilter::MIPMAP);
}

TextureWarp Texture::QueryWarp(string wrap) {
	return !wrap.compare("repeat") ? TextureWarp::REPEAT : TextureWarp::CLAMP;
}

void Texture::QueryFileNameByType(string & type, string & fileName, string& presetsPath) {
	for (const auto& key : Texture::ImageTextures) {
		if (!type.compare(key.first)) {
			type = "rgb";
			fileName = presetsPath + key.second;
			break;
		}
	}
	for (const auto& key : Texture::NoiseTextures) {
		if (!type.compare(key.first)) {
			type = "noise";
			fileName = presetsPath + key.second;
			break;
		}
	}
	for (const auto& key : Texture::VideoTextures) {
		if (!type.compare(key.first)) {
			type = "video";
			fileName = presetsPath + key.second;
			break;
		}
	}
	for (const auto& key : Texture::CubeMapTextures) {
		if (!type.compare(key.first)) {
			type = "cubemap";
			fileName = presetsPath + key.second;
			break;
		}
	}
	for (const auto& key : Texture::VolumeTextures) {
		if (!type.compare(key.first)) {
			type = "volume";
			fileName = presetsPath + key.second;
			break;
		}
	}
}

string Texture::QuerySampler(TextureType type) {
	string sampler = "sampler2D";
	switch (type) {
	case TextureType::CubeMap:
		sampler = "samplerCube";
		break;
	}
	return sampler; 
}


const unordered_map<string, TextureType> Texture::TextureMaps {
	{ "rgb", TextureType::RGB },
	{ "noise", TextureType::Noise },
	{ "cubemap", TextureType::CubeMap },
	{ "video", TextureType::VideoFile },
	{ "videoseq", TextureType::VideoSequence },
	{ "key", TextureType::Keyboard },
	{ "sh", TextureType::SH },
	{ "font", TextureType::Font },
	{ "a", TextureType::FrameBuffer },
	{ "b", TextureType::FrameBuffer },
	{ "c", TextureType::FrameBuffer },
	{ "d", TextureType::FrameBuffer },
	{ "e", TextureType::FrameBuffer },
	{ "f", TextureType::FrameBuffer },
	{ "g", TextureType::FrameBuffer },
	{ "volume", TextureType::Volume },
	{ "light", TextureType::LightField },
};

const unordered_map<string, string> Texture::ImageTextures {
	{ "pano", "panorama.png" },
	{ "panohd", "pano.png" },
	{ "abstract1", "tex07.jpg" },
	{ "abstract2", "tex08.jpg" },
	{ "abstract3", "tex20.jpg" },
	{ "bayer", "tex15.png" },
	{ "lichen", "tex06.png" },
	{ "london", "tex04.jpg" },
	{ "nyancat", "tex14.png" },
	{ "organic1", "tex01.jpg" },
	{ "organic2", "tex03.jpg" },
	{ "organic3", "tex18.jpg" },
	{ "organic4", "tex17.jpg" },
	{ "pebbles", "tex19.png" },
	{ "rocktiles", "tex00.jpg" },
	{ "rustymetal", "tex02.jpg" },
	{ "stars", "tex03.jpg" },
	{ "wood", "tex05.jpg" },
	{ "sjtu", "sjtu.jpg" },
	{ "starr", "starr.jpg" },
	{ "720p", "720p.jpg" },
	{ "1080p", "1080p.jpg" },
	{ "4k", "4k.jpg" },
	{ "6k", "6k.jpg" },
	{ "8k", "8k.jpg" },
	{ "black", "black.jpg" }
};

const unordered_map<string, string> Texture::CubeMapTextures{
	{ "forest", "cube04_0.png" },
	{ "forestb", "cube05_0.png" },
	{ "stpeter", "cube02_0.jpg" },
	{ "stpeterb", "cube03_0.png" },
	{ "basilica", "cube02_0.jpg" },
	{ "basilicab", "cube03_0.png" },
	{ "uffizi", "cube00_0.jpg" },
	{ "uffizib", "cube01_0.png" },
	{ "gallery", "cube00_0.jpg" },
	{ "galleryb", "cube01_0.png" },
};

const unordered_map<string, string> Texture::VolumeTextures{
	{ "noise3d", "noise3d.bin" },
};
const unordered_map<string, string> Texture::NoiseTextures{
	{ "gnm", "tex12.png" },
	{ "greynoise", "tex12.png" },
	{ "graynoise", "tex12.png" },
	{ "gns", "tex10.png" },
	{ "rgbanm", "tex16.png" },
	{ "noise", "tex16.png" },
	{ "rgbans", "tex11.png" },
};


const unordered_map<string, string> Texture::VideoTextures {
	{ "1961", "vid02.ogv" },
	{ "google", "vid00.ogv" },
	{ "claude", "vid03.webm" },
	{ "claudevan", "vid03.webm" },
	{ "britney", "vid01.webm" },
	{ "britneyspears", "vid01.webm" },
};

const unordered_map<string, string> Texture::FontTextures{
	{ "font", "tex21.png" },
};

void Texture::setFiltering() {
	//glGenSamplers(1, &sampler);
	m_wrapFilter = (m_warp == TextureWarp::REPEAT) ? GL_REPEAT : ((m_glType == GL_TEXTURE_CUBE_MAP) ? GL_CLAMP_TO_EDGE : GL_CLAMP);
	switch (m_filter) {
	case TextureFilter::NEAREST:
		m_minFilter = GL_NEAREST;
		m_magFilter = GL_NEAREST;
		//setFiltering(TEXTURE_FILTER_MAG_NEAREST, TEXTURE_FILTER_MIN_NEAREST);
		break;
	case TextureFilter::LINEAR:
		m_minFilter = GL_LINEAR;
		m_magFilter = GL_LINEAR;
		//setFiltering(TEXTURE_FILTER_MAG_BILINEAR, TEXTURE_FILTER_MIN_NEAREST_MIPMAP);
		break;
	case TextureFilter::MIPMAP:
		m_minFilter = GL_LINEAR_MIPMAP_LINEAR;
		m_magFilter = GL_LINEAR;
		//setFiltering(TEXTURE_FILTER_MAG_BILINEAR, TEXTURE_FILTER_MIN_TRILINEAR);
		break;
	}

#if COMPILE_CHECK_GL_ERROR
	// Catch silly-mistake texture interpolation method for magnification
	if (m_magFilter == GL_LINEAR_MIPMAP_LINEAR ||
		m_magFilter == GL_LINEAR_MIPMAP_NEAREST ||
		m_magFilter == GL_NEAREST_MIPMAP_LINEAR ||
		m_magFilter == GL_NEAREST_MIPMAP_NEAREST) {
		warning("! You can't use MIPMAPs for magnification - setting filter to GL_LINEAR");
		m_magFilter = GL_LINEAR;
	}
#endif
	// Set texture interpolation methods for minification and magnification
	glTexParameteri(m_glType, GL_TEXTURE_MIN_FILTER, m_minFilter);
	glTexParameteri(m_glType, GL_TEXTURE_MAG_FILTER, m_magFilter);

	// Set texture clamping methodw
	glTexParameteri(m_glType, GL_TEXTURE_WRAP_S, m_wrapFilter);
	glTexParameteri(m_glType, GL_TEXTURE_WRAP_T, m_wrapFilter);
	if (m_glType == GL_TEXTURE_CUBE_MAP)
		glTexParameteri(m_glType, GL_TEXTURE_WRAP_R, m_wrapFilter);
}

void Texture::genTexture2D() {
	// Generate a number for our textureID's unique handle
	glGenTextures(1, &id);

	// Active the texture object
	glActiveTexture(GL_TEXTURE0 + id);

	// Bind to our texture handle
	glBindTexture(m_glType, id);

	this->setFiltering();
}

void Texture::generateMipmaps() {
	// If we're using mipmaps then generate them. Note: This requires OpenGL 3.0 or higher	   
	if (m_filter == TextureFilter::MIPMAP) {
		glGenerateMipmap(m_glType);
#if VERBOSE_OUTPUT
		info("Mipmap generated for texture" + id);
#endif
	}

#if COMPILE_CHECK_GL_ERROR
	// Check texturing errors.
	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
		logerror("Texturing error: " + to_string(err));
#endif
}

#if DEBUG_TEXTURE_DEPRECATED_FILTERING
void Texture::setFiltering(int a_tfMagnification, int a_tfMinification) {
	// Set magnification filter
	if (a_tfMagnification == TEXTURE_FILTER_MAG_NEAREST)
		glSamplerParameteri(m_sampler, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	else if (a_tfMagnification == TEXTURE_FILTER_MAG_BILINEAR)
		glSamplerParameteri(m_sampler, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	// Set minification filter
	if (a_tfMinification == TEXTURE_FILTER_MIN_NEAREST)
		glSamplerParameteri(m_sampler, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	else if (a_tfMinification == TEXTURE_FILTER_MIN_BILINEAR)
		glSamplerParameteri(m_sampler, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	else if (a_tfMinification == TEXTURE_FILTER_MIN_NEAREST_MIPMAP)
		glSamplerParameteri(m_sampler, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
	else if (a_tfMinification == TEXTURE_FILTER_MIN_BILINEAR_MIPMAP)
		glSamplerParameteri(m_sampler, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
	else if (a_tfMinification == TEXTURE_FILTER_MIN_TRILINEAR)
		glSamplerParameteri(m_sampler, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
}
#endif
