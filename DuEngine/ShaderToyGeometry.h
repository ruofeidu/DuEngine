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
#include "Geometry.h"
#include "stdafx.h"

class ShaderToyGeometry : public Geometry {
 public:
  // Width, height, x0, y0 (top left).
  double geometry[4];

 public:
  GLuint VBO;
  GLuint VAO;
  GLuint EBO;
  GLuint FBO;
  GLuint layoutPosition, layoutTexCoord, layoutFragCoord;
  Vertex vertexBuffer[4];
  GLuint elements[6];

  ShaderToyGeometry(double _width, double _height, double _x0, double _y0);

  void reset(double _width, double _height);

  void reset(double _width, double _height, double _x0, double _y0);

  void render();

 public:
  int getWidth() const { return (int)geometry[0]; }
  int getHeight() const { return (int)geometry[1]; }
};
