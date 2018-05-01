// Loop free digit printer
// ====================================
// Tupper's self-referential formula
// https://en.wikipedia.org/wiki/Tupper%27s_self-referential_formula
// ====================================
// great video by numberphile!
// https://www.youtube.com/watch?v=_s5RFgd59ao
// ====================================

const vec2 scale = vec2(3,5);
float[] k_arr = float[](32319.,2033.,30391.,32437.,31900.,
                        24253.,24255.,32272.,32447.,32445.);

void mainImage(out vec4 col,in vec2 coord)
{
    vec2 uv = (2.*coord.xy-iResolution.xy)/iResolution.y;
    vec2 c = vec2(0), o = vec2(1)/2., mi=c-o, ma=c+o; float s = scale.y;
    if(uv.x<mi.x||uv.y<mi.y||uv.x>ma.x||uv.y>ma.y) return;
    vec2 xy = (uv-mi)/(ma-mi)*scale; // map    
    xy.y+=k_arr[int(mod(iTime,10.))]*s;
    if(.5<floor(mod(floor(xy.y/s)*pow(2.,-s*floor(xy.x)-mod(floor(xy.y),s)),2.))) // magic formula
    	col = vec4(.5+.5*cos(iTime+uv.xyx+vec3(0,2,4)),1);
}