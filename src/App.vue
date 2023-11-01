<!--
 * @Author: chriswoodcn
 * @Email: chriswoodcn@aliyun.com
 * @Date: 2023-10-26 07:59:32
 * @LastEditors: chriswoodcn
 * @LastEditTime: 2023-11-01 17:08:53
 * @Description: 
 * 
 * Copyright (c) 2023 by chriswoodcn, All Rights Reserved. 
-->
<script setup>
import { ref, onMounted } from "vue";
// import { renderer, animate } from "./components/startup";
// import { renderer, animate } from "./components/envmap";
// import { renderer, animate } from "./components/points";
// import { renderer, animate } from "./components/raycaster";
// animate();
// const mapRef = ref();
// onMounted(() => {
//   mapRef.value.appendChild(renderer.domElement);
// });
import * as Cesium from "cesium";
import { modifyMap } from "./utils/cesiumHelper";
Cesium.Ion.defaultAccessToken =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI4YjUxM2U0Yi01NjQ4LTQ3OGItYTRkNC03YzViMDBiYjJmZDUiLCJpZCI6MTc1MjExLCJpYXQiOjE2OTg3OTI2NTF9.c0r5dGsd-fmp7_nNQTjcf4fEyI2ekPmbaxxCfU9kAh4";
onMounted(async () => {
  const viewer = new Cesium.Viewer("cesiumContainer", {
    animation: false, //动画小部件
    baseLayerPicker: false, //地图图层组件
    fullscreenButton: false, //全屏组件
    geocoder: false, //地理编码搜索组件
    homeButton: false, //首页组件
    infoBox: false, //信息框
    sceneModePicker: false, //场景模式
    selectionIndicator: false, //选取指示器组件
    timeline: false, //时间轴
    navigationHelpButton: false, //帮助按钮
    navigationInstructionsInitiallyVisible: false,
    baseLayer: Cesium.ImageryLayer.fromWorldImagery({
      style: Cesium.IonWorldImageryStyle.ROAD,
    }),
    terrainProvider: await Cesium.CesiumTerrainProvider.fromIonAssetId(1, {
      requestVertexNormals: true,
    }),
  });
  // console.log(bingMapProvider);
  // var gaodeImageryProvider = new Cesium.UrlTemplateImageryProvider({
  //   url: "https://webst02.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}",
  //   maximumLevel: 18,
  //   minimumLevel: 1,
  //   credit: "Amap",
  // });
  // var tencentImageryProvider = new Cesium.UrlTemplateImageryProvider({
  //   url: "https://p2.map.gtimg.com/sateTiles/{z}/{sx}/{sy}/{x}_{reverseY}.jpg?version=400",
  //   customTags: {
  //     sx: function(imageryProvider, x, y, level) { return x >> 4; },
  //     sy: function(imageryProvider, x, y, level) { return ((1 << level) - y) >> 4 }
  //   }
  // });
  // viewer.imageryLayers.add(imageryLayer);
  // Enable rendering the sky
  viewer.scene.skyAtmosphere.show = true;
  modifyMap(viewer, {
    invertColor: true,
    filterRGB: [27, 173, 170],
  });
  const cameraChangeListener = function (arg1, arg2) {
    console.log("cameraChangeListener: " + arg1);
    console.log("cameraChangeListener: " + arg2);
  };
  viewer.camera.changed.addEventListener(
    cameraChangeListener,
    viewer.camera.changed
  );

  // 定义目标位置和视角
  var targetPosition = Cesium.Cartesian3.fromDegrees(120, 30, 15000);
  var heading = Cesium.Math.toRadians(0.0);
  var pitch = Cesium.Math.toRadians(-90.0);
  var roll = Cesium.Math.toRadians(0.0);
  // 相机飞到目标点
  viewer.camera.flyTo({
    destination: targetPosition,
    orientation: {
      heading: heading,
      pitch: pitch,
      roll: roll,
    },
    duration: 3, // 飞行动画时长
  });
  try {
    // const tileset = await Cesium.createGooglePhotorealistic3DTileset();
    // viewer.scene.primitives.add(tileset);
  } catch (error) {
    console.log(`Failed to load tileset: ${error}`);
  }
  removeLogo(viewer);
});
function removeLogo(viewer) {
  const creditContainer = viewer.bottomContainer;
  creditContainer.remove();
}
</script>

<template>
  <div id="cesiumContainer" ref="mapRef" class="w-full h-full"></div>
</template>
<style>
.cesium-viewer-bottom {
  display: none !important;
}
</style>
