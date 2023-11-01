<template>
    <div id="cesiumContainer" ref="mapRef" class="w-full h-full">
        <input type="button" value="点采集(经纬度、高度)" @click="gatherPointFun" style="
        position: absolute;
        left: 50px;
        top: 50px;
        background: blue;
        color: white;
        z-index: 9999;
      " />
    </div>
</template>
<script setup>
import * as Cesium from "cesium";
import { ref, onMounted } from "vue";
const mapRef = ref();
var viewer;
//采集点
var gatherPoint = null;
//事件对象
var handler = null;
const gatherPointFun = () => {
    gatherPoint = null;
    handler = new Cesium.ScreenSpaceEventHandler(viewer.canvas);
    //鼠标变成加号
    mapRef.value.style.cursor = "crosshair";
    // 对鼠标按下事件的监听
    handler.setInputAction(function (event) {
        console.log("点击事件event: ", event);
        //获取加载地形后对应的经纬度和高程：地标坐标
        var ray = viewer.camera.getPickRay(event.position);
        var cartesian = viewer.scene.globe.pick(ray, viewer.scene);
        //获取倾斜摄影或模型点击处的坐标：场景坐标
        //var cartesian = viewer.scene.pick(event.position);
        console.log("cartesian:", cartesian);
        if (!Cesium.defined(cartesian)) {
            return;
        }
        gatherPoint = viewer.entities.add({
            name: "point",
            position: cartesian,
            point: {
                color: Cesium.Color.CHARTREUSE.withAlpha(1),
                pixelSize: 10,
                heightReference: Cesium.HeightReference.CLAMP_TO_GROUND,
                outlineColor: Cesium.Color.WHITE,
                outlineWidth: 1,
            },
        });
        //笛卡尔坐标转经纬度坐标
        var ellipsoid = viewer.scene.globe.ellipsoid;
        var cartographic = ellipsoid.cartesianToCartographic(cartesian);
        var obj = {};
        obj.lat = Cesium.Math.toDegrees(cartographic.latitude);
        obj.lng = Cesium.Math.toDegrees(cartographic.longitude);
        obj.alt = cartographic.height;
        console.log("采集的面坐标(经纬度)", obj);
        //鼠标变成默认
        mapRef.value.style.cursor = "default";
        //移除地图点击事件
        handler.removeInputAction(Cesium.ScreenSpaceEventType.LEFT_CLICK); //移除事件
    }, Cesium.ScreenSpaceEventType.LEFT_CLICK);
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
            style: Cesium.IonWorldImageryStyle.AERIAL_WITH_LABELS,
        }),
        terrainProvider: await Cesium.CesiumTerrainProvider.fromIonAssetId(1, {
            requestVertexNormals: true,
        }),
    };
    viewer = new Cesium.Viewer("cesiumContainer", viewerOption);
    //去除版权信息
    viewer._cesiumWidget._creditContainer.style.display = "none";
    viewer.camera.setView({
//         alt
// : 
// 3.1788981145084665
// lat
// : 
// 31.70798493824022
// lng
// : 
// 119.84846710249367
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
