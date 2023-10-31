/** @type{HTMLCanvasElement} */
const canvasEl = document.getElementById("canvas");
console.log(canvasEl);
function resizeCanvasEl() {
  canvasEl.width = window.innerWidth;
  canvasEl.height = window.innerHeight;
}
resizeCanvasEl();
// window.addEventListener("resize".resizeCanvasEl);
// 获取gl上下文
/** @type{!WebGLRenderingContext} */
var gl = canvasEl.getContext("webgl");
// 第一次创建webgl绘图上下文 需要设置视口大小
gl.viewport(0, 0, canvasEl.width, canvasEl.height);
console.log(gl);
// 创建顶点着色器
/** @type{WebGLShader} */
var vertexShader = gl.createShader(gl.VERTEX_SHADER);
// 创建顶点着色器源码
gl.shaderSource(
  vertexShader,
  `
  attribute vec4 a_Position;
  void main() {
        gl_Position = a_Position;
  }
  `
);
// 编译顶点着色器
gl.compileShader(vertexShader);
// 创建片元着色器
var fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
// 创建片元着色器源码
gl.shaderSource(
  fragmentShader,
  `
    void main() {
            gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
    `
);
// 编译片元着色器
gl.compileShader(fragmentShader);
// 创建程序 连接顶点着色器和片元着色器
var program = gl.createProgram();
gl.attachShader(program, vertexShader);
gl.attachShader(program, fragmentShader);
// 链接程序
gl.linkProgram(program);
// 使用program渲染
gl.useProgram(program);

// 传入数据
// 创建顶点缓冲区对象
var vertexBuffer = gl.createBuffer();
// 绑定顶点缓冲区对象
gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
// 向顶点缓冲区传入数据
var vertices = new Float32Array([0.0, 0.5, -0.5, -0.5, 0.5, -0.5]);

gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);
// 获取顶点着色器中的a_Position变量的位置
var a_Position = gl.getAttribLocation(program, "a_Position");
// 将顶点缓冲区对象分配给a_Position变量
gl.vertexAttribPointer(a_Position, 2, gl.FLOAT, false, 0, 0);
// 启用顶点着色器a_Position变量
gl.enableVertexAttribArray(a_Position);
// 绘制
gl.drawArrays(gl.TRIANGLES, 0, 3);
