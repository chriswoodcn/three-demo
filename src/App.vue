<!--
 * @Author: chriswoodcn
 * @Email: chriswoodcn@aliyun.com
 * @Date: 2023-10-27 21:39:21
 * @LastEditors: chriswoodcn
 * @LastEditTime: 2023-10-29 18:30:50
 * @FilePath: \three-demo\src\App.vue
 * @Description: 
 * Copyright (c) 2023 by chriswoodcn, All Rights Reserved. 
-->
<script setup>
import { ref, onMounted } from "vue";
// import { renderer, animate } from "./components/startup";
// import { renderer, animate } from "./components/envmap";
import { renderer, animate } from "./components/points";
animate();
const mapRef = ref();
onMounted(() => {
  mapRef.value.appendChild(renderer.domElement);
});
</script>

<template>
  <div ref="mapRef" class="w-full h-full bg-blueGray"></div>
</template>
