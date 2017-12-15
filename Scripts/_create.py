import os, io, re, sys
import requests

appKey = "rtHtWN"
re_shaderID = re.compile(u"\w+\s\w{6}")
print("Usage: Name [NumOfBuffers] [NumOfChannelsOfMain] [ShaderToyName] // ~%d" % len(sys.argv));
filename = input("Enter the name, or name followed by shader ID of the ShaderToy: ");
numChannels = 1
numBuffers = 0
shaderToyName = ""
numUpperLevel = 1

if re_shaderID.match(filename):
    url = "https://www.shadertoy.com/api/v1/shaders/%s?key=%s" % (filename, appKey)
    print(url)
    try:
        contents = requests.get(url).text
        print(contents)
    except Exception as e:
        print(e)
else:
    parts = filename.split()
    if len(parts) > 1:
        numChannels = int(parts[1])
    if len(parts) > 2:
        numBuffers = int(parts[2])
    if len(parts) > 3:
        shaderToyName = "https://www.shadertoy.com/view/%s" % parts[3]
    if len(sys.argv) > 1:
        numUpperLevel = int(sys.argv[1])
    filename = parts[0]
    
    with open("%s.cmd" % filename, "w") as f:
        f.write('"')
        for i in range(numUpperLevel):
            f.write("../")
        f.write('DuEngine/x64/Release/DuEngine.exe" %~n0.ini\n')
    
    with open("%s.ini" % filename, "w") as f:
        f.write('shader_frag\t\t=\t$Name.glsl\nchannels_count\t=\t%d\n' % numChannels)
        for i in range(numChannels):
            f.write('iChannel%d_type\t=\tLondon\n' % i)
        if numBuffers:
            f.write('buffers_count\t=\t%d\n' % numBuffers)
            for i in range(numBuffers):
                ch = chr(65+i)
                f.write('%s_channels_count\t=\t1\n%s_iChannel0_type\t=\tblack\n' % (ch, ch))
    
    with open("%s.glsl" % filename, "w") as f:
        f.write('// %s\n' % shaderToyName)
    
    for i in range(numBuffers):
        ch = chr(65+i)
        with open("%s%s.glsl" % (filename, ch), "w") as f:
            f.write('// %s\n' % shaderToyName)
    
    print("%s created with %d channels and %d additional buffers." % (filename, numChannels, numBuffers))