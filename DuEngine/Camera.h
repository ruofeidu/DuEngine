#pragma once
#include "stdafx.h"

class Camera
{
public:
	Camera();
	void reset();
	glm::vec3 eye, up, center;

private:
	static Camera *s_Instance;
};
