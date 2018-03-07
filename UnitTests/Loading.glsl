void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 glUV = fragCoord.xy / iResolution.xy;	
	vec4 cvSplashData = vec4(iResolution.x, iResolution.y, iGlobalTime, 0.0);	
	vec2 InUV = glUV * 2.0 - 1.0;	
	
	// Constants
	float TimeElapsed		= cvSplashData.z;
	float Brightness		= sin(TimeElapsed) * 0.1;
	vec2 Resolution		= vec2(cvSplashData.x, cvSplashData.y);
	float AspectRatio		= Resolution.x / Resolution.y;
	vec3 InnerColor		= vec3( 0.50, 0.50, 0.50 );
	vec3 OuterColor		= vec3( 0.00, 0.45, 0.00 );
	vec3 WaveColor		= vec3( 1.00, 1.00, 1.00 );
		
	// Input
	vec2 uv				= (InUV + 1.0) / 2.0;

	// Output
	vec4 outColor			= vec4(0.0, 0.0, 0.0, 0.0);

	// Positioning 
	vec2 outerPos			= -0.5 + uv;
	outerPos.x				*= AspectRatio;

	vec2 innerPos			= InUV * ( 2.0 - Brightness );
	innerPos.x				*= AspectRatio;

	// "logic" 
	float innerWidth		= length(outerPos);	
	float circleRadius		= 0.24 + Brightness * 0.1;
	float invCircleRadius 	= 1.0 / circleRadius;	
	float circleFade		= pow(length(2.0 * outerPos), 0.5);
	float invCircleFade		= 1.0 - circleFade;
	float circleIntensity	= pow(invCircleFade * max(1.1 - circleFade, 0.0), 2.0) * 40.0;
  	float circleWidth		= dot(innerPos,innerPos);
	float circleGlow		= ((1.0 - sqrt(abs(1.0 - circleWidth))) / circleWidth) + Brightness * 0.5;
	float outerGlow			= min( max( 1.0 - innerWidth * ( 1.0 - Brightness ), 0.0 ), 1.0 );
	float waveIntensity		= 0.0;
	
	// Inner circle logic
	if( innerWidth < circleRadius )
	{
		circleIntensity		*= pow(innerWidth * invCircleRadius, 24.0);
		
		float waveWidth		= 0.05;
		vec2 waveUV		= InUV;

		waveUV.y			+= 0.14 * cos(TimeElapsed + (waveUV.x * 2.0));
		waveIntensity		+= abs(1.0 / (130.0 * waveUV.y));
			
		waveUV.x			+= 0.14 * sin(TimeElapsed + (waveUV.y * 2.0));
		waveIntensity		+= abs(1.0 / (130.0 * waveUV.x));

		waveIntensity		*= 1.0 - pow((innerWidth / circleRadius), 3.0);
	}	

	// Compose outColor
	outColor.rgb	= outerGlow * OuterColor;	
	outColor.rgb	+= circleIntensity * InnerColor;	
	outColor.rgb	+= circleGlow * InnerColor * (0.6 + Brightness * 1.2);
	outColor.rgb	+= WaveColor * waveIntensity;
	outColor.rgb	+= circleIntensity * InnerColor;
	outColor.a		= 1.0;

	// Fade in
	outColor.rgb	= saturate(outColor.rgb);
	outColor.rgb	*= min(TimeElapsed / 2.0, 1.0);
	
	fragColor = outColor;
}