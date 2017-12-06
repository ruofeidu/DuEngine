#pragma once
#include <opencv\cv.hpp>
using namespace cv;
using namespace std;

#ifndef HASH_VEC2B
#define HASH_VEC2B
namespace std {
	template <>
	struct hash<Vec2b>
	{
		size_t operator()(Vec2b const & x) const noexcept {
			return x[0] * 256 + x[1];
		}
	};
}
#endif
