<script setup lang="ts">
import { useTvStore } from '../../stores/tvStore';

const tvStore = useTvStore();
</script>

<template>
  <div 
    id="tv-cursor-box" 
    class="tv-cursor-box" 
    :class="{ 'active': tvStore.isTvMode && tvStore.currentFocusedEl }"
  ></div>
</template>

<style scoped>
.tv-cursor-box {
  position: fixed;
  pointer-events: none;
  z-index: 9999;
  border-radius: 12px;
  border: 3px solid #00d2ff;
  box-shadow: 0 0 24px rgba(0, 210, 255, 0.8), inset 0 0 12px rgba(0, 210, 255, 0.3);
  transition: all 0.22s cubic-bezier(0.16, 1, 0.3, 1);
  display: none;
  opacity: 0;
}

.tv-cursor-box.active {
  display: block;
  opacity: 1;
}
</style>
