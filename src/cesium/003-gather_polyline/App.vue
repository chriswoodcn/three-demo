<template>
  <div id="cesiumContainer" ref="mapRef" class="w-full h-full">
    <input
      type="button"
      value="线采集"
      @click="gatherPolylineFun"
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
      @click="addPolyline"
      value="添加可编辑线"
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
      @click="editPolyline"
      value="鼠标选中可编辑线进入编辑"
      style="
        position: absolute;
        left: 50px;
        top: 150px;
        background: blue;
        color: white;
        z-index: 9999;
      "
    />
    <input
      type="button"
      @click="endEditPolyline"
      value="可编辑线结束编辑"
      style="
        position: absolute;
        left: 50px;
        top: 200px;
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
var gatherPolyline = null;
//采集线
function gatherPolylineFun() {
  var gatherPoints = [];
  var points = [];
  gatherPolyline = null;
  var polylineGatherHandler = new Cesium.ScreenSpaceEventHandler(viewer.canvas);
  //鼠标变成加号
  mapRef.value.style.cursor = "crosshair";
  // 对鼠标按下事件的监听
  polylineGatherHandler.setInputAction(function (event) {
    //获取加载地形后对应的经纬度和高程：地标坐标
    var ray = viewer.camera.getPickRay(event.position);
    var cartesian = viewer.scene.globe.pick(ray, viewer.scene);
    //获取倾斜摄影或模型点击处的坐标：场景坐标
    //var cartesian = viewer.scene.pick(event.position);
    //console.log("cartesian:", cartesian);
    if (!Cesium.defined(cartesian)) {
      return;
    }
    var point = viewer.entities.add({
      name: "polyline_point",
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

    if (points.length >= 2) {
      if (gatherPolyline == null) {
        gatherPolyline = viewer.entities.add({
          name: "polyline_instance",
          polyline: {
            //positions: points,
            positions: new Cesium.CallbackProperty(function (time, result) {
              return points;
            }, false),
            width: 10.0,
            clampToGround: true,
            material: new Cesium.PolylineGlowMaterialProperty({
              color: Cesium.Color.CHARTREUSE.withAlpha(0.5),
            }),
          },
        });
      } else {
        //CallbackProperty监听point变化值会自动set
      }
    }
  }, Cesium.ScreenSpaceEventType.LEFT_CLICK);

  polylineGatherHandler.setInputAction(function (rightClick) {
    //方法1
    //var dke=points;
    //方法2
    var dke = gatherPolyline.polyline.positions.getValue();
    console.log("采集的线坐标(笛卡尔)：", dke);
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
    console.log("采集的线坐标(经纬度)", objArr);
    for (var i = 0; i < gatherPoints.length; i++) {
      viewer.entities.remove(gatherPoints[i]);
    }
    gatherPoints = [];
    //points = [];//注：points不可置空，如果置空，会导致地图上的点也不存在。
    //鼠标变成加号
    mapRef.value.style.cursor = "default";
    //移除地图点击事件
    polylineGatherHandler.removeInputAction(
      Cesium.ScreenSpaceEventType.LEFT_CLICK
    ); //移除事件
  }, Cesium.ScreenSpaceEventType.RIGHT_CLICK);
}
//可编辑线
function addPolyline() {
  var polyline = viewer.entities.add({
    name: "polyline",
    polyline: {
      positions: Cesium.Cartesian3.fromDegreesArray([
        118.1044813816513, 24.451483144361173, 118.0850887298584,
        24.439001083374023, 118.0850887298584, 24.469001083374023,
      ]),
      width: 10,
      clampToGround: true,
      material: new Cesium.PolylineGlowMaterialProperty({
        glowPower: 0.2, //一个数字属性，用于指定发光强度，以总线宽的百分比表示。
        taperPower: 1, //一个数字属性，指定渐缩效果的强度，以总行长的百分比表示。如果为1.0或更高，则不使用锥度效果。
        color: Cesium.Color.CORNFLOWERBLUE,
      }),
    },
  });
}
var currentPoint = null;
var pointsId = [];
var halfPointsId = [];
var handler = null;
var gon = null;

function editPolyline() {
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
      if (entity.name === "polyline_instance" && !isEditting) {
        gon = entity;
        // 生成编辑点
        var cartesianArr = gon.polyline.positions.getValue();
        for (var i = 0; i < cartesianArr.length; i++) {
          var cartesian = cartesianArr[i];
          var point = viewer.entities.add({
            name: "polyline_point",
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
        for (var i = 0; i < cartesianArr.length - 1; i++) {
          var halfX = (cartesianArr[i].x + cartesianArr[i + 1].x) / 2;
          var halfY = (cartesianArr[i].y + cartesianArr[i + 1].y) / 2;
          var halfZ = (cartesianArr[i].z + cartesianArr[i + 1].z) / 2;
          var cartesian = new Cesium.Cartesian3(halfX, halfY, halfZ);
          var pointEntity = {
            name: "polyline_half_point",
            position: cartesian,
            point: {
              color: Cesium.Color.RED,
              pixelSize: 8,
              outlineColor: Cesium.Color.BLACK,
              outlineWidth: 1,
              heightReference: Cesium.HeightReference.CLAMP_TO_GROUND, //贴地
            },
          };
          pointEntity.positionFlag = [i, i + 1];
          var point = viewer.entities.add(pointEntity);
          halfPointsId.push(point.id);
        }
        isEditting = true;
        viewer.scene.screenSpaceCameraController.enableRotate = false;
        viewer.scene.screenSpaceCameraController.enableZoom = false;
      } else if (entity.name === "polyline_point") {
        currentPoint = entity;
      } else if (entity.name === "polyline_half_point") {
        //线半点变线上（点击变颜色）
        //线上的中心点移动：更新points
        let ellipsoid = viewer.scene.globe.ellipsoid;
        let cartesian = viewer.camera.pickEllipsoid(windowPosition, ellipsoid);
        if (!cartesian) {
          return;
        }
        var entityTemp = {
          name: "polyline_point",
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
        //console.log("pointsId",pointsId);
        for (var i = 0; i < pointsId.length - 1; i++) {
          var oneTemp = viewer.entities.getById(pointsId[i]).position._value;
          var twoTemp = viewer.entities.getById(pointsId[i + 1]).position
            ._value;
          var halfX = (oneTemp.x + twoTemp.x) / 2;
          var halfY = (oneTemp.y + twoTemp.y) / 2;
          var halfZ = (oneTemp.z + twoTemp.z) / 2;
          var cartesianHalf = new Cesium.Cartesian3(halfX, halfY, halfZ);
          var pointEntity = {
            name: "polyline_half_point",
            position: cartesianHalf,
            point: {
              color: Cesium.Color.RED,
              pixelSize: 8,
              outlineColor: Cesium.Color.BLACK,
              outlineWidth: 1,
              heightReference: Cesium.HeightReference.CLAMP_TO_GROUND, //贴地
            },
          };
          pointEntity.positionFlag = [i, i + 1];
          var point = viewer.entities.add(pointEntity);
          halfPointsId.push(point.id);
        }
      }
    }
  }, Cesium.ScreenSpaceEventType.LEFT_DOWN);

  // 对鼠标移动事件的监听
  handler.setInputAction((event) => {
    //console.log("currentPoint11",currentPoint);
    if (isEditting && currentPoint && currentPoint.name == "polyline_point") {
      //线上的点
      //获取加载地形后对应的经纬度和高程：地标坐标
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
      gon.polyline.positions = new Cesium.CallbackProperty(function (
        time,
        result
      ) {
        //更新线上中心点位置信息
        for (var i = 0; i < halfPointsId.length; i++) {
          var entityTemp = viewer.entities.getById(halfPointsId[i]);
          if (typeof entityTemp != "undefined") {
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
        return points;
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

function endEditPolyline() {
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

  var dke = gon.polyline.positions.getValue();
  console.log("修改后的面坐标(笛卡尔)：", dke);
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
