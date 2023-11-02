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
  try {
    // const tileset0 = await Cesium.Cesium3DTileset.fromIonAssetId(40866);
    // var tileset = viewer.scene.primitives.add(
    //   new Cesium.Cesium3DTileset({
    //     url: "https://assets.ion.cesium.com/ap-northeast-1/40866/tileset.json",
    //     maximumMemoryUsage: 100, //不可设置太高，目标机子空闲内存值以内，防止浏览器过于卡
    //     maximumScreenSpaceError: 20, //用于驱动细节细化级别的最大屏幕空间错误;较高的值可提供更好的性能，但视觉质量较低。
    //     maximumNumberOfLoadedTiles: 1000, //最大加载瓦片个数
    //     shadows: false, //是否显示阴影
    //     skipLevelOfDetail: true,
    //     baseScreenSpaceError: 1024,
    //     skipScreenSpaceErrorFactor: 16,
    //     skipLevels: 1,
    //     immediatelyLoadDesiredLevelOfDetail: false,
    //     loadSiblings: false,
    //     cullWithChildrenBounds: true,
    //     dynamicScreenSpaceError: true,
    //     dynamicScreenSpaceErrorDensity: 0.00278,
    //     dynamicScreenSpaceErrorFactor: 4.0,
    //     dynamicScreenSpaceErrorHeightFalloff: 0.25,
    //   })
    // );
    const tileset = await Cesium.Cesium3DTileset.fromUrl(
      // "http://localhost:8003/1.0/TilesetWithDiscreteLOD/tileset.json",
      // "http://localhost:8003/1.0/TilesetWithTreeBillboards/tileset.json",
      // "http://localhost:8003/1.0/TilesetWithRequestVolume/tileset.json",
      "http://localhost:8003/1.0/40866/tileset.json",
      {
        debugShowBoundingVolume: true,
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
    viewer.scene.primitives.add(tileset);
    viewer.zoomTo(tileset);
  } catch (error) {
    console.log(`Error loading tileset: ${error}`);
  }
};

onMounted(() => {
  initMap();
});
</script>
