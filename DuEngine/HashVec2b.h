/**
 * DuRenderer is a basic OpenGL-based renderer which implements most of the
 * ShaderToy functionality Ruofei Du | Augmentarium Lab | UMIACS Computer
 * Science Department | University of Maryland, College Park me [at] duruofei
 * [dot] com 12/6/2017
 */
#pragma once
#include <opencv\cv.hpp>
using namespace cv;
using namespace std;

#ifndef HASH_VEC2B
#define HASH_VEC2B
namespace std {
template <>
struct hash<Vec2b> {
  size_t operator()(Vec2b const& x) const noexcept { return x[0] * 256 + x[1]; }
};
}  // namespace std
#endif
