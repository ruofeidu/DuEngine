import os, io, re
import requests

appKey = "rtHtWN"
re_shaderID = re.compile(u"\w+\s\w{6}")
re_multipass = re.compile(u"\w+\_\d")
filename = input("Enter the name, or name followed by shader ID of the ShaderToy: ");

if re_shaderID.match(filename):
    url = "https://www.shadertoy.com/api/v1/shaders/%s?key=%s" % (filename, appKey)
    print(url)
    try:
        contents = requests.get(url).text
        print(contents)
    except Exception as e:
        print(e)
else:
    if re_multipass.match(filename):
        buffers = int(filename[-1])
        filename = filename[:-2]
    else:
        buffers = 0
    print(filename)
    with open("%s.cmd" % filename, "w") as f:
        f.write('"../DuEngine/x64/Release/DuEngine.exe" %~n0.ini\n')
    
    with open("%s.ini" % filename, "w") as f:
        if buffers:
            f.write('shader_frag\t\t=\t$Name.glsl\nbuffers_count\t=\t%d\nchannels_count\t=\t0\niChannel0_type\t=\tlondon\n' % buffers)
            for i in range(buffers):
                f.write('%s_channels_count\t=\t1\n%s_iChannel0_type\t=\tlondon\n' % (chr(65+i), chr(65+i)))
        else:
            f.write('shader_frag\t\t=\t$Name.glsl\nchannels_count\t=\t0\niChannel0_type\t=\tfont\n')
    


    with open("%s.glsl" % filename, "w") as f:
        f.write('\n')
    
    for i in range(buffers):
        with open("%s%s.glsl" % (filename, chr(65+i)), "w") as f:
            f.write('\n')
    