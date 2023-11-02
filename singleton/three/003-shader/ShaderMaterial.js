/*
 * @Author: chriswoodcn
 * @Email: chriswoodcn@aliyun.com
 * @Date: 2023-11-02 19:23:34
 * @LastEditors: chriswoodcn
 * @LastEditTime: 2023-11-02 21:11:47
 * @FilePath: \three-demo\singleton\three\003-shader\ShaderMaterial.js
 * @Description: 
 * Copyright (c) 2023 by chriswoodcn, All Rights Reserved. 
 */
import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls";
import BasicVertexShader from "./basic/vertexShader.glsl";
import BasicFragmentShader from "./basic/fragmentShader.glsl";
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
camera.position.z = 10;
// 3.环境光
const light = new THREE.AmbientLight(0xffffff, 0.5); // 柔和的白光
scene.add(light);
// const material = new THREE.MeshBasicMaterial({ color: "#00ff00" });
const material = new THREE.ShaderMaterial({
  vertexShader: BasicVertexShader,
  fragmentShader: BasicFragmentShader,
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
  let delta = clock.getDelta();
  // console.log("间隔时间:" + delta);
  camera.updateProjectionMatrix();
  renderer.render(scene, camera);
  requestAnimationFrame(animate);
}
animate();
