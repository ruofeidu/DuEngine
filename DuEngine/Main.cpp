/**
* DuRenderer is a basic OpenGL-based renderer which implements most of the ShaderToy functionality
* Ruofei Du | Augmentarium Lab
* 12/6/2017
*/
#include "stdafx.h"
#include "DuEngine.h"

int main(int argc, char **argv) {
	DuEngine::GetInstance()->start(argc, argv);
	return EXIT_SUCCESS;
}
