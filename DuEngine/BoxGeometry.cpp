#include "BoxGeometry.h"
#include "stdafx.h"

BoxGeometry::BoxGeometry(double _width, double _height, double _x0,
                         double _y0) {
  reset(_width, _height, _x0, _y0);

  GLuint vertexLength = sizeof(vertexBuffer);

  layoutPosition = 0;
  layoutTexCoord = 1;
  layoutFragCoord = 2;

  glGenBuffers(1, &VBO);

  const float scale = 1.0f;
  const float v = 0.5f * scale;
  vertexBuffer[0] = Vertex(vec3(v, v, v));
  vertexBuffer[1] = Vertex(vec3(v, v, -v));
  vertexBuffer[2] = Vertex(vec3(v, -v, v));
  vertexBuffer[3] = Vertex(vec3(v, -v, -v));
  vertexBuffer[4] = Vertex(vec3(-v, v, -v));
  vertexBuffer[5] = Vertex(vec3(-v, v, v));
  vertexBuffer[6] = Vertex(vec3(-v, -v, -v));
  vertexBuffer[7] = Vertex(vec3(-v, -v, v));

  glGenBuffers(1, &EBO);
  elements[0] = 0;
  elements[1] = 2;
  elements[2] = 1;
  elements[3] = 2;
  elements[4] = 3;
  elements[5] = 1;
  elements[6] = 4;
  elements[7] = 6;
  elements[8] = 5;
  elements[9] = 6;
  elements[10] = 7;
  elements[11] = 5;
  elements[12] = 4;
  elements[13] = 5;
  elements[14] = 1;
  elements[15] = 5;
  elements[16] = 0;
  elements[17] = 1;
  elements[18] = 7;
  elements[19] = 6;
  elements[20] = 2;
  elements[21] = 6;
  elements[22] = 3;
  elements[23] = 2;
  elements[24] = 5;
  elements[25] = 7;
  elements[26] = 0;
  elements[27] = 7;
  elements[28] = 2;
  elements[29] = 0;
  elements[30] = 1;
  elements[31] = 3;
  elements[32] = 4;
  elements[33] = 3;
  elements[34] = 6;
  elements[35] = 4;

  glGenBuffers(1, &VBO);
  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  glBufferData(GL_ARRAY_BUFFER, vertexLength, vertexBuffer, GL_STATIC_DRAW);

  glGenVertexArrays(1, &VAO);
  glBindVertexArray(VAO);
  glEnableVertexAttribArray(layoutPosition);
  glVertexAttribPointer(layoutPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex),
                        NULL);
  // glEnableVertexAttribArray(layoutTexCoord);
  // glVertexAttribPointer(layoutTexCoord, 2, GL_FLOAT, GL_FALSE,
  // sizeof(Vertex), (void*)(sizeof(vec3)));

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(elements), elements,
               GL_STATIC_DRAW);
}

void BoxGeometry::reset(double _width, double _height) {
  geometry[0] = _width;
  geometry[1] = _height;
}

void BoxGeometry::reset(double _width, double _height, double _x0, double _y0) {
  geometry[0] = _width;
  geometry[1] = _height;
  geometry[2] = _x0;
  geometry[3] = _y0;
}

void BoxGeometry::render() {
  glBindVertexArray(VAO);
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
}
