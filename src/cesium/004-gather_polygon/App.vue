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
    <input
      type="button"
      @click="editPolygon"
      value="鼠标选中可编辑面进入编辑"
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
      @click="endEditPolygon"
      value="可编辑面结束编辑"
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
      name: "origin_point",
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
var currentPoint = null;
var pointsId = [];
var halfPointsId = [];
var handler = null;
var gon = null;

function editPolygon() {
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
      if (entity.name === "polygon" && !isEditting) {
        gon = entity;
        // 生成编辑点
        var cartesianArr = gon.polygon.hierarchy.getValue().positions;
        for (var i = 0; i < cartesianArr.length; i++) {
          var cartesian = cartesianArr[i];
          var point = viewer.entities.add({
            name: "polygon_point",
            position: cartesian,
            point: {
              color: Cesium.Color.WHITE,
              pixelSize: 8,
              outlineColor: Cesium.Color.BLACK,
              outlineWidth: 1,
              heightReference: Cesium.HeightReference.CLAMP_TO_GROUND, //贴地
            },
          });
          pointsId.push(point.id);
        }

        //生成half采集点
        for (var i = 0; i < cartesianArr.length; i++) {
          if (i == cartesianArr.length - 1) {
            var halfX = (cartesianArr[i].x + cartesianArr[0].x) / 2;
            var halfY = (cartesianArr[i].y + cartesianArr[0].y) / 2;
            var halfZ = (cartesianArr[i].z + cartesianArr[0].z) / 2;
            var cartesian = new Cesium.Cartesian3(halfX, halfY, halfZ);
          } else {
            var halfX = (cartesianArr[i].x + cartesianArr[i + 1].x) / 2;
            var halfY = (cartesianArr[i].y + cartesianArr[i + 1].y) / 2;
            var halfZ = (cartesianArr[i].z + cartesianArr[i + 1].z) / 2;
            var cartesian = new Cesium.Cartesian3(halfX, halfY, halfZ);
          }
          var pointEntity = {
            name: "polygon_half_point",
            position: cartesian,
            point: {
              color: Cesium.Color.RED,
              pixelSize: 8,
              outlineColor: Cesium.Color.BLACK,
              outlineWidth: 1,
              heightReference: Cesium.HeightReference.CLAMP_TO_GROUND, //贴地
            },
          };
          if (i == cartesianArr.length - 1) {
            pointEntity.positionFlag = [i, 0];
          } else {
            pointEntity.positionFlag = [i, i + 1];
          }
          var point = viewer.entities.add(pointEntity);
          halfPointsId.push(point.id);
        }

        isEditting = true;
        viewer.scene.screenSpaceCameraController.enableRotate = false;
        viewer.scene.screenSpaceCameraController.enableZoom = false;
      } else if (entity.name === "polygon_point") {
        currentPoint = entity;
      } else if (entity.name === "polygon_half_point") {
        //线半点变线上（点击变颜色）
        //线上的中心点移动：更新points
        let ellipsoid = viewer.scene.globe.ellipsoid;
        let cartesian = viewer.camera.pickEllipsoid(windowPosition, ellipsoid);
        if (!cartesian) {
          return;
        }
        var entityTemp = {
          name: "polygon_point",
          position: cartesian,
          point: {
            color: Cesium.Color.WHITE,
            pixelSize: 8,
            outlineColor: Cesium.Color.BLACK,
            outlineWidth: 1,
            heightReference: Cesium.HeightReference.CLAMP_TO_GROUND, //贴地
          },
        };
        var point = viewer.entities.add(entityTemp);
        currentPoint = point;
        //线半点变成线上点
        pointsId.splice(entity.positionFlag[0] + 1, 0, point.id);
        //删除所有线半点
        for (var i = 0; i < halfPointsId.length; i++) {
          viewer.entities.remove(viewer.entities.getById(halfPointsId[i]));
        }
        halfPointsId = [];
        //重新生成所有线半点
        console.log("pointsId", pointsId);
        for (var i = 0; i < pointsId.length; i++) {
          var oneTemp = null;
          var twoTemp = null;
          if (i == pointsId.length - 1) {
            oneTemp = viewer.entities.getById(pointsId[i]).position._value;
            twoTemp = viewer.entities.getById(pointsId[0]).position._value;
          } else {
            oneTemp = viewer.entities.getById(pointsId[i]).position._value;
            twoTemp = viewer.entities.getById(pointsId[i + 1]).position._value;
          }
          var halfX = (oneTemp.x + twoTemp.x) / 2;
          var halfY = (oneTemp.y + twoTemp.y) / 2;
          var halfZ = (oneTemp.z + twoTemp.z) / 2;
          var cartesianHalf = new Cesium.Cartesian3(halfX, halfY, halfZ);
          var pointEntity = {
            name: "polygon_half_point",
            position: cartesianHalf,
            point: {
              color: Cesium.Color.RED,
              pixelSize: 8,
              outlineColor: Cesium.Color.BLACK,
              outlineWidth: 1,
              heightReference: Cesium.HeightReference.CLAMP_TO_GROUND, //贴地
            },
          };
          if (i == pointsId.length - 1) {
            pointEntity.positionFlag = [i, 0];
          } else {
            pointEntity.positionFlag = [i, i + 1];
          }
          var point = viewer.entities.add(pointEntity);
          halfPointsId.push(point.id);
        }
      }
    }
  }, Cesium.ScreenSpaceEventType.LEFT_DOWN);

  // 对鼠标移动事件的监听
  handler.setInputAction((event) => {
    if (isEditting && currentPoint && currentPoint.name == "polygon_point") {
      //获取加载地形后对应的经纬度和高程：地标坐标
      //console.log("event-move",event);
      var ray = viewer.camera.getPickRay(event.endPosition);
      var cartesian = viewer.scene.globe.pick(ray, viewer.scene);
      let points = [];
      if (!cartesian) {
        return;
      }
      currentPoint.position = cartesian;
      for (var i = 0; i < pointsId.length; i++) {
        if (currentPoint.id == pointsId[i]) {
          points.push(currentPoint.position._value);
        } else {
          var id = pointsId[i];
          points.push(viewer.entities.getById(id).position._value);
        }
      }

      //更新线上中心点位置信息
      for (var i = 0; i < halfPointsId.length; i++) {
        var entityTemp = viewer.entities.getById(halfPointsId[i]);
        if (typeof entityTemp != "undefined") {
          //console.log("entityTemp",entityTemp);
          var oneTemp = entityTemp.positionFlag[0];
          var twoTemp = entityTemp.positionFlag[1];
          if (
            typeof points[oneTemp] != "undefined" &&
            typeof points[twoTemp] != "undefined"
          ) {
            var halfX = (points[oneTemp].x + points[twoTemp].x) / 2;
            var halfY = (points[oneTemp].y + points[twoTemp].y) / 2;
            var halfZ = (points[oneTemp].z + points[twoTemp].z) / 2;
            var cartesian = new Cesium.Cartesian3(halfX, halfY, halfZ);
            entityTemp.position = cartesian;
          }
        }
      }

      gon.polygon.hierarchy = new Cesium.CallbackProperty(function (
        time,
        result
      ) {
        var hierarchyTemp = new Cesium.PolygonHierarchy(points, null);
        return hierarchyTemp;
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

function endEditPolygon() {
  viewer.scene.screenSpaceCameraController.enableRotate = true;
  viewer.scene.screenSpaceCameraController.enableZoom = true;
  if (handler !== null && !handler.isDestroyed()) {
    handler.destroy();
  }
  for (let id of pointsId) {
    viewer.entities.removeById(id);
  }
  pointsId = [];

  for (let id of halfPointsId) {
    viewer.entities.removeById(id);
  }
  halfPointsId = [];

  var dke = gon.polygon.hierarchy.getValue().positions;
  console.log("修改后的面坐标(笛卡尔)：", dke);
  var objArr = [];
  for (var i = 0; i < dke.length; i++) {
    var ellipsoid = viewer.scene.globe.ellipsoid;
    var cartesian3 = new Cesium.Cartesian3(dke[i].x, dke[i].y, dke[i].z);
    var cartographic = ellipsoid.cartesianToCartographic(cartesian3);
    console.log("cartographic", cartographic);
    var obj = {};
    obj.lat = Cesium.Math.toDegrees(cartographic.latitude);
    obj.lng = Cesium.Math.toDegrees(cartographic.longitude);
    obj.alt = cartographic.height;
    objArr.push(obj);
  }
  console.log("修改后的面坐标(经纬度)", objArr);
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
