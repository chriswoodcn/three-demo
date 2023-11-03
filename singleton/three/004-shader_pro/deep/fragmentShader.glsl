precision mediump float;

uniform float uTime;
uniform vec2 uWindow;
uniform vec2 uMouse;

varying vec2 uUv;

void main() {
    // gl_FragColor = vec4(uUv, 0.0, 1.0);

    // 渐变 x 0-1从左到右
    // float stength = uUv.x;
    // gl_FragColor = vec4(stength, stength ,stength, 1.0);

    // 渐变 y 0-1从下到上
    // float stength = uUv.y;
    // gl_FragColor = vec4(stength, stength ,stength, 1.0);

    // 取模 条纹
    // float stength = mod(uUv.x * 10.0,1.0);
    // gl_FragColor = vec4(stength, stength ,stength, 1.0);

    // 取模 相乘
    // float stength = mod(uUv.x * 10.0, 1.0) * mod(uUv.y * 10.0, 1.0);
    // gl_FragColor = vec4(stength, stength ,stength, 1.0);

    // 取模 相减
    // float stength = mod(uUv.x * 10.0, 1.0) - mod(uUv.y * 10.0, 1.0);
    // gl_FragColor = vec4(stength, stength ,stength, 1.0);

    // step
    // float stength = step(0.5, mod(uUv.x * 10.0, 1.0));
    // gl_FragColor = vec4(stength, stength ,stength, 1.0);

    // step 相乘
    // float stength = step(0.5, mod(uUv.x * 5.0, 1.0)) * step(0.5, mod(uUv.y * 5.0, 1.0));

    // gl_FragColor = vec4(stength, stength ,stength, 1.0);
    // 根据鼠标移动位置 进行变色
    // vec3 color = vec3(uMouse.x / uWindow.x, uMouse.y / uWindow.y, 0.0);
    // gl_FragColor = vec4(color, 1.0);

    // Mix() 混合   mix(x,y,a)  a控制混合结果 return x(1-a) +y*a  返回线性混合的值
    // gl_FragCoord 是GLSL 自带属性，为 vec4，分别对应x, y, z 以及1/w，w 为坐标经过投影矩阵变化后的新的坐标
    // gl_FragCoord.z / gl_FragCoord.w 可以获得当前片元距离相机的距离
    vec2 uv = gl_FragCoord.xy/uWindow;
    vec3 color = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), uv.y);
    // 等同于下面的写法
    // vec3 color = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(uv.y, uv.y, uv.y));
    float stren = (sin(uTime*10.0) + 1.1)/2.0;
    gl_FragColor = vec4(color, stren);
}