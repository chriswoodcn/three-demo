precision mediump float;
uniform vec2 u_resolution;
float circle(vec2 uv,vec2 center,float d){
    return length(uv-center)-d;
}
void main(){
    vec2 uv=gl_FragCoord.xy/u_resolution;
    float d=circle(uv,vec2(.5,.5),.1);
    d=step(0.,d);
    vec3 color=vec3(d);
    gl_FragColor=vec4(color,1.);
}