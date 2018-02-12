// https://www.shadertoy.com/view/https://www.shadertoy.com/view/XstczN
//#define SCALING (iResolution.y*iResolution.y)
//#define SCALING (2.*iResolution.y)
//#define SCALING iResolution.y
#define SCALING 1.

float valO(int n)
{
    return texelFetch(iChannel0, ivec2(n, 0),0).r;
}

float valR(int n)
{
    return texelFetch(iChannel1, ivec2(n, 0),0).r;
}

float InverseLaplaceCoefficient(int N, int i, int j)
{
    i++;
    j++;
    
    if (j==1)
    {
      return float(N-i);
      //return float(N-i)/float(N-1);
    }
    
    if (j==N)
    {
      return float(i-1);
      //return float(i-1)/float(N-1);
    }
    
    if (i==1 || i==N)
    {
      return 0.;
    }

    i = N-i+1;

    if (i+j> N+1)
    {
      int k=i;
      i=N-j+1;
      j=j+(i-k);
    }

    return float(j-1+(i-2)*(j-1));
    //return float(j-1+(i-2)*(j-1))/float(N-1);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    ivec2 ifragCoord = ivec2(floor(fragCoord));
    
    if(ifragCoord.y != 0)
    {
        fragColor = vec4(0.);
        return;
    }
    
    int i = ifragCoord.x;
    int N = int(iResolution.x);
    float U = 0.;
    
    for(int j=0; j<N; ++j)
    {
        U += InverseLaplaceCoefficient(N, i, j) * valO(j);
    }
    
    U /= float(N-1);
    
    fragColor = vec4(U, 0., 0., 0.);
}