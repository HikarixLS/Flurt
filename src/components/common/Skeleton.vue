<script setup lang="ts">
defineProps<{
  type?: 'card' | 'banner' | 'text' | 'circle';
  count?: number;
}>();
</script>

<template>
  <div v-if="type === 'banner'" class="skeleton-banner skeleton-shimmer"></div>
  
  <div v-else-if="type === 'card'" class="skeleton-cards-grid">
    <div v-for="i in (count || 6)" :key="i" class="skeleton-card">
      <div class="skeleton-thumb skeleton-shimmer"></div>
      <div class="skeleton-title skeleton-shimmer"></div>
      <div class="skeleton-sub skeleton-shimmer"></div>
    </div>
  </div>

  <div v-else-if="type === 'circle'" class="skeleton-circle skeleton-shimmer"></div>

  <div v-else class="skeleton-text skeleton-shimmer"></div>
</template>

<style scoped>
.skeleton-banner {
  width: 100%;
  height: 520px;
  border-radius: var(--radius-xl);
  margin-bottom: 40px;
}

.skeleton-cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 20px;
  width: 100%;
}

.skeleton-card {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.skeleton-thumb {
  width: 100%;
  aspect-ratio: 2 / 3;
  border-radius: var(--radius-md);
}

.skeleton-title {
  height: 16px;
  width: 80%;
  border-radius: var(--radius-sm);
}

.skeleton-sub {
  height: 12px;
  width: 50%;
  border-radius: var(--radius-sm);
}

.skeleton-text {
  height: 16px;
  width: 100%;
  border-radius: var(--radius-sm);
}

.skeleton-circle {
  width: 44px;
  height: 44px;
  border-radius: 50%;
}

@media (max-width: 600px) {
  .skeleton-cards-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
  }
}
</style>
