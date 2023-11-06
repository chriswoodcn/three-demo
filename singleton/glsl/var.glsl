precision mediump float;
uniform vec2 u_resolution;
void main(){
    // 0,1  1,1
    // 0,0  1,0
    vec2 uv=gl_FragCoord.xy/u_resolution;
    gl_FragColor=vec4(uv,0.,1.);
}