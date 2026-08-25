<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue';
import { ChevronLeft, ChevronRight, ArrowRight } from 'lucide-vue-next';
import type { MovieItem } from '../../types/movie';
import MovieCard from './MovieCard.vue';
import Skeleton from './Skeleton.vue';
import { useAnime } from '../../composables/useAnime';

const props = defineProps<{
  title: string;
  movies: MovieItem[];
  loading?: boolean;
  viewAllLink?: string;
  iconName?: string;
}>();

const rowContainer = ref<HTMLElement | null>(null);
const { animateCardGrid } = useAnime();

const scroll = (direction: 'left' | 'right') => {
  if (!rowContainer.value) return;
  const scrollAmount = rowContainer.value.clientWidth * 0.75;
  rowContainer.value.scrollBy({
    left: direction === 'left' ? -scrollAmount : scrollAmount,
    behavior: 'smooth'
  });
};

onMounted(async () => {
  await nextTick();
  if (rowContainer.value) {
    const cards = rowContainer.value.querySelectorAll('.movie-card');
    if (cards.length > 0) {
      animateCardGrid(cards);
    }
  }
});
</script>

<template>
  <section class="movie-row-section">
    <!-- Header -->
    <div class="row-header">
      <div class="header-left">
        <div class="title-bar-accent"></div>
        <h2 class="row-title">{{ title }}</h2>
      </div>

      <div class="header-right">
        <!-- View All Link -->
        <router-link 
          v-if="viewAllLink" 
          :to="viewAllLink" 
          class="view-all-link"
          data-tv-focus
          tabindex="0"
        >
          <span>Xem tất cả</span>
          <ArrowRight :size="14" />
        </router-link>

        <!-- Carousel Navigation Arrows -->
        <div class="row-nav-btns">
          <button 
            class="row-nav-btn" 
            @click="scroll('left')" 
            title="Trước"
            data-tv-focus
            tabindex="0"
          >
            <ChevronLeft :size="18" />
          </button>
          <button 
            class="row-nav-btn" 
            @click="scroll('right')" 
            title="Tiếp"
            data-tv-focus
            tabindex="0"
          >
            <ChevronRight :size="18" />
          </button>
        </div>
      </div>
    </div>

    <!-- Loading Skeleton -->
    <div v-if="loading" class="skeleton-row-wrapper">
      <Skeleton type="card" :count="6" />
    </div>

    <!-- Movies Carousel -->
    <div v-else ref="rowContainer" class="movies-carousel no-scrollbar">
      <div 
        v-for="movie in movies" 
        :key="movie.slug" 
        class="carousel-item"
      >
        <MovieCard :movie="movie" />
      </div>
    </div>
  </section>
</template>

<style scoped>
.movie-row-section {
  margin-bottom: 48px;
  position: relative;
}

.row-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.title-bar-accent {
  width: 4px;
  height: 22px;
  border-radius: 2px;
  background: linear-gradient(180deg, #ff0055 0%, #e50914 100%);
  box-shadow: 0 0 10px var(--primary-glow);
}

.row-title {
  font-size: 22px;
  font-weight: 700;
  color: #ffffff;
  letter-spacing: -0.01em;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.view-all-link {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: var(--accent-cyan);
  font-size: 13px;
  font-weight: 600;
  transition: transform var(--transition-fast), color var(--transition-fast);
}

.view-all-link:hover {
  color: #ffffff;
  transform: translateX(3px);
}

.row-nav-btns {
  display: flex;
  gap: 6px;
}

.row-nav-btn {
  width: 32px;
  height: 32px;
  border-radius: var(--radius-full);
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--border-glass);
  color: var(--text-muted);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.row-nav-btn:hover {
  background: rgba(255, 255, 255, 0.15);
  color: #ffffff;
  transform: scale(1.08);
}

.movies-carousel {
  display: flex;
  gap: 16px;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  padding: 8px 2px 14px;
}

.carousel-item {
  flex: 0 0 calc((100% - 80px) / 6);
  min-width: 170px;
  scroll-snap-align: start;
}

.skeleton-row-wrapper {
  padding: 8px 0;
}

@media (max-width: 1200px) {
  .carousel-item {
    flex: 0 0 calc((100% - 48px) / 4);
    min-width: 160px;
  }
}

@media (max-width: 768px) {
  .carousel-item {
    flex: 0 0 calc((100% - 24px) / 3);
    min-width: 140px;
  }
  .row-title {
    font-size: 18px;
  }
  .row-nav-btns {
    display: none;
  }
}

@media (max-width: 480px) {
  .carousel-item {
    flex: 0 0 calc((100% - 12px) / 2.2);
    min-width: 125px;
  }
}
</style>
