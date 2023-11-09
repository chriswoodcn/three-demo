<template>
  <div id="cesiumContainer" ref="mapRef" class="w-full h-full">
    <input
      type="button"
      value="军事标绘-攻击箭头采集（右击结束采集）"
      @click="gatherAttackArrow"
      style="
        position: absolute;
        left: 50px;
        top: 50px;
        background: blue;
        color: white;
        z-index: 9999;
      "
    />
  </div>
</template>
<script setup>
import * as Cesium from "cesium";
import { ref, onMounted } from "vue";
const mapRef = ref();
/**@type Cesium.viewer */
var viewer;
var worldTerrainProvider;

const initMap = async () => {
  //在线调用需要token
  Cesium.Ion.defaultAccessToken =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI4YjUxM2U0Yi01NjQ4LTQ3OGItYTRkNC03YzViMDBiYjJmZDUiLCJpZCI6MTc1MjExLCJpYXQiOjE2OTg3OTI2NTF9.c0r5dGsd-fmp7_nNQTjcf4fEyI2ekPmbaxxCfU9kAh4";
  viewer = new Cesium.Viewer("cesiumContainer", {
    baseLayerPicker: false, //是否显示图层选择器
    baseLayer: false,
  });
  const imageryLayer = Cesium.ImageryLayer.fromProviderAsync(
    Cesium.IonImageryProvider.fromAssetId(2)
  );
  viewer.imageryLayers.add(imageryLayer);
  worldTerrainProvider = await Cesium.createWorldTerrainAsync();
  viewer.scene.terrainProvider = worldTerrainProvider;
  //优化项--关闭相关特效
  viewer.scene.debugShowFramesPerSecond = true; //显示fps
  //定位
  var obj = {
    lng: 118.0850887298584,
    lat: 24.439001083374023,
    eyeHeight: 10000,
    pitch: -50,
    heading: 0.0,
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

var gatherPosition = []; //采集的点信息
var floatingPoint = null; //移动点
var drawHandler = null; //画事件
var layerId = "attackArrowLayer";
function gatherAttackArrow() {
  console.log("攻击箭头");
  gatherPosition = [];
  floatingPoint = null;
  clearPlot();
  drawHandler = new Cesium.ScreenSpaceEventHandler(viewer.scene.canvas);

  // 鼠标左击
  drawHandler.setInputAction(function (event) {
    var position = event.position;
    if (!Cesium.defined(position)) {
      return;
    }
    var ray = viewer.camera.getPickRay(position);
    if (!Cesium.defined(ray)) {
      return;
    }
    var cartesian = viewer.scene.globe.pick(ray, viewer.scene);
    if (!Cesium.defined(cartesian)) {
      return;
    }
    //console.log("点击地图采集的点：",cartesian);
    var num = gatherPosition.length;
    if (num == 0) {
      gatherPosition.push(cartesian);
      floatingPoint = createPoint(cartesian, -1);
      // showRegion2Map();
    }
    gatherPosition.push(cartesian);
    var oid = gatherPosition.length - 2;
    createPoint(cartesian, oid);
  }, Cesium.ScreenSpaceEventType.LEFT_CLICK);

  // 鼠标移动
  drawHandler.setInputAction(function (event) {
    var position = event.endPosition;
    if (!Cesium.defined(position)) {
      return;
    }
    var ray = viewer.camera.getPickRay(position);
    if (!Cesium.defined(ray)) {
      return;
    }
    var cartesian = viewer.scene.globe.pick(ray, viewer.scene);
    if (!Cesium.defined(cartesian)) {
      return;
    }
    if (floatingPoint == null) {
      return;
    }
    floatingPoint.position.setValue(cartesian);
    gatherPosition.pop();
    gatherPosition.push(cartesian);
  }, Cesium.ScreenSpaceEventType.MOUSE_MOVE);

  //右击停止采集
  drawHandler.setInputAction(function (movement) {
    if (gatherPosition.length < 2) {
      return;
    }
    gatherPosition.pop();
    viewer.entities.remove(floatingPoint);
    //去掉事件
    if (drawHandler) {
      drawHandler.destroy();
      drawHandler = null;
    }
    //删除关键点
    clearKeyPoint();
    getAttackArrowValue();
  }, Cesium.ScreenSpaceEventType.RIGHT_CLICK);
}
/**
 * 删除攻击箭头
 */
function clearPlot() {
  var entityList = viewer.entities.values;
  if (entityList == null || entityList.length < 1) {
    return;
  }
  for (var i = 0; i < entityList.length; i++) {
    var entity = entityList[i];
    if (entity.layerId == layerId) {
      viewer.entities.remove(entity);
      i--;
    }
  }
}
/**
 * 删除关键点
 */
function clearKeyPoint() {
  var entityList = viewer.entities.values;
  if (entityList == null || entityList.length < 1) {
    return;
  }
  for (var i = 0; i < entityList.length; i++) {
    var entity = entityList[i];
    if (entity.flag == "keypoint") {
      viewer.entities.remove(entity);
      i--;
    }
  }
}
/**
 * 获取采集的直线箭头数据
 */
function getAttackArrowValue() {
  var entityList = viewer.entities.values;
  for (var i = 0; i < entityList.length; i++) {
    var entity = entityList[i];
    if (typeof entity.valueFlag != "undefined") {
      console.log(
        "采集的攻击箭头(笛卡尔)：",
        entity.polygon.hierarchy.getValue().positions
      );
      var dke = entity.polygon.hierarchy.getValue().positions;
      var objArr = [];
      for (var i = 0; i < dke.length; i++) {
        var ellipsoid = viewer.scene.globe.ellipsoid;
        var cartesian3 = new Cesium.Cartesian3(dke[i].x, dke[i].y, dke[i].z);
        var cartographic = ellipsoid.cartesianToCartographic(cartesian3);
        //console.log("cartographic",cartographic);
        var obj = {};
        obj.lat = Cesium.Math.toDegrees(cartographic.latitude);
        obj.lng = Cesium.Math.toDegrees(cartographic.longitude);
        //obj.alt=0;
        objArr.push(obj);
      }
      console.log("采集的攻击箭头(经纬度)", objArr);
      console.log(
        "采集的攻击箭头关键点",
        entity.polygon.hierarchy.getValue().keyPoints
      );
    }
  }
}

//创建关键点
function createPoint(cartesian, oid) {
  var point = viewer.entities.add({
    position: cartesian,
    point: {
      color: Cesium.Color.WHITE,
      pixelSize: 8,
      outlineColor: Cesium.Color.BLACK,
      outlineWidth: 1,
      heightReference: Cesium.HeightReference.CLAMP_TO_GROUND, //贴地
    },
    // billboard: {
    //   // image: "./images/gatherPoint.png",
    //   color: Cesium.Color.BLUE,
    //   eyeOffset: new Cesium.ConstantProperty(new Cesium.Cartesian3(0, 0, -500)),
    //   heightReference: Cesium.HeightReference.CLAMP_TO_GROUND,
    // },
  });
  point.oid = oid;
  point.layerId = layerId;
  point.flag = "keypoint";
  return point;
}

function showRegion2Map() {
  var material = Cesium.Color.fromCssColorString("#ff0").withAlpha(0.5);
  var outlineMaterial = new Cesium.PolylineDashMaterialProperty({
    dashLength: 16,
    color: Cesium.Color.fromCssColorString("#f00").withAlpha(0.7),
  });

  var dynamicHierarchy = new Cesium.CallbackProperty(function () {
    if (gatherPosition.length > 1) {
      var lonLats = getLonLatArr(gatherPosition);
      var doubleArrow = xp.algorithm.tailedAttackArrow(lonLats);
      var positions = doubleArrow.polygonalPoint;
      if (positions == null || positions.length < 3) {
        return null;
      }
      var pHierarchy = new Cesium.PolygonHierarchy(positions);
      pHierarchy.keyPoints = lonLats;
      return pHierarchy;
    } else {
      return null;
    }
  }, false);
  var outlineDynamicPositions = new Cesium.CallbackProperty(function () {
    if (gatherPosition.length < 2) {
      return null;
    }
    var lonLats = getLonLatArr(gatherPosition);
    //console.log("关键点lonLats：",lonLats);
    var doubleArrow = xp.algorithm.tailedAttackArrow(lonLats);
    var positions = doubleArrow.polygonalPoint;
    if (positions == null || positions.length < 3) {
      return null;
    }
    var firstPoint = positions[0];
    positions.push(firstPoint);
    return positions;
  }, false);
  var bData = {
    polygon: new Cesium.PolygonGraphics({
      hierarchy: dynamicHierarchy,
      material: material,
      show: true,
    }),
    polyline: {
      positions: outlineDynamicPositions,
      clampToGround: true,
      width: 2,
      material: outlineMaterial,
      show: true,
    },
  };
  var entity = viewer.entities.add(bData);
  entity.layerId = layerId;
  entity.valueFlag = "value";
}

//笛卡尔转经纬度
function getLonLatArr(positions) {
  var arr = [];
  for (var i = 0; i < positions.length; i++) {
    var p = getLonLat(positions[i]);
    if (p != null) {
      arr.push([p.lon, p.lat]);
    }
  }
  return arr;
}

/**
 * 笛卡尔坐标转经纬度坐标
 */
function getLonLat(cartesian) {
  var cartographic =
    viewer.scene.globe.ellipsoid.cartesianToCartographic(cartesian);
  cartographic.height = viewer.scene.globe.getHeight(cartographic);
  var pos = {
    lon: cartographic.longitude,
    lat: cartographic.latitude,
    alt: cartographic.height,
  };
  pos.lon = Cesium.Math.toDegrees(pos.lon);
  pos.lat = Cesium.Math.toDegrees(pos.lat);
  return pos;
}
onMounted(() => {
  initMap();
});
</script>
