<template>
  <div id="cesiumContainer" ref="mapRef" class="w-full h-full"></div>
</template>
<script setup>
import * as Cesium from "cesium";
import { ref, onMounted } from "vue";
const mapRef = ref();
/**@type Cesium.Viewer */
var viewer;

const initMap = () => {
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
  };
  //在线调用需要token
  Cesium.Ion.defaultAccessToken =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI4YjUxM2U0Yi01NjQ4LTQ3OGItYTRkNC03YzViMDBiYjJmZDUiLCJpZCI6MTc1MjExLCJpYXQiOjE2OTg3OTI2NTF9.c0r5dGsd-fmp7_nNQTjcf4fEyI2ekPmbaxxCfU9kAh4";
  viewer = new Cesium.Viewer("cesiumContainer", viewerOption);
  load3Dbuild();
  //去除版权信息
  viewer._cesiumWidget._creditContainer.style.display = "none";
};
const load3Dbuild = async () => {
  console.log("js地图初始化完成,地图对象:", viewer);
  //3D建筑物
  var tileset = await Cesium.Cesium3DTileset.fromUrl(
    await Cesium.IonResource.fromAssetId(96188),
    {
      modelMatrix: Cesium.Matrix4.fromArray([
        1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1,
      ]),
      maximumMemoryUsage: 100, //不可设置太高，目标机子空闲内存值以内，防止浏览器过于卡
      maximumScreenSpaceError: 50, //用于驱动细节细化级别的最大屏幕空间错误;较高的值可提供更好的性能，但视觉质量较低。
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
  viewer.scene.primitives.add(tileset);
  var obj = {
    lng: 121.498,
    lat: 31.2418,
    eyeHeight: 2800,
    pitch: -25,
    heading: 87.0,
    time: 1,
  };
  viewerFlyToLonLat(obj);
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
onMounted(() => {
  initMap();
});
</script>
