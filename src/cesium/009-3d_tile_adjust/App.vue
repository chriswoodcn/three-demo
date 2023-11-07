<!--
 * @Author: chriswoodcn
 * @Email: chriswoodcn@aliyun.com
 * @Date: 2023-11-07 23:05:04
 * @LastEditors: chriswoodcn
 * @LastEditTime: 2023-11-07 23:26:46
 * @FilePath: \three-demo\src\cesium\009-3d_tile_adjust\App.vue
 * @Description: 3d_tile_adjust
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
  viewer = new Cesium.Viewer("cesiumContainer", {
    terrain: Cesium.Terrain.fromWorldTerrain(),
  });
  //去除版权信息
  viewer._cesiumWidget._creditContainer.style.display = "none";
  //优化项--关闭相关特效
  viewer.scene.debugShowFramesPerSecond = true; //显示fps
  viewer.scene.moon.show = false; //月亮
  viewer.scene.fog.enabled = false; //雾
  viewer.scene.sun.show = false; //太阳
  viewer.scene.skyBox.show = false; //天空盒
  viewer.resolutionScale = 1.0; //画面细度，默认值为1.0
  loadPhoto();
};
//调整参数
var params = {
  tx: 113.06265738392063, //模型中心X轴坐标（经度，单位：十进制度）
  ty: 22.647853971034342, //模型中心Y轴坐标（纬度，单位：十进制度）
  tz: 0, //模型中心Z轴坐标（高程，单位：米）
  rx: 0, //X轴（经度）方向旋转角度（单位：度）
  ry: 0, //Y轴（纬度）方向旋转角度（单位：度）
  rz: 2, //Z轴（高程）方向旋转角度（单位：度）
  scale: 1.3, //缩放比例
};
const loadPhoto = async () => {
  try {
    var tileset = await Cesium.Cesium3DTileset.fromUrl(
      "http://localhost:8003/1.0/40866/tileset.json",
      {
        maximumMemoryUsage: 100, //不可设置太高，目标机子空闲内存值以内，防止浏览器过于卡
        maximumScreenSpaceError: 20, //用于驱动细节细化级别的最大屏幕空间错误;较高的值可提供更好的性能，但视觉质量较低。
        maximumNumberOfLoadedTiles: 1000, //最大加载瓦片个数
        shadows: false, //是否显示阴影
        skipLevelOfDetail: true,
        baseScreenSpaceError: 1024,
        skipScreenSpaceErrorFactor: 16,
        skipLevels: 1,
        immediatelyLoadDesiredLevelOfDetail: false,
        loadSiblings: false,
        cullWithChildrenBounds: true,
        dynamicScreenSpaceError: true,
        dynamicScreenSpaceErrorDensity: 0.00278,
        dynamicScreenSpaceErrorFactor: 4.0,
        dynamicScreenSpaceErrorHeightFalloff: 0.25,
      }
    );
    update3dtilesMaxtrix(tileset);
    viewer.scene.primitives.add(tileset);
    viewer.zoomTo(tileset);
    viewer.scene.screenSpaceCameraController.maximumZoomDistance = 1000000;
    viewer.scene.screenSpaceCameraController.minimumZoomDistance = 10;
    // tileset.readyPromise.then(function (tileset) {
    //   update3dtilesMaxtrix(tileset);
    // });
  } catch (error) {
    console.log(`Error loading tileset: ${error}`);
  }
}
//倾斜摄影位置更新
function update3dtilesMaxtrix(tileset) {
  //旋转
  var mx = Cesium.Matrix3.fromRotationX(Cesium.Math.toRadians(params.rx));
  var my = Cesium.Matrix3.fromRotationY(Cesium.Math.toRadians(params.ry));
  var mz = Cesium.Matrix3.fromRotationZ(Cesium.Math.toRadians(params.rz));
  var rotationX = Cesium.Matrix4.fromRotationTranslation(mx);
  var rotationY = Cesium.Matrix4.fromRotationTranslation(my);
  var rotationZ = Cesium.Matrix4.fromRotationTranslation(mz);
  //平移
  var position = Cesium.Cartesian3.fromDegrees(
    params.tx,
    params.ty,
    params.tz
  );
  var m = Cesium.Transforms.eastNorthUpToFixedFrame(position);
  //旋转、平移矩阵相乘
  Cesium.Matrix4.multiply(m, rotationX, m);
  Cesium.Matrix4.multiply(m, rotationY, m);
  Cesium.Matrix4.multiply(m, rotationZ, m);
  //比例缩放
  var scale = Cesium.Matrix4.fromUniformScale(params.scale);
  Cesium.Matrix4.multiply(m, scale, m);
  console.log("矩阵m:", m);
  //赋值给tileset
  tileset._root.transform = m;
}
onMounted(() => {
  initMap();
});
</script>
