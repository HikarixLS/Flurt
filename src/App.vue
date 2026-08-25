<script setup lang="ts">
import Navbar from './components/common/Navbar.vue';
import Footer from './components/common/Footer.vue';
import TvCursor from './components/common/TvCursor.vue';
import { useTvNavigation } from './composables/useTvNavigation';

// Initialize TV remote & spatial keyboard navigation
useTvNavigation();
</script>

<template>
  <div id="flurt-app-layout" class="app-layout">
    <!-- Top Floating Navbar -->
    <Navbar />

    <!-- Main Content Area with Page Transitions -->
    <main class="main-content-view">
      <router-view v-slot="{ Component }">
        <transition name="page-fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>

    <!-- TV Remote Bounding Focus Glow Cursor -->
    <TvCursor />

    <!-- Footer -->
    <Footer />
  </div>
</template>

<style>
.app-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: var(--bg-main);
  color: var(--text-main);
}

.main-content-view {
  flex: 1;
}

/* Page Transition Animations */
.page-fade-enter-active,
.page-fade-leave-active {
  transition: opacity 0.28s ease, transform 0.28s cubic-bezier(0.16, 1, 0.3, 1);
}

.page-fade-enter-from {
  opacity: 0;
  transform: translateY(12px) scale(0.99);
}

.page-fade-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}
</style>
