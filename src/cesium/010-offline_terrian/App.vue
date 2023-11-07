<!--
 * @Author: chriswoodcn
 * @Email: chriswoodcn@aliyun.com
 * @Date: 2023-11-08 07:02:05
 * @LastEditors: chriswoodcn
 * @LastEditTime: 2023-11-08 07:03:30
 * @FilePath: \three-demo\src\cesium\010-offline_terrian\App.vue
 * @Description: offline_terrian
 * Copyright (c) 2023 by chriswoodcn, All Rights Reserved. 
-->
<template>
  <div id="cesiumContainer" ref="mapRef" class="w-full h-full"></div>
</template>
<script setup>
import * as Cesium from "cesium";
import { ref, onMounted } from "vue";
const mapRef = ref();
/**@type Cesium.Viewer */
var viewer;
const initMap = async () => {
  viewer = new Cesium.Viewer("cesiumContainer");
  //去除版权信息
  viewer._cesiumWidget._creditContainer.style.display = "none";
  //优化项--关闭相关特效
  viewer.scene.debugShowFramesPerSecond = true; //显示fps
  viewer.scene.moon.show = false; //月亮
  viewer.scene.fog.enabled = false; //雾
  viewer.scene.sun.show = false; //太阳
  viewer.scene.skyBox.show = false; //天空盒
  viewer.resolutionScale = 1.0; //画面细度，默认值为1.0
  loadTerrain();
};
const loadTerrain = async () => {
  try {
    var terrainLayer = new Cesium.CesiumTerrainProvider({
      // url: "http://10.254.10.38/terrain",//离线部署的地形服务
      url: "http://data.marsgis.cn/terrain",//在线地形服务
    });
    viewer.scene.terrainProvider = terrainLayer;
    //初始定位
    var obj = { lng: 107.3439536777, lat: 33.8578480564, eyeHeight: 12500, pitch: -25, heading: 0.0, time: 1 };
    viewerFlyToLonLat(obj);
  } catch (error) {
    console.log(`Error loading tileset: ${error}`);
  }
}
onMounted(() => {
  initMap();
});
</script>
