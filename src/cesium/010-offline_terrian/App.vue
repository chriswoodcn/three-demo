<!--
 * @Author: chriswoodcn
 * @Email: chriswoodcn@aliyun.com
 * @Date: 2023-11-08 07:02:05
 * @LastEditors: chriswoodcn
 * @LastEditTime: 2023-11-08 15:57:00
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
// const initMap = async () => {
//   viewer = new Cesium.Viewer("cesiumContainer");
//   //去除版权信息
//   viewer._cesiumWidget._creditContainer.style.display = "none";
//   //优化项--关闭相关特效
//   viewer.scene.debugShowFramesPerSecond = true; //显示fps
//   viewer.scene.moon.show = false; //月亮
//   viewer.scene.fog.enabled = false; //雾
//   viewer.scene.sun.show = false; //太阳
//   viewer.scene.skyBox.show = false; //天空盒
//   viewer.resolutionScale = 1.0; //画面细度，默认值为1.0
//   loadTerrain();
// };

const initMap = () => {
  var mapOption = {
    //地图可进行切换
    //高德影像地图
    //url:"https://webst04.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}",
    //google地图（国内暂时被封），后续如果开放可直接f12-->network获取服务
    //osm矢量地图
    //url:"https://b.tile.openstreetmap.org/{z}/{x}/{y}.png",
    //mapbox影像地图(token如果过期，请选择其他地图图层)
    //url:"https://api.mapbox.com/styles/v1/marsgis/cki0adkar2b0e19mv9tpiewld/tiles/512/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibWFyc2dpcyIsImEiOiJja2Fod2xlanIwNjJzMnhvMXBkMnNqcjVpIn0.WnxikCaN2KV_zn9tLZO77A"
    //arcgis影像地图
    url: "https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
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
    baselLayerPicker: false, // 将图层选择的控件关掉，才能添加其他影像数据
    shadows: true, //是否显示背影
    shouldAnimate: true,
    // imageryProvider: imgProvider,
  };
  viewer = new Cesium.Viewer("cesiumContainer", viewerOption);
  loadTerrain();
  //去除版权信息
  viewer._cesiumWidget._creditContainer.style.display = "none";
};

var flyToEntity = null;
function viewerFlyToLonLat(obj) {
  console.log("飞行参数：", obj.lng, obj.lat, obj.eyeHeight);
  let cartographics = [Cesium.Cartographic.fromDegrees(obj.lng, obj.lat)];
  cartographics.obj = obj;
  Cesium.sampleTerrain(viewer.scene.terrainProvider, 14, cartographics).then(
    (updatedPositions) => {
      var flyToHeight = updatedPositions[0].height;
      if (typeof flyToHeight == "undefined") {
        updatedPositions.obj.height = 0;
      } else {
        updatedPositions.obj.height = flyToHeight;
      }
      console.log("地形高度：", updatedPositions.obj.height);
      if (flyToEntity) {
        viewer.entities.remove(flyToEntity);
      }
      flyToEntity = new Cesium.Entity({
        id: "flyTmp",
        position: Cesium.Cartesian3.fromDegrees(
          updatedPositions.obj.lng,
          updatedPositions.obj.lat,
          updatedPositions.obj.height
        ),
        point: {
          pixelSize: 0, //控制居中的时候是否展示中心点
          color: Cesium.Color.RED.withAlpha(0.9),
          outlineColor: Cesium.Color.WHITE.withAlpha(0.9),
          outlineWidth: 0,
        },
      });
      viewer.entities.add(flyToEntity);
      var flyPromise = viewer.flyTo(flyToEntity, {
        duration: updatedPositions.obj.time, //飞行时间,单位：秒
        offset: {
          heading: Cesium.Math.toRadians(updatedPositions.obj.heading), //旋转角度
          pitch: Cesium.Math.toRadians(updatedPositions.obj.pitch), //倾斜角度
          range: updatedPositions.obj.eyeHeight, //视角高度
        },
      });
      // 飞行完后
      flyPromise.then(function (flyPromise) {
        console.log("飞行结束");
      });
    }
  );
}

const loadTerrain = async () => {
  try {
    // url: "http://10.254.10.38/terrain",//离线部署的地形服务
    // url: "http://data.marsgis.cn/terrain", //在线地形服务
    var terrainLayer = await Cesium.CesiumTerrainProvider.fromUrl(
      "http://localhost:8003/gis/demo",
      {}
    );
    viewer.scene.terrainProvider = terrainLayer;
    //初始定位
    var obj = {
      lng: 107.3439536777,
      lat: 33.8578480564,
      eyeHeight: 12500,
      pitch: -25,
      heading: 0.0,
      time: 1,
    };
    viewerFlyToLonLat(obj);
  } catch (error) {
    console.log(`Error loading tileset: ${error}`);
  }
};
onMounted(() => {
  initMap();
});
</script>
