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

#include "stdafx.h"
#include "ShaderToyGeometry.h"

#ifndef kUseTextureCoordinates
#define kUseTextureCoordinates 0
#endif

ShaderToyGeometry::ShaderToyGeometry(double _width, double _height, double _x0,
                                     double _y0) {
  reset(_width, _height, _x0, _y0);

  GLuint vertexLength = sizeof(vertexBuffer);

  layoutPosition = 0;
  layoutTexCoord = 1;
  layoutFragCoord = 2;

  glGenBuffers(1, &VBO);
  const float scale = 2.0f;
  const float v = 0.5f * scale;
  vertexBuffer[0] = Vertex(vec3(v, v, 0.0f));
  vertexBuffer[1] = Vertex(vec3(-v, v, 0.0f));
  vertexBuffer[2] = Vertex(vec3(-v, -v, 0.0f));
  vertexBuffer[3] = Vertex(vec3(v, -v, 0.0f));

  glGenBuffers(1, &EBO);
  elements[0] = 0;
  elements[1] = 1;
  elements[2] = 3;
  elements[3] = 1;
  elements[4] = 2;
  elements[5] = 3;

  glGenBuffers(1, &VBO);
  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  glBufferData(GL_ARRAY_BUFFER, vertexLength, vertexBuffer, GL_STATIC_DRAW);

  glGenVertexArrays(1, &VAO);
  glBindVertexArray(VAO);
  glEnableVertexAttribArray(layoutPosition);
  glVertexAttribPointer(/*attribute_index=*/layoutPosition,
                        /*number_of_components_per_vertex=*/3,
                        /*type=*/GL_FLOAT,
                        /*normalized=*/GL_FALSE,
                        /*stride=*/sizeof(Vertex),
                        /*offset=*/nullptr);

#if kUseTextureCoordinates
  glEnableVertexAttribArray(layoutTexCoord);
  glVertexAttribPointer(layoutTexCoord, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex),
                        (void*)(sizeof(vec3)));
#endif

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(elements), elements,
               GL_STATIC_DRAW);
}

void ShaderToyGeometry::reset(double _width, double _height) {
  geometry[0] = _width;
  geometry[1] = _height;
}

void ShaderToyGeometry::reset(double _width, double _height, double _x0,
                              double _y0) {
  geometry[0] = _width;
  geometry[1] = _height;
  geometry[2] = _x0;
  geometry[3] = _y0;
}

void ShaderToyGeometry::render() {
  glBindVertexArray(VAO);
  glDrawElements(GL_TRIANGLES, /*count=*/6, GL_UNSIGNED_INT, /*offset=*/0);
}
