<!--
 * @Author: chriswoodcn
 * @Email: chriswoodcn@aliyun.com
 * @Date: 2023-11-02 07:53:32
 * @LastEditors: chriswoodcn
 * @LastEditTime: 2023-11-09 13:11:37
 * @Description: 
 * 
 * Copyright (c) 2023 by chriswoodcn, All Rights Reserved. 
-->
<template>
  <div id="cesiumContainer" class="w-full h-full"></div>
</template>
<script setup>
import * as Cesium from "cesium";
import { onMounted } from "vue";

var mapOption = {
  // 天地图
  //   url: "https://t7.tianditu.gov.cn/img_w/wmts?service=WMTS&version=1.0.0&request=GetTile&tilematrix={z}&layer=img&style=default&tilerow={y}&tilecol={x}&tilematrixset=w&format=tiles&tk=2a0e637a8772d92b123ee8866dee4a82",
  //   url: "http://online{s}.map.bdimg.com/onlinelabel/?qt=tile&x={x}&y={y}&z={z}&styles=pl&scaler=1&p=1",
  url: "http://webrd02.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}",
  minimumLevel: 3,
  maximumLevel: 18,
};
var imgProvider = new Cesium.UrlTemplateImageryProvider(mapOption);
var viewerOption = {
  animation: false, //是否创建动画小器件，左下角仪表
  baseLayerPicker: false, //是否显示图层选择器
  fullscreenButton: false, //是否显示全屏按钮
  geocoder: false, //是否显示geocoder小器件，右上角查询按钮
  homeButton: false, //是否显示Home按钮
  infoBox: false, //是否显示信息框
  sceneModePicker: false, //是否显示3D/2D选择器
  scene3DOnly: false, //如果设置为true，则所有几何图形以3D模式绘制以节约GPU资源
  selectionIndicator: false, //是否显示选取指示器组件
  timeline: false, //是否显示时间轴
  navigationHelpButton: false, //是否显示右上角的帮助按钮
  shadows: true, //是否显示背影
  shouldAnimate: true,
  baseLayer: false,
};
var viewer, imageryLayer0;
const initMap = () => {
  // 常用高德地图地址
  // 矢量地图带注记：https://webrd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}
  // 矢量地图不带注记：http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}&scl=1&ltype=3
  // 影像不带注记：http://webst0{1-4}.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}
  // 道路带注记：http://webst0{1-4}.is.autonavi.com/appmaptile?x={x}&y={y}&z={z}&lang=zh_cn&size=1&scale=1&style=8
  // 道路不带注记：http://wprd0{1-4}.is.autonavi.com/appmaptile?x={x}&y={y}&z={z}&lang=zh_cn&size=1&scl=1&style=8<ype=11
  // 矢量带注记http://wprd0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&style=7&x={x}&y={y}&z={z}
  // 天地图
  // http://lbs.tianditu.gov.cn/server/MapService.html
  // 参考 https://blog.csdn.net/hou_ge/article/details/127212932
  // osm矢量地图
  // url:"https://b.tile.openstreetmap.org/{z}/{x}/{y}.png"
  viewer = new Cesium.Viewer("cesiumContainer", viewerOption);
  var imageryProvider = new Cesium.UrlTemplateImageryProvider({
    url: "http://webst01.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}",
    maximumLevel: 18,
    minimumLevel: 1,
  });
//   const mapboxImageryProvider = new Cesium.MapboxStyleImageryProvider({
//     // url: "http://localhost:8003/osm_liberty.json",
//     styleId: "streets-v11",
//     accessToken:
//       "pk.eyJ1IjoieGlhb3NoaWhkIiwiYSI6ImNrNngzYnRhdzBqNm0zZnJ4eWZjdndrYzkifQ.qQjf8zANr9PsMpwq2NsRWQ",
//   });
  viewer.imageryLayers.addImageryProvider(imageryProvider);
  //去除版权信息
  viewer._cesiumWidget._creditContainer.style.display = "none";
  viewer.camera.setView({
    destination: Cesium.Cartesian3.fromDegrees(
      118.03577899932861,
      24.572162691314048,
      200000
    ),
    orientation: {
      // 指向
      heading: Cesium.Math.toRadians(0, 0),
      // 视角
      pitch: Cesium.Math.toRadians(-90),
      roll: 0.0,
    },
  });
};

onMounted(() => {
  initMap();
});
</script>
