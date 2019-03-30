#pragma once
#include "Geometry.h"
#include "stdafx.h"

class ShaderToyGeometry : public Geometry {
 public:
  double geometry[4]; /* width, height, x0, y0 (top left) */

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
