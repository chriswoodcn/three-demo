import { createApp } from "vue";
import "./style.css";
import "virtual:uno.css";
// import App from './App.vue'
// import App from './cesium/001-imagery_provider/App.vue'
// import App from "./cesium/002-gather_point/App.vue";
import App from "./cesium/003-gather_polyline/App.vue";
// import App from "./cesium/004-gather_polygon/App.vue";
// Register Components
import { registerGlobalComponents } from "./components";

const app = createApp(App);
registerGlobalComponents(app);
app.mount("#app");
