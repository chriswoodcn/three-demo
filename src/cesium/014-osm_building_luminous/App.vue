<template>
  <div id="cesiumContainer" ref="mapRef" class="w-full h-full"></div>
</template>
<script setup>
import * as Cesium from "cesium";
import { ref, onMounted } from "vue";
const mapRef = ref();
/**@type Cesium.Viewer */
var viewer;
var worldTerrainProvider;

const initMap = async () => {
  //在线调用需要token
  // Cesium.Ion.defaultAccessToken =
  //   "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI4YjUxM2U0Yi01NjQ4LTQ3OGItYTRkNC03YzViMDBiYjJmZDUiLCJpZCI6MTc1MjExLCJpYXQiOjE2OTg3OTI2NTF9.c0r5dGsd-fmp7_nNQTjcf4fEyI2ekPmbaxxCfU9kAh4";
  const osmImageryProvider = new Cesium.OpenStreetMapImageryProvider({
    url: "https://tile.openstreetmap.org/",
  });
  viewer = new Cesium.Viewer("cesiumContainer", {
    baseLayerPicker: false, //是否显示图层选择器
    baseLayer: false,
  });
  worldTerrainProvider = await Cesium.createWorldTerrainAsync();
  viewer.scene.terrainProvider = worldTerrainProvider;
  viewer.imageryLayers.addImageryProvider(osmImageryProvider);
  //优化项--关闭相关特效
  viewer.scene.debugShowFramesPerSecond = true; //显示fps
  load3Dbuild();
  //去除版权信息
  viewer._cesiumWidget._creditContainer.style.display = "none";
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
const load3Dbuild = async () => {
  console.log("js地图初始化完成,地图对象:", viewer);
  //3D建筑物
  var tileset = await Cesium.Cesium3DTileset.fromIonAssetId(96188, {
    customShader: new Cesium.CustomShader({
      lightingModel: Cesium.LightingModel.UNLIT,
      fragmentShaderText: `
        // Color tiles by distance to the camera
        void fragmentMain(FragmentInput fsInput, inout czm_modelMaterial material)
        {
            // material.diffuse = vec3(0.0, 0.0, 1.0);
            // material.diffuse.g = -fsInput.attributes.positionEC.z / 1.0e4;
            /* 渐变效果 */
            // vec4 v_helsing_position = czm_inverseModelView * vec4(fsInput.attributes.positionEC,1);// 解算出模型坐标
            // float stc_pl = fract(czm_frameNumber / 120.0) * 3.14159265 * 2.0;
            // float stc_sd = v_helsing_position.z / 60.0 + sin(stc_pl) * 0.1;
            // gl_FragColor = vec4(0, 0.2, 1.0,1);// 基础颜色
            // gl_FragColor *= vec4(stc_sd, stc_sd, stc_sd, 1.0);// 按模型高度进行颜色变暗处理
            /* 扫描线 */
            // float glowRange = 250.0; // 光环的移动范围(高度)，最高到360米
            // float stc_a13 = fract(czm_frameNumber / 360.0);// 计算当前着色器的时间，帧率/（6*60），即时间放慢6倍
            // float stc_h = clamp(v_helsing_position.z / glowRange, 0.0, 1.0);
            // stc_a13 = abs(stc_a13 - 0.5) * 2.0;
            // float stc_diff = step(0.005, abs(stc_h - stc_a13));// 根据时间来计算颜色差异
            // gl_FragColor.rgb += gl_FragColor.rgb * (1.0 - stc_diff);// 原有颜色加上颜色差异值提高亮度

            /* 渐变效果 */
            vec4 v_helsing_position = czm_inverseModelView * vec4(fsInput.attributes.positionEC,1);
            float stc_pl = fract(czm_frameNumber / 120.0) * 3.14159265 * 2.0;
            float stc_sd = v_helsing_position.z / 60.0 + sin(stc_pl) * 0.1;
            material.diffuse = vec3(0, 0.2, 1.0);// 基础颜色
            material.diffuse *= vec3(stc_sd, stc_sd, stc_sd);
            /* 扫描线 */
            float glowRange = 250.0; // 光环的移动范围(高度)，最高到360米
            float stc_a13 = fract(czm_frameNumber / 180.0);// 计算当前着色器的时间，帧率/（6*60），即时间放慢6倍
            float stc_h = clamp(v_helsing_position.z / glowRange, 0.0, 1.0);
            stc_a13 = abs(stc_a13 - 0.5) * 2.0;
            float stc_diff = step(0.005, abs(stc_h - stc_a13));// 根据时间来计算颜色差异
            material.diffuse += material.diffuse * (1.0 - stc_diff);// 原有颜色加上颜色差异值提高亮度
        }
        `,
    }),
  });
  var city = viewer.scene.primitives.add(tileset);
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
