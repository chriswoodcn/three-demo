precision mediump float;

attribute vec3 position;
attribute vec2 uv;

uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat4 modelMatrix;

varying vec2 uUv;

void main() {
    uUv = uv;
    vec4 modelPosition = modelMatrix * vec4(position, 1);
    gl_Position = projectionMatrix * viewMatrix * modelPosition;
}