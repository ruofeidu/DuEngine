# DuEngine for ShaderToy
Here is the implementation of using basic I/O to render fragment-shader demos from ShaderToy in C++.
## Installation
Require: OpenGL 4.5+, OpenCV 3.0+, GLM, Visual Studio

The solution file locates in DuEngine/DuEngine.sln, or simply click OpenSolution.cmd.
Compiled in Windows right now, will update with Mac in the future.

Four Environment paths are required. Easy and simple!

* OPENCV_INC: Directory to OpenCV
* GLEW_INC: Directory to Glew, Freeglut, and GLM headers
* OPENCV_LIB: Directory to OpenCV libraries
* GLEW_LIB: Directory to Glew and Freeglut libraries

## Features
### ConfigFiles
This renderer supports reading from a simple config files and built-in textures.
Run:
```c
DuEngine config.ini
```
The config file reads like:
```c
shader_frag		=	$Name.glsl
buffers_count	=	4
channels_count	=	4
iChannel0_type	=	A
iChannel1_type	=	B
iChannel2_type	=	C
iChannel3_type	=	D
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

### Screenshots


Here stores some of my GLSL code written in Shadertoy.com
[My ShaderToy Public Profile](https://www.shadertoy.com/user/starea)

## Demos and blog posts
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