# DuEngine
DuEngine is an efficient and interactive C++ graphics engine for rendering, managing, recording image and video screenshots of ShaderToy-like demos with custom 2D/3D/Video textures.

## Compilation
Dependencies: OpenGL 4.5+, [Glew](http://glew.sourceforge.net/install.html), [OpenCV 3.0+](https://opencv.org/releases.html), [GLM](https://github.com/g-truc/glm/releases), [Visual Studio 2015](https://www.visualstudio.com/downloads)+

* To compile the project, simply run *OpenSolution.cmd*, or locate the solution file at *DuEngine/DuEngine.sln*
* To test the project, run *UnitTest/debug.cmd*, and you will see the renderer with all sorts of input channels.

If the compilation fails, please fix the following five environment variables.

* OPENCV_INC: Directory to OpenCV include folder.
* GLEW_INC: Directory to Glew, Freeglut, and GLM headers.
* OPENCV_LIB: Directory to OpenCV libraries.
* GLEW_LIB: Directory to Glew and Freeglut libraries.
* PATH: Add the executable DLLs of OpenCV and GLUT into this variables.

## Run the Default Demo


## Create New Demos
Dependency: Python

To create a new ShaderToy demo, just click *_create.cmd* in any category folder like "Ray Tracing". In the console, please input the desired shader name, like "Test". The Python script will generate *Test.glsl*, *Test.ini*, and *Test.cmd* files. The GLSL file is the main Shadertoy-like GLSL code, the ini file is the config file which defines the input channels, and the cmd file is where you run the demo.

## Features
### ConfigFiles
This renderer provides an easy-to-use interface to link any GLSL demos with built-in, and custom textures.
Run:
```c
DuEngine config.ini
```
The config file reads like:
```c
shader_frag		    =	$Name.glsl
buffers_count	    =	4
channels_count	    =	4
iChannel0_type	    =	noise
iChannel1_type	    =	rgb
iChannel1_tex       =   whatever.png
iChannel2_type	    =	video
iChannel2_tex       =   whatever.mp4
iChannel3_type	    =	A
A_channels_count	=	1
A_iChannel0_type	=	london
B_channels_count	=	1
B_iChannel0_type	=	A
C_channels_count	=	1
C_iChannel0_type	=	B
D_channels_count	=	1
D_iChannel0_type	=	C
```

### Multipass
Full-featured multipass rendering

### Screenshots and Recording
Press F2 to take a screen shot. Inside the configuration file, please add the following statements for recording a video / sequences of images:
```C
recording		=	true
record_start	=	1
record_end		=	50
record_video	=	true
```
The video will be stored in record by default.

In the end, here stores some of my GLSL code written in Shadertoy.com
[My ShaderToy Public Profile](https://www.shadertoy.com/user/starea)

## Demos and Blog Posts
![Interactive Poisson Blending](http://www.duruofei.com/Public/trailer/poisson.jpg)
* [Interactive Poisson Blending](https://www.shadertoy.com/view/4l3Xzl)
    * [Blog post](http://blog.ruofeidu.com/interactive-poisson-blending)

![UNIFIED GNOMONIC AND STEREOGRAPHIC PROJECTIONS](http://blog.ruofeidu.com/wp-content/uploads/2017/04/p2.jpg)
* [Unified Gnomonic & Stereographic](https://www.shadertoy.com/view/ldBczm)
	* [Blog post](http://blog.ruofeidu.com/unified-gnomonic-stereographic-projections/)
* [Cubemap to Gnomonic Projection](https://www.shadertoy.com/view/4sjcz1)
	* [Blog post](http://blog.ruofeidu.com/equirectangular-gnomonic-projections-cubemaps/)
* [Foveated Rendering via Quadtree](https://www.shadertoy.com/view/Ml3SDf)
* [Dotted Drawing / Sketch Effect](https://www.shadertoy.com/view/ldSyzV)
	* [Blog post](http://blog.ruofeidu.com/dotted-drawing-sketch-effect/)
* [Edges with Bilateral Filters](https://www.shadertoy.com/view/MlG3WG)

![Instgram Brannan Filter](http://blog.ruofeidu.com/wp-content/uploads/2017/11/earlybird.jpg)
* [Instgram Brannan Filter](https://www.shadertoy.com/view/4lSyDK)
* [Instgram Earlybird Filter](https://www.shadertoy.com/view/XlSyWV)
    * [Blog post](http://blog.ruofeidu.com/implementing-instagram-filters-brannan/)
* [0-4 Order of Spherical Harmonics](https://www.shadertoy.com/view/4dsyW8)
* [Cubemap to Gnomonic Projection](https://www.shadertoy.com/view/4sjcz1)
* [Unified Gnomonic & Stereographic](https://www.shadertoy.com/view/ldBczm)
* [Low-Poly Style Image](https://www.shadertoy.com/view/llGGz3)
* [404 Not Found](http://duruofei.com/404) 
    * [Blog post](http://blog.ruofeidu.com/404-not-found-two-triangles/)
* [Postprocessing Thermal](https://www.shadertoy.com/view/4dcSDH)
* [2D Affine Transformation](https://www.shadertoy.com/view/llBSWw)
* [Image Fade-In Effect](https://www.shadertoy.com/view/MlcSz2)

![Code Golf: Halftone Image](http://blog.ruofeidu.com/wp-content/uploads/2017/10/golf.jpg)
* [Dot Screen / Halftone](https://www.shadertoy.com/view/4sBBDK)
	* [Blog post](http://blog.ruofeidu.com/code-golf-halftone-image/)
* [Equirectangular Fibonacci Sphere](https://www.shadertoy.com/view/Ms2yDK)
* [Parameterized Gabor Filters](https://www.shadertoy.com/view/4sBcRV)
* [Bilateral Filter to Look Younger](https://www.shadertoy.com/view/XtVGWG)

![Brightness, Contrast, Hue, Saturation, Vibrance](http://blog.ruofeidu.com/wp-content/uploads/2017/10/hue.jpg)
* [Brightness, Contrast, Hue, Saturation, Vibrance](https://www.shadertoy.com/view/MdjBRy)
	* [Blog post] (http://blog.ruofeidu.com/postprocessing-brightness-contrast-hue-saturation-vibrance/)

Author
----
Ruofei Du


License
----
Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.