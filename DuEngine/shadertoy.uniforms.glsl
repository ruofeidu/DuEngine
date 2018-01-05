#version 450
#extension GL_EXT_shader_texture_lod : require

uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iTime;                 // shader playback time (in seconds)
uniform float     iTimeDelta;            // rendering time (in seconds)
uniform int       iFrameRate;            // rendering frame rate
uniform int       iFrame;                // rendering frame id
uniform float     iChannelTime[4];       // channel playback time (in seconds) current time in video or sound.
uniform vec3      iChannelResolution[4]; // channel resolution (in pixels)
uniform vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
uniform vec4      iDate;                 // (year, month, day, time in seconds)
uniform float     iSampleRate;           // sound sample rate (i.e., 44100)
#define iGlobalTime iTime
