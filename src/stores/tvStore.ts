import { defineStore } from 'pinia';
import { ref, watch } from 'vue';

export const useTvStore = defineStore('tv', () => {
  const savedTvMode = localStorage.getItem('flurt_tv_mode') === 'true';
  const isTvMode = ref(savedTvMode);
  const currentFocusedEl = ref<HTMLElement | null>(null);

  const setTvMode = (active: boolean) => {
    isTvMode.value = active;
    localStorage.setItem('flurt_tv_mode', String(active));
    if (active) {
      document.body.classList.add('tv-mode-active');
    } else {
      document.body.classList.remove('tv-mode-active');
    }
  };

  // Sync class on body
  watch(isTvMode, (val) => {
    if (val) {
      document.body.classList.add('tv-mode-active');
    } else {
      document.body.classList.remove('tv-mode-active');
    }
  }, { immediate: true });

  const setFocusedElement = (el: HTMLElement | null) => {
    if (currentFocusedEl.value) {
      currentFocusedEl.value.classList.remove('tv-focused');
    }
    currentFocusedEl.value = el;
    if (el) {
      el.classList.add('tv-focused');
      el.focus({ preventScroll: true });
      el.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'nearest' });
    }
  };

  return {
    isTvMode,
    currentFocusedEl,
    setTvMode,
    setFocusedElement
  };
});
