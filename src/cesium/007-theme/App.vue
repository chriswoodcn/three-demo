<template>
  <div id="cesiumContainer" ref="mapRef" class="w-full h-full">
    <input
      type="button"
      @click="changeTheme"
      value="更换主题色"
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
/**
 * 创建天地图ImageryProvider
 */
function createTdtImageryProvider(params) {
  var tileMatrixSet = "w";
  var host = params.host || "http://t{s}.tianditu.com/";
  var subdomains = ["0", "1", "2", "3", "4", "5", "6", "7"];

  if (host[host.length - 1] == "/") {
    host = host.substr(0, host.length - 1);
  }
  var url =
    host +
    "/" +
    params.layer +
    "_" +
    tileMatrixSet +
    "/wmts?service=wmts&request=GetTile&version=1.0.0&LAYER=" +
    params.layer +
    "&tileMatrixSet=" +
    tileMatrixSet +
    "&TileMatrix={TileMatrix}&TileRow={TileRow}&TileCol={TileCol}&style=default&format=tiles";
  url += "&tk=" + params.appKey;

  let provider = new Cesium.WebMapTileServiceImageryProvider({
    url: url,
    layer: params.layer,
    style: "default",
    subdomains: subdomains,
    tileMatrixSetID: tileMatrixSet,
    maximumLevel: params.maximumLevel || 18,
    minimumLevel: params.minimumLevel,
  });

  return provider;
}
// 天地图tdtImageryProvider
var tdtImageryProvider = createTdtImageryProvider({
  layer: "vec",
  appKey: "f0c521dc0c8c58ae47e818e5f18c062e",
});
const initMap = async () => {
  var viewerOption = {
    animation: false, //是否创建动画小器件，左下角仪表
    baseLayerPicker: false, //是否显示图层选择器
    fullscreenButton: false, //是否显示全屏按钮
    geocoder: true, //是否显示geocoder小器件，右上角查询按钮
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
  // viewer.imageryLayers.addImageryProvider(tdtImageryProvider);
  modifyMap(viewer, {
    invertColor: true,
    filterRGB: [255, 173, 170],
  });
  //去除版权信息
  viewer._cesiumWidget._creditContainer.style.display = "none";
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
