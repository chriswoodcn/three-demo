precision mediump float;

attribute vec3 position;
attribute vec2 uv;

uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat4 modelMatrix;
uniform float uTime;

varying vec2 uUv;

void main() {
    uUv = uv;
    vec3 temp = position;
    temp.x += pow(sin(uTime), 2.0);
    temp.y += pow(1.0 - sin(uTime), 2.0);
    vec4 modelPosition = modelMatrix * vec4(temp, 1);
    gl_Position = projectionMatrix * viewMatrix * modelPosition;
}