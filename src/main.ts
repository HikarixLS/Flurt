import { createApp } from 'vue';
import { createPinia } from 'pinia';
import App from './App.vue';
import router from './router';

// Design System & TV styles
import './assets/styles/main.css';
import './assets/styles/tv-mode.css';

const app = createApp(App);

app.use(createPinia());
app.use(router);

app.mount('#app');
