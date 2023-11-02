<template>
  <div id="cesiumContainer" ref="mapRef" class="w-full h-full">
    <input
      type="button"
      value="面采集"
      @click="gatherPolygonFun"
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
import { modifyMap } from "../../utils/cesiumHelper";
const mapRef = ref();
/**@type Cesium.Viewer */
var viewer;
//采集面
function gatherPolygonFun() {
  var gatherPoints = [];
  var points = [];
  var gatherPolygon = null;
  var polygonGatherHandler = new Cesium.ScreenSpaceEventHandler(
    viewer.scene.canvas
  );
  //鼠标变成加号
  mapRef.value.style.cursor = "crosshair";
  // 对鼠标按下事件的监听
  polygonGatherHandler.setInputAction((event) => {
    //获取加载地形后对应的经纬度和高程：地标坐标
    var ray = viewer.camera.getPickRay(event.position);
    var cartesian = viewer.scene.globe.pick(ray, viewer.scene);
    console.log(cartesian);
    if (!Cesium.defined(cartesian)) {
      return;
    }
    var point = viewer.entities.add({
      name: "gon_point",
      position: cartesian,
      point: {
        color: Cesium.Color.WHITE,
        pixelSize: 5,
        heightReference: Cesium.HeightReference.CLAMP_TO_GROUND,
        outlineColor: Cesium.Color.BLACK,
        outlineWidth: 1,
      },
    });
    gatherPoints.push(point);
    points.push(cartesian);
    // 如果点的数量在3个及以上 则绘制面
    if (points.length >= 3) {
      // 面为空 绘制新的面
      if (gatherPolygon == null) {
        gatherPolygon = viewer.entities.add({
          name: "polygon",
          polygon: {
            hierarchy: new Cesium.CallbackProperty(function (time, result) {
              var hierarchyTemp = new Cesium.PolygonHierarchy(points, null);
              return hierarchyTemp;
            }, false),
            material: Cesium.Color.fromRandom({ alpha: 0.5 }),
          },
        });
      } else {
        // 否则面重新生成
        gatherPolygon.polygon.hierarchy = new Cesium.CallbackProperty(function (
          time,
          result
        ) {
          var hierarchyTemp = new Cesium.PolygonHierarchy(points, null);
          return hierarchyTemp;
        },
        false);
      }
    }
  }, Cesium.ScreenSpaceEventType.LEFT_CLICK);

  polygonGatherHandler.setInputAction(function (rightClick) {
    console.log(
      "采集的面坐标(笛卡尔)：",
      gatherPolygon.polygon.hierarchy.getValue().positions
    );
    var dke = gatherPolygon.polygon.hierarchy.getValue().positions;
    var objArr = [];
    for (var i = 0; i < dke.length; i++) {
      var ellipsoid = viewer.scene.globe.ellipsoid;
      var cartesian3 = new Cesium.Cartesian3(dke[i].x, dke[i].y, dke[i].z);
      var cartographic = ellipsoid.cartesianToCartographic(cartesian3);
      //console.log("cartographic",cartographic);
      var obj = {};
      obj.lat = Cesium.Math.toDegrees(cartographic.latitude);
      obj.lng = Cesium.Math.toDegrees(cartographic.longitude);
      obj.alt = cartographic.height;
      objArr.push(obj);
    }
    console.log("采集的面坐标(经纬度)", objArr);
    for (var i = 0; i < gatherPoints.length; i++) {
      viewer.entities.remove(gatherPoints[i]);
    }
    gatherPoints = [];
    //points = [];//注：points不可置空，如果置空，会导致地图上的点也不存在。
    //鼠标变成加号
    mapRef.value.style.cursor = "default";
    //移除地图点击事件
    polygonGatherHandler.removeInputAction(
      Cesium.ScreenSpaceEventType.LEFT_CLICK
    ); //移除事件
  }, Cesium.ScreenSpaceEventType.RIGHT_CLICK);
}
const initMap = async () => {
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
    baseLayer: Cesium.ImageryLayer.fromWorldImagery({
      style: Cesium.IonWorldImageryStyle.ROAD,
    }),
    terrainProvider: await Cesium.CesiumTerrainProvider.fromIonAssetId(1, {
      requestVertexNormals: true,
    }),
  };
  viewer = new Cesium.Viewer("cesiumContainer", viewerOption);
  //去除版权信息
  viewer._cesiumWidget._creditContainer.style.display = "none";
  modifyMap(viewer, {
    invertColor: true,
    filterRGB: [27, 173, 170],
  });
  viewer.camera.setView({
    destination: Cesium.Cartesian3.fromDegrees(
      119.84846710249367,
      31.70798493824022,
      1000
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
