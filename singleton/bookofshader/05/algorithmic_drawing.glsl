#ifdef GL_ES
precision mediump float;
#endif
#define PI 3.14159265359

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

//#region -------------------Plot a line------------------------
// Plot a line on Y using a value between 0.0-1.0
// float plot(vec2 st){
  //   return 1.-smoothstep(.0,.002,abs(st.y-st.x));
// }
// void main(){
  //   vec2 st=gl_FragCoord.xy/u_resolution;
  
  //   float y=st.x;
  
  //   vec3 color=vec3(y);
  
  //   // Plot a line
  //   float pct=plot(st);
  //   color=mix(color,vec3(0.,1.,0.),pct);
  //   // color=(1.-pct)*color+pct*vec3(0.,1.,0.);
  
  //   gl_FragColor=vec4(color,1.);
// }
//#endregion

//#region -------------------power a line------------------------
// float plot(vec2 st,float pct){
  //   return smoothstep(pct-.01,pct,st.y)-
  //   smoothstep(pct,pct+.01,st.y);
// }

// void main(){
  //   vec2 st=gl_FragCoord.xy/u_resolution;
  
  //   // float y = pow(st.x,5.0);
  //   // float y=exp(st.x)-1.0;//以自然常数e为底的指数函数 向下移动1.0才能看到
  //   float y=log(st.x)+1.;//对数函数 向上移动1.0才能看到
  //   // float y = sqrt(st.x);//平方根函数
  
  //   vec3 color=vec3(y);
  
  //   float pct=plot(st,y);
  //   color=mix(color,vec3(0.,1.,0.),pct);
  //   // color = (1.0-pct)*color+pct*vec3(0.0,1.0,0.0);
  
  //   gl_FragColor=vec4(color,1.);
// }
//#endregion

//#region -------------------step------------------------
// float plot(vec2 st, float pct){
  //   return  smoothstep( pct-0.02, pct, st.y) -
  //           smoothstep( pct, pct+0.02, st.y);
// }

// void main() {
  //     vec2 st = gl_FragCoord.xy/u_resolution;
  
  //     // Step will return 0.0 unless the value is over 0.5,
  //     // in that case it will return 1.0
  //     float y = step(0.5,st.x);
  
  //     vec3 color = vec3(y);
  
  //     float pct = plot(st,y);
  //     color = (1.0-pct)*color+pct*vec3(0.0,1.0,0.0);
  
  //     gl_FragColor = vec4(color,1.0);
// }
//#endregion

//#region -------------------smoothstep------------------------
// float plot(vec2 st,float pct){
  //   return smoothstep(pct-.02,pct,st.y)-
  //   smoothstep(pct,pct+.02,st.y);
// }

// void main(){
  //   vec2 st=gl_FragCoord.xy/u_resolution;
  
  //   // Smooth interpolation between 0.3 and 0.7
  //   float y=smoothstep(.3,.7,st.x);
  
  //   vec3 color=vec3(y);
  
  //   float pct=plot(st,y);
  //   color=(1.-pct)*color+pct*vec3(0.,1.,0.);
  
  //   gl_FragColor=vec4(color,1.);
// }
//#endregion

//#region -------------------sin------------------------
float plot(vec2 st,float pct){
  return smoothstep(pct-.02,pct,st.y)-
  smoothstep(pct,pct+.02,st.y);
}

void main(){
  vec2 st=gl_FragCoord.xy/u_resolution;
  
  // Smooth interpolation between 0.3 and 0.7
  // float y=sin(st.x);
  // float y=(sin(st.x+u_time*5.)+1.)/2.;
  // float y=sin(PI*st.x);
  // float y=sin(u_time*st.x);
  // float y=sin(st.x)*2.;
  // float y=abs(sin(st.x+u_time));
  // float y=fract(sin(st.x));
  // float y=ceil(sin(st.x+u_time));
  // float y=floor(sin(st.x+u_time));
  // float y=mod(st.x,.2);// 返回 x 对 0.2 取模的值
  // float y = sign(st.x);  // 提取 x 的正负号
  // float y=clamp(sin(st.x+u_time),0.,1.);// 把 x 的值限制在 0.0 到 1.0
  // float y = min(0.0,st.x);   // 返回 x 和 0.0 中的较小值
  float y=max(0.,st.x);// 返回 x 和 0.0 中的较大值
  
  vec3 color=vec3(y);
  
  float pct=plot(st,y);
  color=(1.-pct)*color+pct*vec3(0.,1.,0.);
  
  gl_FragColor=vec4(color,1.);
}
//#endregion