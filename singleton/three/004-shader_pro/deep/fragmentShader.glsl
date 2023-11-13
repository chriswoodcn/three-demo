precision mediump float;

uniform float uTime;
uniform vec2 uWindow;
uniform vec2 uMouse;

varying vec2 vUv;

vec2 rotate(vec2 uv,float rotation,vec2 mid){
    return vec2(
        cos(rotation)*(uv.x-mid.x)+sin(rotation)*(uv.y-mid.y)+mid.x,
        cos(rotation)*(uv.y-mid.y)-sin(rotation)*(uv.x-mid.x)+mid.y
    );
}

void main(){
    // 根据鼠标移动位置 进行变色
    // vec3 color = vec3(uMouse.x / uWindow.x, uMouse.y / uWindow.y, 0.0);
    // gl_FragColor = vec4(color, 1.0);
    
    // Mix() 混合   mix(x,y,a)  a控制混合结果 return x(1-a) +y*a  返回线性混合的值
    // gl_FragCoord 是GLSL 自带属性，为 vec4，
    // gl_FragCoord存储了活动线程正在处理的像素或屏幕碎片的坐标。有了它我们就知道了屏幕上的哪一个线程正在运转
    // 分别对应x, y, z 以及1/w，w 为坐标经过投影矩阵变化后的新的坐标
    // gl_FragCoord.z / gl_FragCoord.w 可以获得当前片元距离相机的距离
    // vec2 uv = gl_FragCoord.xy/uWindow;
    // vec3 color = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), uv.x);
    // 等同于下面的写法
    // vec3 color = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(uv.y, uv.y, uv.y));
    // float stren = (sin(uTime*10.0) + 1.1)/2.0;
    // gl_FragColor = vec4(color, 1);
    // gl_FragColor = vec4(vUv, 0.0, 1.0);
    
    // 渐变 x 0-1从左到右
    // float stength = vUv.x;
    // gl_FragColor = vec4(stength, stength ,stength, 1.0);
    
    // 渐变 y 0-1从下到上
    // float stength = vUv.y;
    // gl_FragColor = vec4(stength, stength ,stength, 1.0);
    
    // 取模 达到反复的效果 条纹
    // float stength = mod(vUv.y * 10.0,1.0);
    // gl_FragColor = vec4(stength, stength ,stength, 1.0);
    
    // 取模 相乘
    // float stength = mod(vUv.x * 10.0, 1.0) * mod(vUv.y * 10.0, 1.0);
    // gl_FragColor = vec4(stength, stength ,stength, 1.0);
    
    // 取模 相减
    // float stength = mod(vUv.x * 10.0, 1.0) - mod(vUv.y * 10.0, 1.0);
    // gl_FragColor = vec4(stength, stength ,stength, 1.0);
    
    // step(e,x) 如果x<e 返回0.0 否则返回1.0
    // float stength = step(0.5, mod(vUv.x * 10.0, 1.0));
    // gl_FragColor = vec4(stength, stength ,stength, 1.0);
    
    // step 相乘
    // float stength = step(0.5, mod(vUv.x * 5.0, 1.0)) * step(0.5, mod(vUv.y * 5.0, 1.0));
    
    //绝对值 abs
    // float stength=abs(vUv.x-.5);
    // float stength=step(.2,abs(vUv.x-.5));
    // stength*=step(.2,abs(vUv.y-.5));
    // gl_FragColor=vec4(stength,stength,stength,1.);
    
    //最小值 min
    // float stength=min(abs(vUv.x-.5),abs(vUv.y-.5));
    // gl_FragColor=vec4(stength,stength,stength,1.);
    
    //最大值 max
    // float stength=1.-max(abs(vUv.x-.5),abs(vUv.y-.5));
    // gl_FragColor=vec4(stength,stength,stength,1.);
    
    //条纹渐变 floor取整
    // float stength=floor(vUv.x*10.)/10.;
    // stength+=floor(vUv.y*10.)/10.;
    // stength*=floor(vUv.x*10.)/10.;
    // stength*=floor(vUv.y*10.)/10.;
    // gl_FragColor=vec4(stength,1.-stength,1.-stength,1.);
    
    // 随机
    // float stength=fract(sin(vUv.x)*100000.);
    // float param=floor(vUv.x*10.)/10.+floor(vUv.y*10.)/10.;
    // float stength=fract(sin(dot(vec2(param,param),vec2(12.9898,78.233)))*43758.5453123);
    // float stength2=.5-fract(sin(dot(vec2(param,param),vec2(12.9898,78.233)))*43758.5453123);
    // float stength3=.5-fract(sin(dot(vec2(param,param),vec2(12.9898,78.233)))*43758.5453123);
    // gl_FragColor=vec4(stength,stength,stength,1.);
    
    // length 返回向量长度
    // float stength=length(vUv);
    // gl_FragColor=vec4(stength,stength,stength,1.);
    
    // distance 计算两个向量的距离
    // float stength=1.-distance(vUv,vec2(.5,.5));
    // gl_FragColor=vec4(stength,stength,stength,1.);
    
    // 根据相除 实现星星
    // vec2 rotateUv=rotate(vUv,(uTime*2.0),vec2(.5,.5));
    // float stength=.3/distance(vec2(rotateUv.x,(rotateUv.y-.5)*5.+.5),vec2(.5,.5))-1.;
    // stength+=.3/distance(vec2(rotateUv.y,(rotateUv.x-.5)*5.+.5),vec2(.5,.5))-1.;
    // gl_FragColor=vec4(stength,stength,stength,1);
    
    // 绘制圆
    // float strength=1.-step(.5,distance(vUv,vec2(.5))+.05);
    // 绘制圆环
    // float strength=1.-step(.5,distance(vUv,vec2(.5)));
    // strength*=step(.5,distance(vUv,vec2(.5))+.25);
    //渐变环
    // float strength=abs(distance(vUv,vec2(.5))-.25);
    // 绘制圆环
    // float strength=1.-step(.1,abs(distance(vUv,vec2(.5))-.25));
    // 波浪环
    vec2 waveUv=vec2(
        vUv.x+sin(vUv.y*mod(uTime*2.,3.)*10.)*.1,
        vUv.y+sin(vUv.x*mod(uTime*2.,3.)*10.)*.1
    );
    float strength=1.-step(.01,abs(distance(waveUv,vec2(.5))-.25));
    // 取模 多个圆环
    // float strength=1.-step(.2,mod(abs(distance(vUv,vec2(.5))-.25*uTime)*20.,1.));
    
    gl_FragColor=vec4(strength,strength,strength,1);
    
}