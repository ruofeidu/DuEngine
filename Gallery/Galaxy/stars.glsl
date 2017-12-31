// 
//122 version by FabriceNeyret2
//116 after addition of iTime, is this supported on all versions of oGL?
//103 with the #define trick
#define mainImage(f,u)                              \
    vec2 g = u+ vec2( cos((u.y+iTime)/3.) , u.x/9.);\
    f += 2./ length(u-g + 1e2*cos(g+ceil(g)) )		\
       -f 											\

//original by me (135)
//void mainImage( out vec4 f, vec2 u)
//{////////////////////////////////////////////////////////////////////////////
//*        .           *                  .            *              .     */																					#define s(x) u-x+cos(x+ceil(x))*99.
//**/f //    .       *    .   .  *           .        *    .                */ 
//*    */= // .     *                .        *                      .      */
//*    */2.//    .       .                               *                  */
//*    *// //                                    *                          */
//*    */length//       .            *                                .     */
//*  . */(//                             .            *         .           */
//*        */s//      *          .                                          */  
//*    *   */(//             *                                              */
//*            */vec2//                          .             *            */
//*  .    .    */(//                      *                                 */
//*                */u.x//       .              .                     .     */
//*            *   */+ //                                    .              */
//*     .          */cos//  *                                               */
//*   *            */(//                   .                                */
//*            *      */(//            *                 *              .   */     
//*                        */u.y//                                          */   
//*.       *       .   *   */+ //          .                    *           */    
//*                        */iTime//                                  */             
//*            *       */)//                        .         .             */ 
//*   *                *// //  *                                         .  */ 
//*           .        */3.//                                               */
//*                */)//                  .                  *              */
//*       .        */,//      .                                             */
//*                */u.y//                      *                 .         */
//*  .          .  */+ //                                  .                */
//*        *       */u.x//      .                                           */
//*                *// //            *   .                       *          */
//*  .     *       */9.//                                                   */
//*            */)//                             .      *              .    */
//*        */)//      *       *                                             */
//*    */)//      *             .   *                           .           */
//**/-f;//    .        .                      .                             */
//}////////////////////////////////////////////////////////////////////////////

/*
//a much prettier effect:
void mainImage( out vec4 f, vec2 u)
{
    //189
    //uv = floor(uv/8.)*8.;
	float t = iTime,y=u.y,x=u.x;
    f.gb+=1./length(u-vec2(x+cos(x/40.+tan(t+y/35.)+ceil(x/32.))*70.+sin((x+y)/10.+t)*6.,y+cos((y+x)/40.-t+ceil(y/32.))*70.))-f.gb;
}
*/