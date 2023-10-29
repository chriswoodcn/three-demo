import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
// 创建场景
const scene = new THREE.Scene();
export const renderer = new THREE.WebGLRenderer();
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap; // default THREE.PCFShadowMap
renderer.setSize(window.innerWidth, window.innerHeight);
// 添加辅助坐标轴
const axesHelper = new THREE.AxesHelper(3);
scene.add(axesHelper);
// 创建相机
const camera = new THREE.PerspectiveCamera(
  75,
  window.innerWidth / window.innerHeight,
  0.1,
  1000
);
camera.position.set(0, 0, 50);
// 环境光
const light = new THREE.AmbientLight(0x404040); // 柔和的白光
scene.add(light);
// 平行光，强度为 0.5。
const directionalLight = new THREE.DirectionalLight(0xffffff, 5.0);
directionalLight.position.set(5, 5, 5);
scene.add(directionalLight);
// 创建轨道控制器
const controls = new OrbitControls(camera, renderer.domElement);
controls.update();
// 加载纹理
const loader = new THREE.CubeTextureLoader();
const textureCube = loader.load([
  "assets/Park3Med/px.jpg",
  "assets/Park3Med/nx.jpg",
  "assets/Park3Med/py.jpg",
  "assets/Park3Med/ny.jpg",
  "assets/Park3Med/pz.jpg",
  "assets/Park3Med/nz.jpg",
]);
// const textureCube = loader.load([
//   "assets/Park2/posx.jpg",
//   "assets/Park2/negx.jpg",
//   "assets/Park2/posy.jpg",
//   "assets/Park2/negy.jpg",
//   "assets/Park2/posz.jpg",
//   "assets/Park2/negz.jpg",
// ]);
scene.background = textureCube;
// scene添加mesh
const boxGeometry = new THREE.SphereGeometry(5, 30, 30);
const boxMaterial = new THREE.MeshBasicMaterial({
  envMap: textureCube,//添加环境反射
});
const cube = new THREE.Mesh(boxGeometry, boxMaterial);
scene.add(cube);

export const animate = function () {
  requestAnimationFrame(animate);
  controls.update();
  renderer.render(scene, camera);
};
