import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

// 1.创建场景
const scene = new THREE.Scene();
export const renderer = new THREE.WebGLRenderer();
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setClearAlpha(0);
// 添加辅助坐标轴
const axesHelper = new THREE.AxesHelper(5);
scene.add(axesHelper);
// 2.创建相机
const camera = new THREE.PerspectiveCamera(
  75,
  window.innerWidth / window.innerHeight,
  0.1,
  10000
);
camera.position.set(0, 0, 15);
// 3.环境光
const light = new THREE.AmbientLight(0x404040); // 柔和的白光
scene.add(light);
// 创建轨道控制器
const controls = new OrbitControls(camera, renderer.domElement);
const cubeGeometry = new THREE.BoxGeometry(1, 1, 1);
const material = new THREE.MeshBasicMaterial({
  color: "#666666",
  wireframe: true,
});
const redMaterial = new THREE.MeshBasicMaterial({
  color: "#ff0000",
});
const cubeArr = [];
const cubeGroup = new THREE.Group();
// 创建1000个立方体
for (let i = -5; i < 5; i++) {
  for (let j = -5; j < 5; j++) {
    for (let v = -5; v < 5; v++) {
      const cube = new THREE.Mesh(cubeGeometry, material);
      cube.position.set(i, j, v);
      // cubeArr.push(cube);
      cubeGroup.add(cube);
    }
  }
}
scene.add(cubeGroup);

function simpleRaycaster() {
  // 创建投射光线
  const raycaster = new THREE.Raycaster();
  // 鼠标的二维对象
  const mouse = new THREE.Vector2();
  // 监听鼠标的位置
  window.addEventListener("click", function (e) {
    console.log(e);
    mouse.x = (e.clientX / this.window.innerWidth) * 2 - 1;
    mouse.y = 1 - (e.clientY / this.window.innerHeight) * 2;
    raycaster.setFromCamera(mouse, camera);
    let res = raycaster.intersectObjects(cubeGroup.children);
    console.log(res);
    if (res.length) {
      res[0].object.material = redMaterial;
    }
  });
}
simpleRaycaster();
const clock = new THREE.Clock();
export const animate = function () {
  let time = clock.getDelta();
  cubeGroup.rotateOnAxis(new THREE.Vector3(1, 0, 0), time / 5);
  cubeGroup.rotateOnAxis(new THREE.Vector3(0, 1, 0), time / 5);
  cubeGroup.rotateOnAxis(new THREE.Vector3(0, 0, 1), time / 5);
  // cubeGroup.rotateX(time * 0.002);
  // cubeGroup.rotateZ(time * 0.001);
  requestAnimationFrame(animate);
  // controls.update();
  renderer.render(scene, camera);
};
