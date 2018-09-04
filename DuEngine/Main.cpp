/**
* DuRenderer: An efficient interactive C++ renderer for ShaderToy-alike 
*             demos with 2D/CubeMap/Video/Camera/LightField textures.
* Ruofei Du | Augmentarium Lab | UMIACS
* Computer Science Department | University of Maryland, College Park
* me [at] duruofei [dot] com
* 12/6/2018
*/
#include "stdafx.h"
#include "DuEngine.h"

int main(int argc, char **argv) {
	DuEngine::GetInstance()->start(argc, argv);
	return EXIT_SUCCESS;
}
