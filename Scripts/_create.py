from __future__ import print_function
import re, sys, json, random
import requests

# This script generates the .cmd, .glsl, and .ini file automatically from ShaderToy
# Example:
# Augmentarium XtV3DW

MAX_CHANNELS = 10
DEFAULT_CHANNELS = 4
APP_KEY = "rtHtWN"
RANDOM_TEXTURES = ['London', 'SJTU', '720p', '1080p']

re_shaderID = re.compile(u"\w+\s\w{6}")
print("Usage: ShaderName [NumOfBuffers] [NumOfChannelsOfMainBuffer] [ShaderToyID] // ~%d" % len(sys.argv))
filename = input("Enter the name, or name followed by shader ID of the ShaderToy: ")
numChannels = DEFAULT_CHANNELS
numBuffers = 0
shaderToyName = ""
numUpperLevel = 1
frags = ['' for _ in range(MAX_CHANNELS)]
channels = [DEFAULT_CHANNELS for _ in range(MAX_CHANNELS)]
render_pass = None

# parse the ShaderToy structure
if re_shaderID.match(filename):
    parts = filename.split()
    shaderToyName = parts[1]
    url = "https://www.shadertoy.com/api/v1/shaders/%s?key=%s" % (shaderToyName, APP_KEY)
    print(url)
    try:
        contents = json.loads(requests.get(url).text)
        print(contents)
        print(contents['Shader']['info']['name'])

        render_pass = contents['Shader']['renderpass']
        numBuffers = len(render_pass) - 1

        for i, rp in enumerate(render_pass):
            frags[i] = rp['code']
            channels[i] = len(rp['inputs'])
    except Exception as e:
        print(e)
else:
    parts = filename.split()
    if len(parts) > 1:
        channels[0] = int(parts[1])
    if len(parts) > 2:
        numBuffers = int(parts[2])
    if len(parts) > 3:
        shaderToyName = "https://www.shadertoy.com/view/%s" % parts[3]

# parse levels of the directory
if len(sys.argv) > 1:
    numUpperLevel = int(sys.argv[1])

# write the command file
filename = parts[0]
with open("%s.cmd" % filename, "w") as f:
    f.write('"')
    for i in range(numUpperLevel):
        f.write("../")
    f.write('DuEngine/x64/Release/DuEngine.exe" %~n0.ini\n')

# write the channels
with open("%s.ini" % filename, "w") as f:
    f.write('shader_frag\t\t=\t$Name.glsl\nchannels_count\t=\t%d\n' % channels[0])
    for i in range(channels[0]):
        buf_type = random.choice(RANDOM_TEXTURES)
        # print(render_pass[0]['inputs'][i]['channel'])
        if render_pass and render_pass[0]['inputs'][i]['src'] is not None:
            s = render_pass[0]['inputs'][i]['src']
            if s.find('buffer0') >= 0:
                print(s)
                print("parse: ", s[-5:-4])
                buf_type = chr(65 + int(s[-5:-4]))
        f.write('iChannel%d_type\t=\t%s\n' % (i, buf_type))
    if numBuffers:
        f.write('buffers_count\t=\t%d\n' % numBuffers)
        for i in range(numBuffers):
            ch = chr(65 + i)
            f.write('%s_channels_count\t=\t%d\n' % (ch, channels[i + 1]))
            for j in range(channels[i + 1]):
                buf_type = 'black'
                # print(ch, render_pass[i + 1]['inputs'][j]['channel'])
                if render_pass and render_pass[i + 1]['inputs'][j]['src'] is not None:
                    s = render_pass[i + 1]['inputs'][j]['src']
                    if s.find('buffer0') >= 0:
                        print("prase: ", s[-5:-4])
                        buf_type = chr(65 + int(s[-5:-4]))
                f.write('%s_iChannel%d_type\t=\t%s\n' % (ch, j, buf_type))

# write the GL
with open("%s.glsl" % filename, "w", encoding="utf-8") as f:
    f.write('// %s\n%s' % (shaderToyName, frags[0]))

for i in range(numBuffers):
    ch = chr(65 + i)
    with open("%s%s.glsl" % (filename, ch), "w", encoding="utf-8") as f:
        f.write('// %s\n%s' % (shaderToyName, frags[i + 1]))

print("%s created with %d channels and %d additional buffers." % (filename, numChannels, numBuffers))
