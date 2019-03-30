// MdtBD8
vec3 boxCol( vec3 p )
{
    vec3 c = vec3( 0.9, 0.9, 0.9);
    if (p.x>box_size.x-0.001) {
        c.rb = vec2(0.0);
    }
    if (p.x<-box_size.x+0.001) {
        c.rg = vec2(0.0);
    }
	return c;
}

void intersect( inout vec3 ray_pos, vec3 ray_dir) 
{
    float thresh = 0.0002;
    float d;
    for (int i=0; i<96; i++)
    {
     	d = map(ray_pos);
        if (d<thresh) {
        	break;
        }
        ray_pos += ray_dir*d*0.4;
    }
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uvt = fragCoord.xy/iResolution.xy;
    vec2 uv = uvt - 0.5;
    uv.x *= iResolution.x/iResolution.y;
    
    // Jitter pixel start coordinates for free antialiasing 
    vec2 p_size = 2.0/iResolution.xy;
    uv.x += p_size.x*hash1( uint( 10000.0*iTime ) );
    uv.y += p_size.y*hash1( uint( 20000.0*iTime+3535.0 ) );
    vec3 ray_dir = normalize(vec3(uv, 1.0));
    vec3 ray_pos = vec3(0.0, 0.0, -1.0);
    vec3 col = vec3(1.0,1.0,1.0);
    
    vec3 incoming = vec3(0.0);
    
	for (int b=0; b<6; b++)
    {
    	intersect(ray_pos, ray_dir);
        
        vec3 n = calcNormal(ray_pos);

        if (sdSphere(ray_pos-spherePos.xyz, 
            spherePos.w) < 0.01) {
         // hit sphere
            vec3 c = vec3(sin(4.0*ray_pos.x)+1.0, 0.2, 0.5);
       		col *= c;
            incoming += 0.03*c;
        } else if (
            	ray_pos.y > 0.99 &&
            	all( lessThan( mod( 
                abs(ray_pos.xz+vec2(4.4,0.0)), 1.5 ), 
                vec2(1.3) ) ) ) {
           	// hit ceiling           
            incoming += vec3(5.0);
            break;
        } else {
            // hit walls or floor
            col *= boxCol(ray_pos);
            incoming += vec3(0.01);
        }
        
		float perp = length(cross(n,ray_dir));
        float rand = hash71(ray_pos, ray_dir, iFrame);
        if (rand > 0.9-0.7*perp*perp*perp) {
            // specular reflection
        	ray_dir = reflect(ray_dir, n);
        } else {
            // diffuse scatter
         	vec3 ndir = randomDir( ray_pos, ray_dir, iFrame+10 );
            ray_dir = normalize(8.0*(ndir+n*1.002));
        }
        ray_pos += 0.01*ray_dir;
    }
    
	col = incoming*col;

    // adjust color space
    col = pow(col, vec3(0.44));

    // delay accumulation to allow time for full screen
    float m = 1.0-1.0/float(iFrame-DELAY);
    if (iFrame < DELAY+1) m = 0.0;
    //m = 0.99;
    vec3 prev = texture( iChannel0, uvt).rgb;
    fragColor = vec4(mix(col,prev,m), 1.0);
}
