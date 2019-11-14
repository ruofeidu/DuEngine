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
#include "stdafx.h"

class Window {
 public:
  static Window *GetInstance();
  void init(int argc, char *argv[], int width, int height, string _windowTitle);
  void reshape(int _width, int _height);
  int width, height;

 private:
  static Window *s_Instance;
  class GC {
   public:
    ~GC() {
      if (s_Instance != NULL) {
        delete s_Instance;
        s_Instance = NULL;
      }
    }
  };
  static GC gc;
};
