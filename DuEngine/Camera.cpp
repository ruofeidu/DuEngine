/**
 * DuRenderer is a basic OpenGL-based renderer which implements most of the
 * ShaderToy functionality Ruofei Du | Augmentarium Lab | UMIACS Computer
 * Science Department | University of Maryland, College Park me [at] duruofei
 * [dot] com 12/6/2017
 */
#include "Camera.h"
#include "stdafx.h"

Camera::Camera() { reset(); }

void Camera::reset() {
  using namespace glm;
  eye = vec3(0.0, 0.0, 1.0);
  up = vec3(0.0, 1.0, 0.0);
  center = vec3(0.0);
}
