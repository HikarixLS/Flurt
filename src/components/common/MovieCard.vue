<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { Play, Bookmark, Star } from 'lucide-vue-next';
import type { MovieItem } from '../../types/movie';
import { useLibraryStore } from '../../stores/libraryStore';
import { useAnime } from '../../composables/useAnime';

const props = defineProps<{
  movie: MovieItem;
}>();

const router = useRouter();
const libraryStore = useLibraryStore();
const { animatePulse } = useAnime();

const imageLoaded = ref(false);
const imageError = ref(false);

const handleImageLoad = () => {
  imageLoaded.value = true;
};

const handleImageError = () => {
  imageError.value = true;
  imageLoaded.value = true;
};

const goToDetail = () => {
  router.push(`/phim/${props.movie.slug}`);
};

const toggleFav = (e: Event) => {
  e.stopPropagation();
  animatePulse(e.currentTarget as HTMLElement);
  libraryStore.toggleFavorite(props.movie);
};
</script>

<template>
  <div 
    class="movie-card" 
    @click="goToDetail"
    data-tv-focus
    tabindex="0"
    :title="movie.name"
  >
    <!-- Poster Thumbnail -->
    <div class="poster-wrapper">
      <img
        v-if="!imageError"
        :src="movie.thumb_url || movie.poster_url"
        :alt="movie.name"
        class="poster-img"
        :class="{ 'is-loaded': imageLoaded }"
        loading="lazy"
        @load="handleImageLoad"
        @error="handleImageError"
      />
      <div v-else class="poster-fallback">
        <span class="fallback-title">{{ movie.name }}</span>
      </div>

      <!-- Shimmer Placeholder while loading -->
      <div v-if="!imageLoaded" class="poster-skeleton skeleton-shimmer"></div>

      <!-- Badges Overlay -->
      <div class="badges-top">
        <span v-if="movie.quality" class="badge-quality">{{ movie.quality }}</span>
        <span v-if="movie.language" class="badge-lang">{{ movie.language }}</span>
      </div>

      <div class="badge-bottom-left" v-if="movie.current_episode">
        <span class="badge-episode">{{ movie.current_episode }}</span>
      </div>

      <!-- Hover / Focus Overlay -->
      <div class="card-overlay">
        <button class="play-btn-circle" title="Xem ngay">
          <Play :size="24" fill="#ffffff" />
        </button>

        <button 
          class="fav-toggle-btn"
          :class="{ 'is-fav': libraryStore.isFavorite(movie.slug) }"
          @click="toggleFav"
          :title="libraryStore.isFavorite(movie.slug) ? 'Bỏ yêu thích' : 'Thêm vào yêu thích'"
        >
          <Bookmark :size="18" :fill="libraryStore.isFavorite(movie.slug) ? '#e50914' : 'none'" />
        </button>
      </div>
    </div>

    <!-- Movie Details -->
    <div class="movie-info">
      <h3 class="movie-title">{{ movie.name }}</h3>
      <div class="movie-meta">
        <span v-if="movie.year" class="movie-year">{{ movie.year }}</span>
        <span v-if="movie.original_name" class="movie-orig">{{ movie.original_name }}</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.movie-card {
  display: flex;
  flex-direction: column;
  cursor: pointer;
  border-radius: var(--radius-md);
  transition: transform 0.28s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.28s ease;
  user-select: none;
  outline: none;
  position: relative;
}

.movie-card:hover {
  transform: translateY(-6px) scale(1.02);
  z-index: 10;
}

.movie-card:hover .poster-wrapper {
  box-shadow: 0 14px 35px rgba(0, 0, 0, 0.7), 0 0 20px rgba(229, 9, 20, 0.3);
  border-color: rgba(255, 255, 255, 0.25);
}

.movie-card:hover .card-overlay {
  opacity: 1;
}

.movie-card:hover .poster-img {
  transform: scale(1.06);
}

.poster-wrapper {
  position: relative;
  width: 100%;
  aspect-ratio: 2 / 3;
  border-radius: var(--radius-md);
  overflow: hidden;
  background: var(--bg-card);
  border: 1px solid var(--border-glass);
  transition: all 0.28s ease;
}

.poster-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  opacity: 0;
  transition: opacity 0.4s ease, transform 0.45s cubic-bezier(0.16, 1, 0.3, 1);
}

.poster-img.is-loaded {
  opacity: 1;
}

.poster-skeleton {
  position: absolute;
  inset: 0;
}

.poster-fallback {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px;
  text-align: center;
  height: 100%;
  background: linear-gradient(135deg, #181b26 0%, #0d0f15 100%);
}

.fallback-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-muted);
}

/* Badges */
.badges-top {
  position: absolute;
  top: 8px;
  left: 8px;
  display: flex;
  gap: 4px;
  z-index: 2;
}

.badge-lang {
  background: rgba(0, 0, 0, 0.75);
  backdrop-filter: blur(4px);
  color: #ffffff;
  font-size: 10px;
  font-weight: 600;
  padding: 2px 6px;
  border-radius: var(--radius-sm);
  border: 1px solid rgba(255, 255, 255, 0.15);
}

.badge-bottom-left {
  position: absolute;
  bottom: 8px;
  left: 8px;
  z-index: 2;
}

/* Card Overlay */
.card-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.55);
  backdrop-filter: blur(3px);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.25s ease;
  z-index: 3;
}

.play-btn-circle {
  width: 52px;
  height: 52px;
  border-radius: 50%;
  background: var(--primary);
  border: none;
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 20px rgba(229, 9, 20, 0.7);
  cursor: pointer;
  transition: transform 0.2s ease, background-color 0.2s ease;
}

.play-btn-circle:hover {
  transform: scale(1.12);
  background: var(--primary-hover);
}

.fav-toggle-btn {
  position: absolute;
  top: 10px;
  right: 10px;
  width: 34px;
  height: 34px;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.65);
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s ease;
}

.fav-toggle-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: scale(1.1);
}

.fav-toggle-btn.is-fav {
  color: var(--primary);
  border-color: var(--primary);
  background: rgba(229, 9, 20, 0.2);
}

/* Info */
.movie-info {
  padding: 10px 4px 4px;
}

.movie-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-main);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  margin-bottom: 3px;
  line-height: 1.3;
}

.movie-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: var(--text-muted);
}

.movie-year {
  color: var(--accent-cyan);
  font-weight: 500;
}

.movie-orig {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  color: var(--text-dim);
}
</style>
