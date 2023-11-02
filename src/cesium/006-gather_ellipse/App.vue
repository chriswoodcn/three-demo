<template>
  <div id="cesiumContainer" ref="mapRef" class="w-full h-full">
    <input
      type="button"
      @click="gatherEllipse"
      value="圆采集(鼠标点击后压住拖动)"
      style="
        position: absolute;
        left: 50px;
        top: 50px;
        background: blue;
        color: white;
        z-index: 9999;
      "
    />
    <input
      type="button"
      @click="editEllipse"
      value="鼠标选中可编辑圆进入编辑"
      style="
        position: absolute;
        left: 50px;
        top: 100px;
        background: blue;
        color: white;
        z-index: 9999;
      "
    />
    <input
      type="button"
      @click="endEditEllipse"
      value="可编辑圆结束编辑"
      style="
        position: absolute;
        left: 50px;
        top: 150px;
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

//事件
var handler = null;
//中心点
var centerPoint = null;
//采集的圆对象
var ellipseGather = null;
function gatherEllipse() {
  ellipseGather = null;
  //鼠标变成加号
  mapRef.value.style.cursor = "crosshair";
  //禁止地图移动
  viewer.scene.screenSpaceCameraController.enableRotate = false;
  viewer.scene.screenSpaceCameraController.enableZoom = false;
  handler = new Cesium.ScreenSpaceEventHandler(viewer.scene.canvas);
  //鼠标点击事件
  handler.setInputAction((event) => {
    //获取加载地形后对应的经纬度和高程：地标坐标
    var ray = viewer.camera.getPickRay(event.position);
    var cartesian = viewer.scene.globe.pick(ray, viewer.scene);
    //console.log("cartesian:", cartesian);
    if (!Cesium.defined(cartesian)) {
      return;
    }
    centerPoint = viewer.entities.add({
      name: "centerPoint",
      position: cartesian,
      point: {
        color: Cesium.Color.CHARTREUSE.withAlpha(1),
        pixelSize: 10,
        heightReference: Cesium.HeightReference.CLAMP_TO_GROUND,
        outlineColor: Cesium.Color.WHITE,
        outlineWidth: 1,
      },
    });
    //默认生成半径为0.1米的圆。
    ellipseGather = viewer.entities.add({
      position: cartesian,
      name: "ellipse",
      ellipse: {
        semiMinorAxis: 0.1, //椭圆短轴（单位米）
        semiMajorAxis: 0.1, //椭圆长轴（单位米）
        material: Cesium.Color.fromRandom({ alpha: 0.5 }),
        outline: true,
        outlineColor: Cesium.Color.WHITE,
        outlineWidth: 3,
      },
    });
  }, Cesium.ScreenSpaceEventType.LEFT_DOWN);

  // 对鼠标移动事件的监听
  handler.setInputAction((event) => {
    if (centerPoint == null || ellipseGather == null) {
      return;
    }
    //获取加载地形后对应的经纬度和高程：地标坐标
    var ray = viewer.camera.getPickRay(event.endPosition);
    var radiusCartesian = viewer.scene.globe.pick(ray, viewer.scene);
    if (!radiusCartesian) {
      return;
    }
    var centerCartesian = centerPoint.position.getValue(
      Cesium.JulianDate.now()
    );
    //计算移动点与中心点的距离（单位米）
    var centerTemp =
      viewer.scene.globe.ellipsoid.cartesianToCartographic(centerCartesian);
    var radiusTemp =
      viewer.scene.globe.ellipsoid.cartesianToCartographic(radiusCartesian);
    var geodesic = new Cesium.EllipsoidGeodesic();
    geodesic.setEndPoints(centerTemp, radiusTemp);
    var radius = geodesic.surfaceDistance;
    //console.log("radius",radius);
    //如果半径小于0,则不更新圆信息
    if (radius <= 0) {
      return;
    }
    ellipseGather.ellipse.semiMinorAxis = new Cesium.CallbackProperty(function (
      time,
      result
    ) {
      return radius;
    },
    false);
    ellipseGather.ellipse.semiMajorAxis = new Cesium.CallbackProperty(function (
      time,
      result
    ) {
      return radius;
    },
    false);
  }, Cesium.ScreenSpaceEventType.MOUSE_MOVE);

  // 对鼠标抬起事件的监听(结束点采集)
  handler.setInputAction((event) => {
    //鼠标变成默认
    mapRef.value.style.cursor = "default";
    //开始鼠标操作地图
    viewer.scene.screenSpaceCameraController.enableRotate = true;
    viewer.scene.screenSpaceCameraController.enableZoom = true;
    //移除地图鼠标点击事件
    handler.removeInputAction(Cesium.ScreenSpaceEventType.LEFT_DOWN);
    //移除地图鼠标移动事件
    handler.removeInputAction(Cesium.ScreenSpaceEventType.MOUSE_MOVE);
    //移除地图鼠标抬起事件
    handler.removeInputAction(Cesium.ScreenSpaceEventType.LEFT_UP);
    var ellipsoid = viewer.scene.globe.ellipsoid;
    var cartographic = ellipsoid.cartesianToCartographic(
      centerPoint.position.getValue(Cesium.JulianDate.now())
    );
    var lat = Cesium.Math.toDegrees(cartographic.latitude);
    var lng = Cesium.Math.toDegrees(cartographic.longitude);
    var height = cartographic.height;
    console.log("圆中心点：经度", lng + ",纬度：" + lat + ",高度：" + height);
    console.log(
      "圆半径：",
      ellipseGather.ellipse.semiMinorAxis.getValue() + "米"
    );
    //如果圆半径小于0.5米则删除，防止出现默认为0.1米的被采集。该种情况则是用户取消圆采集
    if (ellipseGather.ellipse.semiMinorAxis.getValue() < 0.5) {
      viewer.entities.remove(ellipseGather);
      ellipseGather = null;
    }
    //清除圆中心点和半径点
    viewer.entities.remove(centerPoint);
    centerPoint = null;
  }, Cesium.ScreenSpaceEventType.LEFT_UP);
}
//当前编辑点
var currentPoint = null;
//所有编辑点
var pointsId = [];
//事件
var handler = null;
//当前编辑对象
var editObj = null;
//当时是否是编辑状态
var isEditting = false;
//经度1度=101194米
var degreeMeter = 101194;
function editEllipse() {
  mapRef.value.style.cursor = "pointer";
  //去掉双击事件
  viewer.cesiumWidget.screenSpaceEventHandler.removeInputAction(
    Cesium.ScreenSpaceEventType.LEFT_DOUBLE_CLICK
  );
  isEditting = false;
  handler = new Cesium.ScreenSpaceEventHandler(viewer.scene.canvas);
  //鼠标点击事件
  handler.setInputAction((event) => {
    let windowPosition = event.position;
    let pickedObject = viewer.scene.pick(windowPosition);
    if (Cesium.defined(pickedObject)) {
      let entity = pickedObject.id;
      if (entity.name === "ellipse" && !isEditting) {
        editObj = entity;
        //获取圆心与半径
        var circle_center_cartesian = editObj.position.getValue(
          Cesium.JulianDate.now()
        );
        var circleRadius = editObj.ellipse.semiMinorAxis.getValue();
        console.log("可编辑圆的圆心：", circle_center_cartesian);
        console.log("可编辑圆的半径：", circleRadius);
        //生成圆心编辑点
        var centerEditPoint = viewer.entities.add({
          name: "circle_point",
          position: circle_center_cartesian,
          point: {
            color: Cesium.Color.RED,
            pixelSize: 10,
            outlineColor: Cesium.Color.BLACK,
            outlineWidth: 1,
            heightReference: Cesium.HeightReference.CLAMP_TO_GROUND, //贴地
          },
        });
        centerEditPoint.flag = "centerPoint";
        pointsId.push(centerEditPoint.id);
        //生成圆边编辑点
        //圆半径换成米
        var degreeTemp = circleRadius / degreeMeter; //该值在不同的纬度上不同的值，可以根据自己的情况进行调整
        //获取圆心（经度）
        var ellipsoid = viewer.scene.globe.ellipsoid;
        var cartographic = ellipsoid.cartesianToCartographic(
          circle_center_cartesian
        );
        var circleCenterLng = Cesium.Math.toDegrees(cartographic.longitude);
        var circleCenterLat = Cesium.Math.toDegrees(cartographic.latitude);
        //获取圆边经纬度
        var circleBorderCartesian = Cesium.Cartesian3.fromDegrees(
          circleCenterLng + degreeTemp,
          circleCenterLat,
          0
        );
        var circle_border_point = viewer.entities.add({
          name: "circle_point",
          position: circleBorderCartesian,
          point: {
            color: Cesium.Color.WHITE,
            pixelSize: 10,
            outlineColor: Cesium.Color.BLACK,
            outlineWidth: 1,
            heightReference: Cesium.HeightReference.CLAMP_TO_GROUND, //贴地
          },
        });
        circle_border_point.flag = "borderPoint";
        pointsId.push(circle_border_point.id);
        //var d = Cesium.Cartesian3.distance(circle_center_cartesian, circle_border_cartesian);
        //进入编辑状态
        isEditting = true;
        //禁止地图的鼠标操作
        viewer.scene.screenSpaceCameraController.enableRotate = false;
        viewer.scene.screenSpaceCameraController.enableZoom = false;
      } else if (entity.name === "circle_point") {
        currentPoint = entity;
      }
    }
  }, Cesium.ScreenSpaceEventType.LEFT_DOWN);

  // 对鼠标移动事件的监听
  handler.setInputAction((event) => {
    if (isEditting && currentPoint && currentPoint.name == "circle_point") {
      //获取加载地形后对应的经纬度和高程：地标坐标
      var ray = viewer.camera.getPickRay(event.endPosition);
      var cartesian = viewer.scene.globe.pick(ray, viewer.scene);
      if (!cartesian) {
        return;
      }
      //更新当前点的位置
      currentPoint.position = cartesian;
      //移动的是半径点，则更新半径
      if (currentPoint.flag == "borderPoint") {
        var centerTemp = viewer.scene.globe.ellipsoid.cartesianToCartographic(
          editObj.position.getValue(Cesium.JulianDate.now())
        );
        var radiusTemp = viewer.scene.globe.ellipsoid.cartesianToCartographic(
          currentPoint.position.getValue(Cesium.JulianDate.now())
        );
        var geodesic = new Cesium.EllipsoidGeodesic();
        geodesic.setEndPoints(centerTemp, radiusTemp);
        var radius = geodesic.surfaceDistance;
        editObj.ellipse.semiMinorAxis = new Cesium.CallbackProperty(function (
          time,
          result
        ) {
          return radius;
        },
        false);
        editObj.ellipse.semiMajorAxis = new Cesium.CallbackProperty(function (
          time,
          result
        ) {
          return radius;
        },
        false);
      }
      //移动的是圆中心，则更新圆中心
      if (currentPoint.flag == "centerPoint") {
        //更新圆边编辑点
        var circleRadius = editObj.ellipse.semiMinorAxis.getValue();
        //圆半径换成米
        var degreeTemp = circleRadius / degreeMeter; //该值在不同的纬度上不同的值，可以根据自己的情况进行调整
        //获取圆心（经度）
        var ellipsoid = viewer.scene.globe.ellipsoid;
        var cartographic = ellipsoid.cartesianToCartographic(
          currentPoint.position.getValue(Cesium.JulianDate.now())
        );
        var circleCenterLng = Cesium.Math.toDegrees(cartographic.longitude);
        var circleCenterLat = Cesium.Math.toDegrees(cartographic.latitude);
        //获取圆边经纬度
        var circleBorderCartesian = Cesium.Cartesian3.fromDegrees(
          circleCenterLng + degreeTemp,
          circleCenterLat,
          0
        );
        for (var i = 0; i < pointsId.length; i++) {
          var entityTemp = viewer.entities.getById(pointsId[i]);
          if (entityTemp.flag == "borderPoint") {
            //console.log("circleBorderCartesian:",circleBorderCartesian);
            entityTemp.position = circleBorderCartesian;
          }
        }
        //更新圆中心点
        var positionTemp = currentPoint.position.getValue(
          Cesium.JulianDate.now()
        );
        editObj.position = new Cesium.CallbackProperty(function (time, result) {
          return positionTemp;
        }, false);
      }
    }
  }, Cesium.ScreenSpaceEventType.MOUSE_MOVE);

  // 对鼠标抬起事件的监听
  handler.setInputAction((event) => {
    //isEditting = false;
    currentPoint = undefined;
  }, Cesium.ScreenSpaceEventType.LEFT_UP);
}

function endEditEllipse() {
  viewer.scene.screenSpaceCameraController.enableRotate = true;
  viewer.scene.screenSpaceCameraController.enableZoom = true;
  if (handler !== null && !handler.isDestroyed()) {
    handler.destroy();
  }
  for (let id of pointsId) {
    viewer.entities.removeById(id);
  }
  pointsId = [];
  if (editObj == null) return;
  //获取圆心与半径
  var circle_center_cartesian = editObj.position.getValue(
    Cesium.JulianDate.now()
  );
  var ellipsoid = viewer.scene.globe.ellipsoid;
  var cartographic = ellipsoid.cartesianToCartographic(circle_center_cartesian);
  var lat = Cesium.Math.toDegrees(cartographic.latitude);
  var lng = Cesium.Math.toDegrees(cartographic.longitude);
  var height = cartographic.height;
  console.log("圆中心点：");
  console.log("经度：" + lng + ",纬度：" + +lat + ",高度：" + height);
  var circleRadius = editObj.ellipse.semiMinorAxis.getValue();
  console.log("圆半径：", circleRadius + "米");
  editObj = null;
  //鼠标变成默认
  mapRef.value.style.cursor = "default";
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
  // modifyMap(viewer, {
  //   invertColor: true,
  //   filterRGB: [27, 173, 170],
  // });
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
