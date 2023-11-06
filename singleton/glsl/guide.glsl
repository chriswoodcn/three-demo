/*
webgl 自带的函数
1.角度相关的函数
  sin(x) 正弦函数
  asin(x) 反正切函数
  cos(x) 余弦函数
  acos(x) 反余弦函数
  tan(x)正切函数
  atan(x) 反正切含糊
  radians(x) 角度制转为弧度制
  degrees(x) 弧度转角度
2.数学函数
  pow(x,y) x 的y次方
  exp(x) e 的 x 次方
  log(x) 计算满足x等于e的y次方的值
  exp2(x) 计算2的x次方
  log2(x) 计算满足x等于2的y次方的值
  sqrt(x) 计算x的开方
  inversesqrt(x) 计算x的开方分之一
3.常用函数
  abs(x) 绝对值
  sign(x) 若 x>0，返回1.0；若x=0，返回0；若x<0，返回-1
  floor(x) x值 - > 向下取整
  ceil(x)  x值 - > 向上取整
  fract(x) 返回x的小数部分（取一个数的小数部分）
  mod(x,y) 取x除以y的余数 (相当于js中的 x%y的值)
  min(x,y) 取x和y的最小值
  max(x,y) 取x和y的最大值
  clamp(x,minVal,maxVal) x 小于 minVal 返回minVal;x 在 minVal 和 maxVal 之间返回 x;x 大于 maxVal 返回maxVal
  smoothstep(edge0,edge1,x) x<=edge0 => 0.0;x>=edge1 => 1.0;edge0<x<edge1 =>  平滑埃尔米特差值
4.几何函数
  length(x) 返回向量x的长度
  distance(x,y) 计算两个向量之间的距离
  dot(x,y) 向量x,y之间的点积
  cross(x,y) 向量x,y之间的叉积
  normalize(x)标准化向量，返回一个方向和x相同当长度为1的向量
  faceforward(N, I, Nref)	如果Nref和I的点积小于0，返回N；否则，返回-N；
  reflect(I,N) 返回反射向量
  refract(I,N,eta) 返回折射向量

webgl 中内置的绘制方式
1.顶点着色器： gl_Position
2.片原着色器：gl_FragColor
3.片原着色中忽略绘制：discard

cesium 中内置的一些变量和方法
1.czm_materialInput :  用作每个材质的czm_getMaterial函数的输入
  s：一维纹理坐标 r x 
  st：二维纹理坐标 rg xy
  str：三维纹理坐标 rgb xyz
2.czm_getDefaultMaterial(materialInput)：一个带有默认值的czm_material，每个材质的czm_getMaterial都应该使用这个默认材质作为它返回材质的基数
3.czm_material：保存可用于照明的材料信息，由所有czm_getMaterial函数返回
  diffuse：向各个方向均匀散射的入射光，也可以理解为就是展示的rgb 
  alpha：透明度
  emission：可以理解为发光强度
*/