<!--
 * @Author: chriswoodcn
 * @Email: chriswoodcn@aliyun.com
 * @Date: 2023-10-26 08:06:24
 * @LastEditors: chriswoodcn
 * @LastEditTime: 2023-10-26 12:13:03
 * @Description: startup-1
 * 
 * Copyright (c) 2023 by chriswoodcn, All Rights Reserved. 
-->
<script setup>
import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { onMounted, ref } from "vue";
// 创建场景
const scene = new THREE.Scene();
const renderer = new THREE.WebGLRenderer();
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
directionalLight.castShadow = true;
directionalLight.shadow.mapSize.width = 512; // default
directionalLight.shadow.mapSize.height = 512; // default
directionalLight.shadow.radius = 10;
scene.add(directionalLight);
const helper = new THREE.CameraHelper(directionalLight.shadow.camera);
scene.add(helper);
// 创建轨道控制器
const controls = new OrbitControls(camera, renderer.domElement);
controls.update();
// scene添加mesh
const boxGeometry = new THREE.SphereGeometry(5, 10, 10);
const boxMaterial = new THREE.MeshStandardMaterial({
  color: 0xf5f5f5,
  roughness: 1,
});
const cube = new THREE.Mesh(boxGeometry, boxMaterial);
cube.castShadow = true;
cube.receiveShadow = false;

scene.add(cube);
const planeGeometry = new THREE.PlaneGeometry(50, 50);
const planeMaterial = new THREE.MeshStandardMaterial({ color: 0xffffff });
const plane = new THREE.Mesh(planeGeometry, planeMaterial);
plane.position.set(0, -10, 0);
plane.receiveShadow = true;
plane.rotateX(-Math.PI / 2);
scene.add(plane);

function animate() {
  requestAnimationFrame(animate);
  controls.update();
  renderer.render(scene, camera);
}

animate();
const mapRef = ref();
onMounted(() => {
  mapRef.value.appendChild(renderer.domElement);
});
</script>

<template>
  <div ref="mapRef" class="w-full h-full bg-blueGray"></div>
</template>

<style scoped></style>
