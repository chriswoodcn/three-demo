/*
 * @Author: chriswoodcn
 * @Email: chriswoodcn@aliyun.com
 * @Date: 2023-11-02 19:18:05
 * @LastEditors: chriswoodcn
 * @LastEditTime: 2023-11-08 21:33:39
 * @FilePath: \three-demo\src\main.js
 * @Description: 
 * Copyright (c) 2023 by chriswoodcn, All Rights Reserved. 
 */
import { createApp } from "vue";
import "./style.css";
import "virtual:uno.css";
// import App from './App.vue'
// import App from './cesium/001-imagery_provider/App.vue'
// import App from "./cesium/002-gather_point/App.vue";
// import App from "./cesium/003-gather_polyline/App.vue";
// import App from "./cesium/004-gather_polygon/App.vue";
// import App from "./cesium/005-gather_rect/App.vue";
// import App from "./cesium/006-gather_ellipse/App.vue";
// import App from "./cesium/007-theme/App.vue";
// import App from "./cesium/008-3d_tile/App.vue";
// import App from "./cesium/009-3d_tile_adjust/App.vue";
// import App from "./cesium/010-offline_terrian/App.vue";
// import App from "./cesium/011-osm_building/App.vue";
// import App from "./cesium/012-osm_building_info/App.vue";
import App from "./cesium/013-osm_building_color/App.vue";
// Register Components
import { registerGlobalComponents } from "./components";

const app = createApp(App);
registerGlobalComponents(app);
app.mount("#app");
