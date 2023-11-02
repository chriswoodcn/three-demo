<template>
  <div id="cesiumContainer" ref="mapRef" class="w-full h-full">
    <input
      type="button"
      @click="gatherRect"
      value="矩形采集(鼠标点击后压住拖动)"
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
      @click="editRect"
      value="鼠标选中可编辑矩形进入编辑"
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
      @click="endEditRect"
      value="可编辑矩形结束编辑"
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
//矩形采集
var handler = null;
var startPoint = null;
var rect = null;
function gatherRect() {
  rect = null;
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
    console.log("cartesian:", cartesian);
    if (!Cesium.defined(cartesian)) {
      return;
    }
    startPoint = viewer.entities.add({
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

    rect = viewer.entities.add({
      name: "rect",
      rectangle: {
        coordinates: Cesium.Rectangle.fromCartesianArray([
          cartesian,
          cartesian,
        ]),
        material: Cesium.Color.GREENYELLOW.withAlpha(0.5),
        outline: true,
        outlineColor: Cesium.Color.WHITE,
        outlineWidth: 3,
      },
    });
  }, Cesium.ScreenSpaceEventType.LEFT_DOWN);

  // 对鼠标移动事件的监听
  handler.setInputAction((event) => {
    if (startPoint == null || rect == null) {
      return;
    }
    //获取加载地形后对应的经纬度和高程：地标坐标
    var ray = viewer.camera.getPickRay(event.endPosition);
    var cartesian = viewer.scene.globe.pick(ray, viewer.scene);
    if (!cartesian) {
      return;
    }
    //console.log("cartesian:", cartesian);
    var startCartesian = startPoint.position.getValue(Cesium.JulianDate.now());
    //console.log("startCartesian:",startCartesian);

    rect.rectangle.coordinates = new Cesium.CallbackProperty(function (
      time,
      result
    ) {
      return Cesium.Rectangle.fromCartesianArray([startCartesian, cartesian]);
    },
    false);
  }, Cesium.ScreenSpaceEventType.MOUSE_MOVE);

  // 对鼠标抬起事件的监听(结束点采集)
  handler.setInputAction((event) => {
    //鼠标变成默认
    mapRef.value.style.cursor = "default";
    //开启地图移动
    viewer.scene.screenSpaceCameraController.enableRotate = true;
    viewer.scene.screenSpaceCameraController.enableZoom = true;
    viewer.entities.remove(startPoint);
    //移除地图鼠标点击事件
    handler.removeInputAction(Cesium.ScreenSpaceEventType.LEFT_DOWN);
    //移除地图鼠标移动事件
    handler.removeInputAction(Cesium.ScreenSpaceEventType.MOUSE_MOVE);
    //移除地图鼠标抬起事件
    handler.removeInputAction(Cesium.ScreenSpaceEventType.LEFT_UP);

    var dke = rect.rectangle.coordinates.getValue();
    console.log("修改后的面坐标(笛卡尔)：", dke);
    var east = Cesium.Math.toDegrees(dke.east);
    var west = Cesium.Math.toDegrees(dke.west);
    var north = Cesium.Math.toDegrees(dke.north);
    var south = Cesium.Math.toDegrees(dke.south);
    console.log("矩形西南东北坐标:", west, south, east, north);
  }, Cesium.ScreenSpaceEventType.LEFT_UP);
}

//当前编辑点
var currentPoint = null;
//所有编辑点
var pointsId = [];
//事件
var handler = null;
//当前编辑事件
var gon = null;
//中心编辑点
var centerPoint = null;

function editRect() {
  mapRef.value.style.cursor = "pointer";
  //去掉双击事件
  viewer.cesiumWidget.screenSpaceEventHandler.removeInputAction(
    Cesium.ScreenSpaceEventType.LEFT_DOUBLE_CLICK
  );

  let isEditting = false;
  handler = new Cesium.ScreenSpaceEventHandler(viewer.scene.canvas);
  //鼠标点击事件
  handler.setInputAction((event) => {
    let windowPosition = event.position;
    let pickedObject = viewer.scene.pick(windowPosition);
    if (Cesium.defined(pickedObject)) {
      let entity = pickedObject.id;
      if (entity.name === "rect" && !isEditting) {
        gon = entity;
        // 生成边界编辑点
        var degrees = gon.rectangle.coordinates.getValue();
        var cartesianArr = [];
        var westNorth = Cesium.Cartesian3.fromRadians(
          degrees.west,
          degrees.north
        );
        westNorth.flag = "westNorth";
        cartesianArr.push(westNorth);
        var eastNorth = Cesium.Cartesian3.fromRadians(
          degrees.east,
          degrees.north
        );
        eastNorth.flag = "eastNorth";
        cartesianArr.push(eastNorth);
        var eastSouth = Cesium.Cartesian3.fromRadians(
          degrees.east,
          degrees.south
        );
        eastSouth.flag = "eastSouth";
        cartesianArr.push(eastSouth);
        var westSouth = Cesium.Cartesian3.fromRadians(
          degrees.west,
          degrees.south
        );
        westSouth.flag = "westSouth";
        cartesianArr.push(westSouth);
        console.log("cartesianArr", cartesianArr);
        for (var i = 0; i < cartesianArr.length; i++) {
          var cartesian = cartesianArr[i];
          var point = viewer.entities.add({
            name: "rect_point",
            position: cartesian,
            point: {
              color: Cesium.Color.WHITE,
              pixelSize: 8,
              outlineColor: Cesium.Color.BLACK,
              outlineWidth: 1,
              heightReference: Cesium.HeightReference.CLAMP_TO_GROUND, //贴地
            },
          });
          point.flag = cartesian.flag;
          pointsId.push(point.id);
        }
        // 生成中心编辑点
        var centerLng = (degrees.west + degrees.east) / 2;
        var centerLat = (degrees.north + degrees.south) / 2;
        var rect_center_cartesian = Cesium.Cartesian3.fromRadians(
          centerLng,
          centerLat
        );
        var pointTemp = viewer.entities.add({
          name: "rect_point",
          position: rect_center_cartesian,
          point: {
            color: Cesium.Color.RED,
            pixelSize: 10,
            outlineColor: Cesium.Color.BLACK,
            outlineWidth: 1,
            heightReference: Cesium.HeightReference.CLAMP_TO_GROUND, //贴地
          },
        });
        pointTemp.flag = "center";
        pointsId.push(pointTemp.id);

        isEditting = true;
        viewer.scene.screenSpaceCameraController.enableRotate = false;
        viewer.scene.screenSpaceCameraController.enableZoom = false;
      } else if (entity.name === "rect_point") {
        currentPoint = entity;
      }
    }
  }, Cesium.ScreenSpaceEventType.LEFT_DOWN);

  // 对鼠标移动事件的监听
  handler.setInputAction((event) => {
    if (isEditting && currentPoint && currentPoint.name == "rect_point") {
      //获取加载地形后对应的经纬度和高程：地标坐标
      var ray = viewer.camera.getPickRay(event.endPosition);
      var cartesian = viewer.scene.globe.pick(ray, viewer.scene);
      let points = [];
      if (!cartesian) {
        return;
      }
      //更新当前点的位置
      currentPoint.position = cartesian;
      for (var i = 0; i < pointsId.length; i++) {
        if (currentPoint.id == pointsId[i]) {
          var objTemp = currentPoint.position._value;
          objTemp.flag = currentPoint.flag;
          points.push(objTemp);
        } else {
          var id = pointsId[i];
          var objTemp = viewer.entities.getById(id).position._value;
          objTemp.flag = viewer.entities.getById(id).flag;
          points.push(objTemp);
        }
      }
      if (typeof currentPoint == "undefined") {
        var radians = Cesium.Rectangle.fromDegrees(west, south, east, north);
        return radians;
      }
      //当前移动是哪个点，获取新的矩形边界
      var ellipsoid = viewer.scene.globe.ellipsoid;
      var lngArr = [];
      var latArr = [];
      if (
        currentPoint.flag == "westNorth" ||
        currentPoint.flag == "eastSouth"
      ) {
        for (var i = 0; i < points.length; i++) {
          if (points[i].flag == "westNorth" || points[i].flag == "eastSouth") {
            var cartographic = ellipsoid.cartesianToCartographic(points[i]);
            var lng = Cesium.Math.toDegrees(cartographic.longitude);
            var lat = Cesium.Math.toDegrees(cartographic.latitude);
            lngArr.push(lng);
            latArr.push(lat);
          }
        }
      } else if (
        currentPoint.flag == "eastNorth" ||
        currentPoint.flag == "westSouth"
      ) {
        for (var i = 0; i < points.length; i++) {
          if (points[i].flag == "eastNorth" || points[i].flag == "westSouth") {
            var cartographic = ellipsoid.cartesianToCartographic(points[i]);
            var lng = Cesium.Math.toDegrees(cartographic.longitude);
            var lat = Cesium.Math.toDegrees(cartographic.latitude);
            lngArr.push(lng);
            latArr.push(lat);
          }
        }
      } else if (currentPoint.flag == "center") {
        var cartographic = ellipsoid.cartesianToCartographic(
          currentPoint.position._value
        );
        var centerLng = Cesium.Math.toDegrees(cartographic.longitude);
        var centerLat = Cesium.Math.toDegrees(cartographic.latitude);
        //console.log("centerLng",centerLng);
        var rectInfo = gon.rectangle.coordinates.getValue();
        //console.log("currentPoint.position",currentPoint.position._value);
        var rectWidth =
          Cesium.Math.toDegrees(rectInfo.east) -
          Cesium.Math.toDegrees(rectInfo.west);
        var rectHeight =
          Cesium.Math.toDegrees(rectInfo.north) -
          Cesium.Math.toDegrees(rectInfo.south);
        //console.log("rectWidth:",rectWidth);
        var rectInfoEast = centerLng + rectWidth / 2;
        lngArr.push(rectInfoEast);
        var rectInfoWest = centerLng - rectWidth / 2;
        lngArr.push(rectInfoWest);
        var rectInfoNorth = centerLat + rectHeight / 2;
        latArr.push(rectInfoNorth);
        var rectInfoSouth = centerLat - rectHeight / 2;
        latArr.push(rectInfoSouth);
        //console.log("rectInfoEast",rectInfoEast);
        //console.log("经度组：",lngArr);
      }
      var east = Math.max.apply(null, lngArr);
      var west = Math.min.apply(null, lngArr);
      var north = Math.max.apply(null, latArr);
      var south = Math.min.apply(null, latArr);
      //更新所有编辑点的位置
      for (var i = 0; i < pointsId.length; i++) {
        var id = pointsId[i];
        var entityTemp = viewer.entities.getById(id);
        if (
          typeof entityTemp != "undefined" &&
          typeof currentPoint != "undefined"
        ) {
          if (entityTemp.flag != currentPoint.flag) {
            if (entityTemp.flag == "westNorth") {
              entityTemp.position = Cesium.Cartesian3.fromDegrees(west, north);
            } else if (entityTemp.flag == "eastNorth") {
              entityTemp.position = Cesium.Cartesian3.fromDegrees(east, north);
            } else if (entityTemp.flag == "eastSouth") {
              entityTemp.position = Cesium.Cartesian3.fromDegrees(east, south);
            } else if (entityTemp.flag == "westSouth") {
              entityTemp.position = Cesium.Cartesian3.fromDegrees(west, south);
            } else if (entityTemp.flag == "center") {
              var centerLng = (west + east) / 2;
              var centerLat = (north + south) / 2;
              entityTemp.position = Cesium.Cartesian3.fromDegrees(
                centerLng,
                centerLat
              );
            }
          }
        }
      }
      //console.log("坐标：",west, south, east, north);
      if (west >= east || south >= north) {
        currentPoint = undefined;
        return;
      }
      var radians = Cesium.Rectangle.fromDegrees(west, south, east, north);
      //更新矩形位置
      gon.rectangle.coordinates = new Cesium.CallbackProperty(function (
        time,
        result
      ) {
        return radians;
      },
      false);
    }
  }, Cesium.ScreenSpaceEventType.MOUSE_MOVE);

  // 对鼠标抬起事件的监听
  handler.setInputAction((event) => {
    // isEditting = false;
    currentPoint = undefined;
  }, Cesium.ScreenSpaceEventType.LEFT_UP);
}

function endEditRect() {
  viewer.scene.screenSpaceCameraController.enableRotate = true;
  viewer.scene.screenSpaceCameraController.enableZoom = true;
  if (handler !== null && !handler.isDestroyed()) {
    handler.destroy();
  }
  for (let id of pointsId) {
    viewer.entities.removeById(id);
  }
  pointsId = [];

  var dke = gon.rectangle.coordinates.getValue();
  console.log("修改后的面坐标(笛卡尔)：", dke);

  var east = Cesium.Math.toDegrees(dke.east);
  var west = Cesium.Math.toDegrees(dke.west);
  var north = Cesium.Math.toDegrees(dke.north);
  var south = Cesium.Math.toDegrees(dke.south);
  console.log("矩形西南东北坐标:", west, south, east, north);

  gon = null;
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
