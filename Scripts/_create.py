import os, io, re
import requests

appKey = "rtHtWN"
re_shaderID = re.compile(u"\w+\s\w{6}")
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
    print(filename)
    with open("%s.cmd" % filename, "w") as f:
        f.write('"../DuEngine/x64/Release/DuEngine.exe" %~n0.ini\n')
    
    with open("%s.ini" % filename, "w") as f:
        f.write('shader_frag\t\t=\t$Name.glsl\nchannels_count\t=\t0\niChannel0_type\t=\tfont\n')
    
    with open("%s.glsl" % filename, "w") as f:
        f.write('\n')
    
    