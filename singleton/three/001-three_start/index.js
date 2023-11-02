console.log("init script");
import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls";
// 1.创建场景
const scene = new THREE.Scene();
// const axesHelper = new THREE.AxesHelper(30);
// axesHelper.setColors("#E63F32", "#FCC31F", "#1C90ED");
// scene.add(axesHelper);
// 2.创建相机
const camera = new THREE.PerspectiveCamera(
  90,
  window.innerWidth / window.innerHeight,
  0.1,
  10000
);
camera.position.z = 10;
// 3.环境光
const light = new THREE.AmbientLight(0xffffff, 0.5); // 柔和的白光
scene.add(light);

const cubeGeometry = new THREE.BoxGeometry(1, 1, 1);
const material = new THREE.MeshBasicMaterial({
  color: "#666666",
  wireframe: true,
});
const redMaterial = new THREE.MeshBasicMaterial({
  color: "#ff0000",
});
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

const params = {
  count: 5000,
  radius: 10,
  color: "#ffff00",
  size: 0.01,
  branch: 3,
  endColor: "#113984",
};
let galaxyGeometry, galaxyMaterial, galaxyPoints;
function createGalaxy2() {
  const textureLoader = new THREE.TextureLoader();
  const pointsTexture = textureLoader.load("assets/points/star.png");
  const positions = new Float32Array(params.count * 3);
  const colors = new Float32Array(params.count * 3);
  const centerColor = new THREE.Color(params.color);
  const endColor = new THREE.Color(params.endColor);
  for (let i = 0; i < params.count; i++) {
    const current = i * 3;
    let angle = (i % params.branch) * ((Math.PI * 2) / params.branch);
    const distance0 = Math.random() * params.radius;
    const distance = distance0 * Math.pow(Math.random() - 1, 3);
    angle += distance * 0.3;
    let rangeX =
      ((Math.random() * 4 - 2) *
        Math.pow(Math.random() * 2 - 1, 3) *
        (params.radius - distance)) /
      params.radius;
    let rangeY =
      ((Math.random() * 4 - 2) *
        Math.pow(Math.random() * 2 - 1, 3) *
        (params.radius - distance)) /
      params.radius;
    let rangeZ =
      ((Math.random() * 4 - 2) *
        Math.pow(Math.random() * 2 - 1, 3) *
        (params.radius - distance)) /
      params.radius;
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
  galaxyGeometry = new THREE.BufferGeometry();
  galaxyGeometry.setAttribute(
    "position",
    new THREE.BufferAttribute(positions, 3)
  );
  galaxyGeometry.setAttribute("color", new THREE.BufferAttribute(colors, 3));
  galaxyMaterial = new THREE.PointsMaterial({
    // color: new THREE.Color(params.color),
    size: params.size,
    sizeAttenuation: true,
    texture: pointsTexture,
  });
  galaxyPoints = new THREE.Points(galaxyGeometry, galaxyMaterial);
  galaxyPoints.position.setY(-30);
  galaxyPoints.rotateOnAxis(new THREE.Vector3(1, 0, 0), 3);
  scene.add(galaxyPoints);
}
createGalaxy2();
console.log(galaxyPoints.position);
console.log(camera.position);

const pointLightGroup = new THREE.Group();
let light1, light1Sphere, plane;
function createPointLight() {
  const planeGeometry = new THREE.PlaneGeometry(20, 20);
  const planeMaterial = new THREE.MeshStandardMaterial({
    color: 0xffffff,
  });
  plane = new THREE.Mesh(planeGeometry, planeMaterial);
  plane.receiveShadow = true;
  plane.rotateX(-Math.PI / 2);
  plane.rotateY(0.1);
  plane.position.set(0, -3, 0);
  pointLightGroup.add(plane);

  const sphereGeometry = new THREE.SphereGeometry(1, 30, 30);
  const sphereMaterial = new THREE.MeshStandardMaterial({
    color: 0xffffff,
  });
  const sphere = new THREE.Mesh(sphereGeometry, sphereMaterial);
  sphere.castShadow = true;
  sphere.receiveShadow = true;
  sphere.position.setY(-1);
  pointLightGroup.add(sphere);

  light1 = new THREE.PointLight(0xff0000, 10, 100);
  light1.castShadow = true;
  light1Sphere = new THREE.Mesh(
    new THREE.SphereGeometry(0.2, 30, 30),
    new THREE.MeshBasicMaterial({ color: 0xff0000 })
  );
  light1.add(light1Sphere);
  light1.position.set(2, 0, 2);
  pointLightGroup.add(light1);

  pointLightGroup.position.setY(-60);
  scene.add(pointLightGroup);
}
createPointLight();

const renderer = new THREE.WebGLRenderer();
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setPixelRatio(window.devicePixelRatio);
// renderer.setClearAlpha(0);
console.log(document.getElementsByTagName("body")[0]);
document.getElementsByTagName("body")[0].appendChild(renderer.domElement);
// 创建轨道控制器
const controls = new OrbitControls(camera, renderer.domElement);
controls.enableZoom = false;
controls.minZoom = 1;
controls.maxZoom = 1;
const clock = new THREE.Clock();

function animate() {
  let time = clock.getDelta();
  let elapsedTime = clock.getElapsedTime();
  cubeGroup.rotateOnAxis(new THREE.Vector3(1, 0, 0), time / 5);
  cubeGroup.rotateOnAxis(new THREE.Vector3(0, 1, 0), time / 5);
  cubeGroup.rotateOnAxis(new THREE.Vector3(0, 0, 1), time / 5);
  galaxyPoints.rotateOnAxis(new THREE.Vector3(0, 1, 0), time);
  light1.position.x = Math.sin(elapsedTime * 3) * 2;
  light1.position.y = Math.cos(elapsedTime) * 2;
  light1.position.z = Math.cos(elapsedTime * 3) * 2;
  plane.rotateOnAxis(new THREE.Vector3(0, 0, 1), time / 5);
  // 根据滚动的scrollY 去设置相机移动的位置
  camera.position.setY(-(window.scrollY / window.innerHeight) * 30);
  camera.lookAt(0, -(window.scrollY / window.innerHeight) * 30, 0);
  camera.updateProjectionMatrix();
  renderer.render(scene, camera);
  requestAnimationFrame(animate);
}

let currentPage = 1;
function pageHandler(e) {
  let page = Math.floor(window.scrollY / window.innerHeight) + 1;
  // console.log("page: " + page);
  // console.log("rate: " + window.scrollY / window.innerHeight);
  if (currentPage != page) {
    currentPage = page;
    console.log("page: " + page);
  }
}
window.addEventListener("scroll", pageHandler);

animate();
