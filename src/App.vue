<script setup>
import { ref, onMounted } from "vue";
// import { renderer, animate } from "./components/startup";
// import { renderer, animate } from "./components/envmap";
// import { renderer, animate } from "./components/points";
// import { renderer, animate } from "./components/raycaster";
// animate();
// const mapRef = ref();
// onMounted(() => {
//   mapRef.value.appendChild(renderer.domElement);
// });
import * as Cesium from "cesium";
onMounted(() => {
  const viewer = new Cesium.Viewer("cesium");
});
</script>

<template>
  <div id="cesium" ref="mapRef" class="w-full h-full"></div>
</template>
