import {createApp} from 'vue'
import './style.css'
import 'virtual:uno.css'
import App from './App.vue'
// Register Components
import {registerGlobalComponents} from "./components";

const app = createApp(App);
registerGlobalComponents(app);
app.mount('#app')
