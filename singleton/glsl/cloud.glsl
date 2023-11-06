precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

float circle(vec2 uv,vec2 center,float d){
    return length(uv-center)-d;
}
float cloud(vec2 uv,vec2 center,float d){
    float step=1.2;
    float c1=circle(uv,vec2(center.x-d*.9*1.*step,center.y),d*.9);
    float c2=circle(uv,vec2(center.x-d*.8*2.*step,center.y),d*.8);
    float c3=circle(uv,vec2(center.x,center.y),d);
    float c4=circle(uv,vec2(center.x+d*.9*1.*step,center.y),d*.9);
    float c5=circle(uv,vec2(center.x+d*.8*2.*step,center.y),d*.8);
    return min(c5,min(c4,min(c3,min(c1,c2))));
}
void main(){
    // vec2 uv=gl_FragCoord.xy/u_resolution;
    // float d=cloud(uv,vec2(.5,.5),.05);
    // d=1.-step(0.,d);
    // vec3 color=vec3(d);
    // gl_FragColor=vec4(color,1.);
    
    // //图层叠加
    // vec2 uv=gl_FragCoord.xy/u_resolution;
    // // backCol 代表背景颜色
    // vec3 backCol=vec3(.2078,.7765,1.);
    // // col表示最终颜色 先将背景颜色赋给最终颜色
    // vec3 col=backCol;
    // float d=cloud(uv,vec2(.5,.5),.05);
    // d=1.-step(0.,d);
    // vec3 cloudCol=vec3(d);
    // // 将云朵的颜色叠加在背景色上
    // col=mix(col,cloudCol,d);
    // gl_FragColor=vec4(col,1.);
    
    //让顶部变成蓝色 底部变成黄色  通过y坐标来进行插值。修改代码如下
    vec2 uv=gl_FragCoord.xy/u_resolution;
    uv.x+=u_time*.3;
    uv.x=fract(uv.x);
    vec3 backCol=vec3(.2078,.7765,1.);
    vec3 backCol2=vec3(.7412,.4353,.0667);
    float gradient=smoothstep(.1,.8,uv.y);
    // backCol=mix(backCol2,backCol,uv.y);
    backCol=mix(backCol2,backCol,gradient);
    vec3 col=backCol;
    float d=cloud(uv,vec2(.5,.5),.05);
    d=1.-step(0.,d);
    vec3 cloudCol=vec3(d);
    col=mix(col,cloudCol,d);
    gl_FragColor=vec4(col,1.);
}