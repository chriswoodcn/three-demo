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
  //在线调用需要token
  // Cesium.Ion.defaultAccessToken =
  //   "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI4YjUxM2U0Yi01NjQ4LTQ3OGItYTRkNC03YzViMDBiYjJmZDUiLCJpZCI6MTc1MjExLCJpYXQiOjE2OTg3OTI2NTF9.c0r5dGsd-fmp7_nNQTjcf4fEyI2ekPmbaxxCfU9kAh4";
  viewer = new Cesium.Viewer("cesiumContainer", {
    terrain: Cesium.Terrain.fromWorldTerrain(),
  });
  //优化项--关闭相关特效
  viewer.scene.debugShowFramesPerSecond = true; //显示fps
  viewer.scene.moon.show = false; //月亮
  viewer.scene.fog.enabled = false; //雾
  viewer.scene.sun.show = false; //太阳
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
  var city = viewer.scene.primitives.add(tileset);
  // city.shadows = false;
  console.log("city:", city);
  var heightStyle = new Cesium.Cesium3DTileStyle({
    color: {
      conditions: [
        ["${feature['cesium#estimatedHeight']} === null", 'color("white")'],
        ["${feature['cesium#estimatedHeight']} === undefined", 'color("white")'],
        ["Number(${feature['cesium#estimatedHeight']}) > 300", "rgb(248,215,20)"],
        ["Number(${feature['cesium#estimatedHeight']}) >= 200", "rgb(255, 255, 255)"],
        ["Number(${feature['cesium#estimatedHeight']}) >= 100", "rgb(170, 162, 204)"],
        ["Number(${feature['cesium#estimatedHeight']}) >= 50", "rgb(224, 226, 238)"],
        ["Number(${feature['cesium#estimatedHeight']}) >= 25", "rgb(252, 230, 200)"],
        ["Number(${feature['cesium#estimatedHeight']}) >= 10", "rgb(248, 176, 87)"],
        ["Number(${feature['cesium#estimatedHeight']}) >= 5", "rgb(198, 106, 11)"],
      ]
    }
  });
  // 将默认样式改为自定义样式
  city.style = heightStyle;
  // 通过鼠标点击建筑物获取改建筑物的所有字段以及内容
  var handler = new Cesium.ScreenSpaceEventHandler(viewer.canvas);
  handler.setInputAction(function (movement) {
    console.log("movement", movement);
    var feature = viewer.scene.pick(movement.position);
    console.log("feature ", feature);
    if (feature instanceof Cesium.Cesium3DTileFeature) {
      feature.color = Cesium.Color.fromRandom({ alpha: 1.0 });
      const propertyIds = feature.getPropertyIds();
      const length = propertyIds.length;
      for (let i = 0; i < length; ++i) {
        const propertyId = propertyIds[i];
        console.log(`${propertyId}: ${feature.getProperty(propertyId)}`);
      }
    }
  }, Cesium.ScreenSpaceEventType.LEFT_CLICK);
  var obj = {
    lng: 121.498,
    lat: 31.2418,
    eyeHeight: 3000,
    pitch: -30,
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
