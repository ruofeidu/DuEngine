#define FOVEAL_WITH_MOUSE 1
#define DEBUG_LOG_SPACE 0
#define SEE_GROUNDTRUTH 0

#define ALPHA 4.0
//#define DEFAULT_SIGMA 1.8
#define DEFAULT_SIGMA 1.0

#if DEBUG_LOG_SPACE
	#define iApplyLogMap1 true
	#define iApplyLogMap2 false
#else
    #if SEE_GROUNDTRUTH
        #define iApplyLogMap1 (iMouse.z < 0.5)
        #define iApplyLogMap2 (iMouse.z < 0.5)
    #else
        #define iApplyLogMap1 true
        #define iApplyLogMap2 true
    #endif
#endif

#define logTexture iChannel0
#define AdjustRegion 2

#define PI 3.141592653589793238
#define TWOPI 6.283185307179586

#define MOVECENTER
//#define NONLINEAR_LOGMAP

#define MAX_THETA TWOPI
#define PIXEL_SIZE (vec2(1,1) / iResolution.xy)

#define USE_FXAA 0
// FXAA parameterS
#define FXAA_EDGE_THRESHOLD_MIN (1.0/12.0)
#define FXAA_EDGE_THRESHOLD (1.0/8.0)
#define FXAA_SPAN_MAX     8.0

#define KERNEL_FUNCTION_TYPE 3.0


// foveal position
#if FOVEAL_WITH_MOUSE
    #define FOVEAL ((iMouse.xy / iResolution.xy) * 2.0 - 1.0)
    #define FOVEAL2 (iMouse.xy / iResolution.xy)
#else
    #define FOVEAL vec2(0.0, 0.0)
    #define FOVEAL2 vec2(0.5, 0.5)
#endif

