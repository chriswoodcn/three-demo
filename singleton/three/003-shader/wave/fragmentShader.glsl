precision mediump float;
varying vec2 vUv;
varying float vElevation;
// 采样纹理
uniform sampler2D uTexture;

void main() {
    // float calc_vElevation = vElevation + 0.05 * 10.0;
    // gl_FragColor = vec4(1.0 * calc_vElevation, 0.0, 0.0, 1.0);

    // 根据UV取出对应的颜色
    vec4 textureColor = texture2D(uTexture, vUv);
    gl_FragColor = textureColor;
}