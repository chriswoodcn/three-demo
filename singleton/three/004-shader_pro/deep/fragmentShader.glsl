precision mediump float;

varying vec2 uUv;

void main() {
    gl_FragColor = vec4(uUv, 0.0, 1.0);
}