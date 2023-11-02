import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls";
import RawVertexShader from "./wave/vertexShader.glsl";
import RawFragmentShader from "./wave/fragmentShader.glsl";
// 1.创建场景
const scene = new THREE.Scene();
// 坐标轴
const axesHelper = new THREE.AxesHelper(5);
axesHelper.setColors("#E63F32", "#FCC31F", "#1C90ED");
scene.add(axesHelper);
// 2.相机
const camera = new THREE.PerspectiveCamera(
  90,
  window.innerWidth / window.innerHeight,
  0.1,
  10000
);
camera.position.z = 1.1;
camera.position.x = 1.1;
camera.position.y = 1.1;
// 3.环境光
const light = new THREE.AmbientLight(0xffffff, 0.5); // 柔和的白光
scene.add(light);
// 导入纹理
const textureLoader = new THREE.TextureLoader();
const texture = textureLoader.load("assets/flag.jpg");
// const material = new THREE.MeshBasicMaterial({ texture: texture });
const material = new THREE.RawShaderMaterial({
  vertexShader: RawVertexShader,
  fragmentShader: RawFragmentShader,
  // wireframe: true,
  side: THREE.DoubleSide,
  uniforms: {
    uTime: {
      value: 0,
    },
    uTexture: {
      value: texture,
    },
  },
});
const floor = new THREE.Mesh(new THREE.PlaneGeometry(1, 1, 64, 64), material);
scene.add(floor);
// 4.渲染到页面
const renderer = new THREE.WebGLRenderer();
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setPixelRatio(window.devicePixelRatio);
document.getElementsByTagName("body")[0].appendChild(renderer.domElement);
// 创建轨道控制器
const controls = new OrbitControls(camera, renderer.domElement);
// 时钟
const clock = new THREE.Clock();
function animate() {
  requestAnimationFrame(animate);
  let delta = clock.getDelta();
  let elapsed = clock.getElapsedTime();
  console.log(elapsed);
  material.uniforms.uTime.value = elapsed;
  // console.log("间隔时间:" + delta);
  camera.updateProjectionMatrix();
  renderer.render(scene, camera);
}
animate();
