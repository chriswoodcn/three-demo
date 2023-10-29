import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

// 1.创建场景
const scene = new THREE.Scene();
export const renderer = new THREE.WebGLRenderer();
renderer.setSize(window.innerWidth, window.innerHeight);
// 添加辅助坐标轴
const axesHelper = new THREE.AxesHelper(5);
scene.add(axesHelper);
// 2.创建相机
const camera = new THREE.PerspectiveCamera(
  75,
  window.innerWidth / window.innerHeight,
  0.1,
  1000
);
camera.position.set(10, 10, 10);
// 3.环境光
const light = new THREE.AmbientLight(0x404040); // 柔和的白光
scene.add(light);
// 创建轨道控制器
const controls = new OrbitControls(camera, renderer.domElement);

export const animate = function () {
  requestAnimationFrame(animate);
  controls.update();
  renderer.render(scene, camera);
};

function createSimplePoints() {
  // 使用sphereGeometry生成点集;
  const sphereGeometry = new THREE.SphereGeometry(1, 20, 20);
  const pointMaterial = new THREE.PointsMaterial({
    color: 0xff0000,
    size: 0.05,
    sizeAttenuation: false,
  });
  const points = new THREE.Points(sphereGeometry, pointMaterial);
  scene.add(points);
}

function createCollectionPoints() {
  // 自定义生成点集
  const pointsGeometry = new THREE.BufferGeometry();
  const count = 1000;
  const positions = new Float32Array(count * 3);
  for (let i = 0; i < count * 3; i++) {
    positions[i] = Math.random() * ((i % 5) + 1);
  }
  pointsGeometry.setAttribute(
    "position",
    new THREE.BufferAttribute(positions, 3)
  );
  const pointsMaterial = new THREE.PointsMaterial({
    color: 0xffff00,
    size: () => Math.random() * 100,
  });
  const points = new THREE.Points(pointsGeometry, pointsMaterial);
  scene.add(points);
}
const params = {
  count: 50000,
  radius: 50,
  color: "#ffff00",
  size: 0.02,
  branch: 3,
  endColor: "#113984",
};
let geometry, material, points;

// createCollectionPoints();
function createGalaxy1() {
  const positions = new Float32Array(params.count * 3);
  for (let i = 0; i < params.count; i++) {
    const current = i * 3;
    const angle = (i % params.branch) * ((Math.PI * 2) / params.branch);
    const distance = Math.random() * params.radius;
    positions[current] = Math.sin(angle) * distance;
    positions[current + 1] = 0;
    positions[current + 2] = Math.cos(angle) * distance;
  }
  geometry = new THREE.BufferGeometry();
  geometry.setAttribute("position", new THREE.BufferAttribute(positions, 3));
  material = new THREE.PointsMaterial({
    color: new THREE.Color(params.color),
    size: params.size,
    sizeAttenuation: true,
  });
  const points = new THREE.Points(geometry, material);
  scene.add(points);
}
// createGalaxy1();

function createGalaxy2() {
  const textureLoader = new THREE.TextureLoader();
  const pointsTexture = textureLoader.load("assets/points/star.png");
  // const pointsTexture2 = textureLoader.load("assets/points/star2.png");
  const positions = new Float32Array(params.count * 3);
  const colors = new Float32Array(params.count * 3);
  const centerColor = new THREE.Color(params.color);
  const endColor = new THREE.Color(params.endColor);
  for (let i = 0; i < params.count; i++) {
    const current = i * 3;
    let angle = (i % params.branch) * ((Math.PI * 2) / params.branch);
    const distance0 =
      Math.random() * params.radius
    const distance = distance0 * Math.pow(Math.random() - 1, 3);
    angle += distance * 0.3;
    let rangeX =
      ((Math.random() * 10 - 5) *
        Math.pow(Math.random() * 2 - 1, 3) *
        (params.radius - distance)) /
      params.radius;
    let rangeY =
      ((Math.random() * 10 - 5) *
        Math.pow(Math.random() * 2 - 1, 3) *
        (params.radius - distance)) /
      params.radius;
    let rangeZ =
      ((Math.random() * 10 - 5) *
        Math.pow(Math.random() * 2 - 1, 3) *
        (params.radius - distance)) /
      params.radius;

    // let rangeX =
    //   ((Math.random() * 10 - 5) *
    //     Math.pow(Math.random() * 2 - 1, 3) *
    //     distance) /
    //   params.radius;
    // let rangeY =
    //   ((Math.random() * 10 - 5) *
    //     Math.pow(Math.random() * 2 - 1, 3) *
    //     distance) /
    //   params.radius;
    // let rangeZ =
    //   ((Math.random() * 10 - 5) *
    //     Math.pow(Math.random() * 2 - 1, 3) *
    //     distance) /
    //   params.radius;
    positions[current] = Math.sin(angle) * distance + rangeX;
    positions[current + 1] = 0 + rangeY;
    positions[current + 2] = Math.cos(angle) * distance + rangeZ;

    // 混合颜色
    const mixColor = centerColor.clone();
    mixColor.lerp(endColor, distance0 / params.radius);
    colors[current] = mixColor.r;
    colors[current + 1] = mixColor.g;
    colors[current + 2] = mixColor.b;
  }
  geometry = new THREE.BufferGeometry();
  geometry.setAttribute("position", new THREE.BufferAttribute(positions, 3));
  geometry.setAttribute("color", new THREE.BufferAttribute(colors, 3));
  material = new THREE.PointsMaterial({
    // color: new THREE.Color(params.color),
    size: params.size,
    sizeAttenuation: true,
    map: pointsTexture,
    vertexColors: true,
  });
  const points = new THREE.Points(geometry, material);
  scene.add(points);
}
createGalaxy2();
