// 以下方式访问向量等同
// vec4 vector;
// vector[0] = vector.r = vector.x = vector.s;
// vector[1] = vector.g = vector.y = vector.t;
// vector[2] = vector.b = vector.z = vector.p;
// vector[3] = vector.a = vector.w = vector.q;

#ifdef GL_ES
precision mediump float;
#endif
#define PI 3.14159265359
#define TWO_PI 6.28318530718

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

//#region -------------------mix------------------------
// vec3 colorA=vec3(.149,.141,.912);
// vec3 colorB=vec3(1.,.833,.224);

// void main(){
  //   vec3 color=vec3(0.);
  
  //   float pct=abs(sin(u_time));
  
  //   // Mix uses pct (a value from 0-1) to
  //   // mix the two colors
  //   color=mix(colorA,colorB,pct);
  
  //   gl_FragColor=vec4(color,1.);
// }
//#endregion

//#region -------------------mix2------------------------
// vec3 colorA=vec3(.149,.141,.912);
// vec3 colorB=vec3(1.,.833,.224);

// float plot(vec2 st,float pct){
  //   return smoothstep(pct-.01,pct,st.y)-
  //   smoothstep(pct,pct+.01,st.y);
// }

// void main(){
  //   vec2 st=gl_FragCoord.xy/u_resolution.xy;
  //   vec3 color=vec3(0.);
  
  //   vec3 pct=vec3(st.x);
  
  //   pct.r=smoothstep(0.,1.,st.x);
  //   pct.g=sin(st.x*PI);
  //   pct.b=pow(st.x,.5);
  
  //   color=mix(colorA,colorB,st.x);
  
  //   // Plot transition lines for each channel
  //   color=mix(color,vec3(1.,0.,0.),plot(st,pct.r));
  //   color=mix(color,vec3(0.,1.,0.),plot(st,pct.g));
  //   color=mix(color,vec3(0.,0.,1.),plot(st,pct.b));
  
  //   gl_FragColor=vec4(color,1.);
// }
//#endregion

//#region -----------------------------hsb----------------------
// vec3 rgb2hsb(in vec3 c){
  //   vec4 K=vec4(0.,-1./3.,2./3.,-1.);
  //   vec4 p=mix(vec4(c.bg,K.wz),
  //   vec4(c.gb,K.xy),
  //   step(c.b,c.g));
  //   vec4 q=mix(vec4(p.xyw,c.r),
  //   vec4(c.r,p.yzx),
  //   step(p.x,c.r));
  //   float d=q.x-min(q.w,q.y);
  //   float e=1.e-10;
  //   return vec3(abs(q.z+(q.w-q.y)/(6.*d+e)),d/(q.x+e),q.x);
// }

// //  Function from Iñigo Quiles
// //  https://www.shadertoy.com/view/MsS3Wc
// vec3 hsb2rgb(in vec3 c){
  //   vec3 rgb=clamp(abs(mod(c.x*6.+vec3(0.,4.,2.),6.)-3.)-1.,0.,1.);
  //   rgb=rgb*rgb*(3.-2.*rgb);
  //   return c.z*mix(vec3(1.),rgb,c.y);
// }

// void main(){
  //   vec2 st=gl_FragCoord.xy/u_resolution;
  //   vec3 color=vec3(0.);
  
  //   // We map x (0.0 - 1.0) to the hue (0.0 - 1.0)
  //   // And the y (0.0 - 1.0) to the brightness
  //   color=hsb2rgb(vec3(st.x,1.,st.y));
  
  //   gl_FragColor=vec4(color,1.);
// }
//#endregion

//#region --------------------length and atan----------------------
//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
// vec3 hsb2rgb(in vec3 c){
  //   vec3 rgb=clamp(abs(mod(c.x*6.+vec3(0.,4.,2.),6.)-3.)-1.,0.,1.);
  //   rgb=rgb*rgb*(3.-2.*rgb);
  //   return c.z*mix(vec3(1.),rgb,c.y);
// }

// void main(){
  //   vec2 st=gl_FragCoord.xy/u_resolution;
  //   vec3 color=vec3(0.);
  
  //   // Use polar coordinates instead of cartesian
  //   vec2 toCenter=vec2(.5)-st;
  //   float angle=atan(toCenter.y,toCenter.x);
  //   float radius=length(toCenter)*2.;
  
  //   // Map the angle (-PI to PI) to the Hue (from 0 to 1)
  //   // and the Saturation to the radius
  //   color=hsb2rgb(vec3((angle/TWO_PI)+.5,radius,1.));
  
  //   gl_FragColor=vec4(color,1.);
// }
//#endregion

//#region --------------------五彩旗----------------------
void main(){
  vec2 st=gl_FragCoord.xy/u_resolution.xy;
  vec3 color=vec3(0.);
  float alpha1=step(.2,st.x);
  color+=mix(vec3(1.,0.,0.),vec3(0.),1.-alpha1);
  float alpha2=step(.2,st.x-.2);
  color+=mix(vec3(0.,1.,0.),vec3(0.),1.-alpha2);
  float alpha3=step(.2,st.x-.4);
  color+=mix(vec3(0.,0.,1.),vec3(0.),1.-alpha3);
  float alpha4=step(.2,st.x-.6);
  color+=mix(vec3(1.,0.,0.),vec3(0.),1.-alpha4);
  float alpha5=step(.2,st.x-.8);
  color+=mix(vec3(0.,1.,0.),vec3(0.),1.-alpha5);
  gl_FragColor=vec4(color,1.);
}
//endregion