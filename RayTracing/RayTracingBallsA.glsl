// XstfD8



vec2 mainSound( float time )
{
    float 	baseFrequency = 6.2831 * 440.0 * time; // 440 Hz
    vec2 	wave = vec2(0, 0);
    
    wave += sin(baseFrequency) * 0.5 + 0.5;
    return wave * 0.0f;
}