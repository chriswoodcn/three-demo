#ifdef GL_ES
precision mediump float;
#endif
#define PI 3.14159265359
#define TWO_PI 6.28318530718

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
//#region ---------------------rect-------------------
// void main(){
  //   vec2 st=gl_FragCoord.xy/u_resolution.xy;
  //   vec3 color=vec3(0.);
  
  //   // Each result will return 1.0 (white) or 0.0 (black).
  //   float left=step(.1,st.x);// Similar to ( X greater than 0.1 )
  //   float bottom=step(.1,st.y);// Similar to ( Y greater than 0.1 )
  
  //   vec2 lb=step(vec2(.02),st);
  //   // vec2 lb=smoothstep(vec2(.1),vec2(.3),st);
  //   float pct=lb.x*lb.y;
  //   // The multiplication of left*bottom will be similar to the logical AND.
  //   // color=vec3(left*bottom);
  
  //   // top-right
  //   vec2 tr=step(vec2(.02),1.-st);
  //   // vec2 tr=smoothstep(vec2(.1),vec2(.3),1.-st);
  //   pct*=tr.x*tr.y;
  
  //   color=vec3(pct);
  
  //   gl_FragColor=vec4(color,1.);
// }
//#endregion

//#region -----------------------circle-----------------------
// void main(){
//   vec2 st=gl_FragCoord.xy/u_resolution;
//   float pct=0.;
  
//   // a. The DISTANCE from the pixel to the center
//   // pct=distance(st,vec2(.5));
//   pct=1.-step(.5,distance(st,vec2(.5)));
  
//   // b. The LENGTH of the vector
//   //    from the pixel to the center
//   // vec2 toCenter = vec2(0.5)-st;
//   // pct = length(toCenter);
  
//   // c. The SQUARE ROOT of the vector
//   //    from the pixel to the center
//   // vec2 tC = vec2(0.5)-st;
//   // pct = sqrt(tC.x*tC.x+tC.y*tC.y);
  
//   vec3 color=vec3(pct);
  
//   gl_FragColor=vec4(color,1.);
// }
//#endregion

//#region -----------------------atan-----------------------
void main(){
  vec2 st = gl_FragCoord.xy/u_resolution.xy;
  st.x *= u_resolution.x/u_resolution.y;
  vec3 color = vec3(0.0);
  float d = 0.0;

  // Remap the space to -1. to 1.
  st = st *2.-1.;

  // Number of sides of your shape
  int N = 3;

  // Angle and radius from the current pixel
  float a = atan(st.x,st.y)+PI;
  float r = TWO_PI/float(N);

  // Shaping function that modulate the distance
  d = cos(floor(.5+a/r)*r-a)*length(st);

  color = vec3(1.0-smoothstep(.4,.41,d));
  // color = vec3(d);

  gl_FragColor = vec4(color,1.0);
}
//#endregion