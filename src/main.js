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
import App from "./cesium/008-3d_tile/App.vue";
// Register Components
import { registerGlobalComponents } from "./components";

const app = createApp(App);
registerGlobalComponents(app);
app.mount("#app");
