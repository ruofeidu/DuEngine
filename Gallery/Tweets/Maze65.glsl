// https://www.shadertoy.com/view/lt2cRR
#define mainImage( O, U )   \
   O += mod( U [ int( 1e4*length(ceil(U/8.)) ) % 2 ] , 8. )
   

     
 
       
       
/**   // 70 chars

#define mainImage( O, U )   \
   O += mod( U [ sin(1e5*length(ceil(U/8.))) < 0.  ? 0 : 1 ] , 8. )
       
/**/