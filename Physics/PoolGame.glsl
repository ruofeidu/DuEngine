// https://www.shadertoy.com/view/MljSz1 
// constants are changable :)
const int futureTrail = 0;  // 1 shows the trail until stop
const float bounceRatio = 0.75; // 1.0=fully elastic collisions   (min 0.0001)
const float diskrad = 0.066;
const float initialVelocity = 2.0;
const float timewrap = 10.01;
const int showSolution = 0;  // shows the final coordinates of the green ball with each input
const int ballCount = 4;  // be sure to adjust the code if increased


float endtime=5.0; // fake air friction  ends movements at this virtual time

vec4 balldatas[ballCount+99];
vec3 ballcolors[ballCount+99];
vec3 color=vec3(0.0);
vec2 uv;
vec2 mouse;
float time;    // time of displayed state
float simtime; // starts from zero

float soundout=0.0; // ignored in the image shader file

void disk(vec2 pos,float radius,vec3 color2) // AA disk
{
    color = mix(color2,color,clamp((length(pos-uv)-radius)*iResolution.y+0.5,0.0,1.0)); 
}


int pass; // pass = 0   find earliest collision    pass = 1 update velocities at a the time of collision
float  earliest;  // store the earliest collision time

#define timeoffset(i,t) balldatas[i].xy-=balldatas[i].zw*t

void ballvsball_func_unused() // needs to be #defined
{
    const int i=0;
    const int j=1;
    
    vec2 startpt = balldatas[j].xy-balldatas[i].xy;
    vec2 dir = balldatas[j].zw-balldatas[i].zw;
    float f;
    if ( (f=abs(dot(dir.yx*vec2(1.0,-1.0),startpt)))<2.0*diskrad*length(dir)) // hit or missed
    {
    	float t = (-sqrt(  pow(2.0*diskrad*length(dir),2.0)-f*f)-dot(startpt,dir))/dot(dir,dir);
        
        if (t>simtime)
        {
            if (pass==0)
            {
                earliest = min(earliest,t);
            }
            else
            {
                if (earliest==t)
                {
                    balldatas[i].xy+=balldatas[i].zw*t;
                    balldatas[j].xy+=balldatas[j].zw*t;
                    
                    vec2 bouncenormal = (balldatas[i].xy-balldatas[j].xy)/diskrad/2.0;
                    vec2 ch = bouncenormal*dot(bouncenormal,(balldatas[i].zw-balldatas[j].zw))*(1.0+bounceRatio)/2.0;
                    balldatas[i].zw-=ch;
                    balldatas[j].zw+=ch;
                    timeoffset(i,t);
                    timeoffset(j,t);
                    
                }
            }
//            disk(balldatas[i].xy+balldatas[i].zw*t,diskrad,ballcolors[i]*0.5);
        }
        
    }
}

#define ballvsball(i,j)   { vec2 startpt = balldatas[j].xy-balldatas[i].xy;    vec2 dir = balldatas[j].zw-balldatas[i].zw;    float f;    if ( (f=abs(dot(dir.yx*vec2(1.0,-1.0),startpt)))<2.0*diskrad*length(dir))   {    	float t = (-sqrt(  pow(2.0*diskrad*length(dir),2.0)-f*f)-dot(startpt,dir))/dot(dir,dir);                if (t>simtime)        {            if (pass==0)            {                earliest = min(earliest,t);            }            else            {                if (earliest==t)                {                    balldatas[i].xy+=balldatas[i].zw*t;                    balldatas[j].xy+=balldatas[j].zw*t;                                        vec2 bouncenormal = (balldatas[i].xy-balldatas[j].xy)/diskrad/2.0;                    vec2 ch = bouncenormal*dot(bouncenormal,(balldatas[i].zw-balldatas[j].zw))*(1.0+bounceRatio)/2.0;                    balldatas[i].zw-=ch;                    balldatas[j].zw+=ch;                    timeoffset(i,t);                    timeoffset(j,t);                                    }            }        }            }}


void render()
{
    // render balls
    for(int i=0;i<ballCount;i++)
    {
        disk(balldatas[i].xy+balldatas[i].zw*time,diskrad,ballcolors[i]);
    }
}

void renderline(vec2 a,vec2 b,vec3 color2) // anti aliased line
{
    if (  dot(uv,b-a)>dot(a,b-a) && dot(uv,b-a)<dot(b,b-a))
    {
        if (length(color)<0.2) 
        {
            float f= clamp((0.006-abs(dot(uv-a,(b-a).yx*vec2(1.0,-1.0)))/length(b-a))*iResolution.y,0.0,1.0);
            color = color2*f;
        }
    }
}

#define pos(i,t) (balldatas[i].xy+balldatas[i].zw*t)

#define ballpath(i) renderline(pos(i,simtime),pos(i,earliest),ballcolors[i]*0.5)

void pathrender()
{
    ballpath(0);
    ballpath(1);
    ballpath(2);
    if (ballCount>3) ballpath(3);
    
}

const float wallx = 8.0/9.0-diskrad;
const float wally = 0.5-diskrad;

#define updatevel(i,v,t){ balldatas[i].xy+=(balldatas[i].zw-(v))*t;balldatas[i].zw=(v);}

void ballwall_func_unused() // needs to be #defined
{
    const int i=0;

    float t;
    
    t = (((balldatas[i].z>0.0) ? wallx : -wallx) -   balldatas[i].x)/balldatas[i].z;
    if (pass==0)
    {
        earliest = min(earliest,t);
    }
    else
    {
        if (earliest==t)
        {
            updatevel(i,balldatas[i].zw*vec2(-1.,1.)*bounceRatio,t);
        }
    }
    t = (((balldatas[i].w>0.0) ? wally : -wally) -   balldatas[i].y)/balldatas[i].w;
    if (pass==0)
    {
        earliest = min(earliest,t);
    }
    else
    {
        if (earliest==t)
        {
            updatevel(i,balldatas[i].zw*vec2(1.,-1.)*bounceRatio,t);
        }
    }
}

#define ballwall(i) {    float t;    t = (((balldatas[i].z>0.0) ? wallx : -wallx) -   balldatas[i].x)/balldatas[i].z;    if (pass==0)    {        earliest = min(earliest,t);    }    else    {        if (earliest==t)        {            updatevel(i,balldatas[i].zw*vec2(-1.,1.)*bounceRatio,t);        }    }    t = (((balldatas[i].w>0.0) ? wally : -wally) -   balldatas[i].y)/balldatas[i].w;    if (pass==0)    {        earliest = min(earliest,t);    }    else    {        if (earliest==t)        {            updatevel(i,balldatas[i].zw*vec2(1.,-1.)*bounceRatio,t);        }    }     }


void docollisions()
{
    ballwall(0);
    ballwall(1);
    ballvsball(0,1);
    if (ballCount>2)
    {
    	ballwall(2);
    	ballvsball(0,2);
    	ballvsball(1,2);
        if (ballCount>3)
        {
    		ballwall(3);
            ballvsball(0,3);
            ballvsball(1,3);
            ballvsball(2,3);
        }
    }
}
 

void rundemo(float timein) 
{
    float startdata = floor(timein/timewrap);
    timein = mod(timein,timewrap);
    timein = max(timein-1.0,0.0); // wait before shooting
    
    ballcolors[0] = vec3(0.9);
    ballcolors[1] = vec3(0.9,0.0,0.0);
    ballcolors[2] = vec3(0.8,0.5,0.0);
    ballcolors[3] = vec3(0.1,0.6,0.0);
    ballcolors[4] = vec3(0.0,0.6,0.9);
    
    float mininum=1e-20;
    balldatas[0] = vec4(-0.7,0.0+startdata*0.01,initialVelocity,mininum);
    balldatas[1] = vec4(-0.1,-0.08,mininum,mininum);
    balldatas[2] = vec4(-0.0,0.1,mininum,mininum);
    balldatas[3] = vec4(0.4,0.1,mininum,mininum);
    
    if (mouse.x!=0.0)
    {
        balldatas[0].y = mouse.y;
        balldatas[0].zw = normalize(vec2(1.0,mouse.x*2.0))*initialVelocity;
    }
    
    
    if (timein<0.1)
    {
        renderline(balldatas[0].xy,balldatas[0].xy+balldatas[0].zw*0.25,ballcolors[0]);
    }
        
    time = endtime*(1.0-exp(-timein/endtime)); // apply air friction to all balls (no roll friction)
    
    if (futureTrail==0)
    {
        endtime = min(endtime,time);
    }
    
    simtime = 0.0;
    
    for(int i=0;i<100;i++)
    {
        earliest = endtime;
        pass = 0;
        docollisions();
        pathrender();
        if (earliest>=endtime) break;
        if (simtime<=time && earliest>time) render();
        pass = 1;
        docollisions();
        simtime = earliest;
    }
    earliest=endtime;
    pathrender();
    if (simtime<=time) render();
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	uv = fragCoord.xy / iResolution.xy;
    uv.x -= 0.5;
    uv.y -= 0.5;
    uv.x*=16.0/9.0;
    mouse = iMouse.xy / iResolution.xy;
    if (length(mouse)>0.0)
    {
    	mouse.xy -= vec2(0.5,0.5);
    	mouse.x*=16.0/9.0;
    }
 
    if (showSolution!=0)
    {
        mouse = uv;
    }
  
   
   color = vec3(0.0);
   rundemo(iTime);
    
    
	fragColor = vec4(color,1.0);
    if (showSolution!=0)
    {
//        fragColor = vec4( length(pos(3,endtime).xy-vec2(-wallx,-wally))<0.1?1.0:0.0, 0.0,0.0,0.0);
        fragColor = vec4( pos(3,endtime).xy,0.0,0.0);        
    }
    
}