<script setup>
import { ref, onMounted } from "vue";
// import { renderer, animate } from "./components/startup";
// import { renderer, animate } from "./components/envmap";
// import { renderer, animate } from "./components/points";
import { renderer, animate } from "./components/raycaster";
animate();
const mapRef = ref();
onMounted(() => {
  mapRef.value.appendChild(renderer.domElement);
});
</script>

<template>
  <div ref="mapRef" class="w-full h-full"></div>
</template>
