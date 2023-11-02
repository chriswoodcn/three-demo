void main() {
    // 没有转换的坐标
    // gl_Position = vec4(position, 1); 
    // 转换后的坐标 投影矩阵 视图矩阵 模型矩阵 顶点矩阵
    gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1);
}