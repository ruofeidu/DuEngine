#include "stdafx.h"
#include "Camera.h"

Camera::Camera() {
	reset();
}

void Camera::reset() {
	using namespace glm;
	eye = vec3(0.0, 0.0, 1.0);
	up = vec3(0.0, 1.0, 0.0);
	center = vec3(0.0);
}