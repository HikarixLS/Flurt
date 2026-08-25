<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch, nextTick } from 'vue';
import { useRouter } from 'vue-router';
import { Play, Info, Bookmark, Sparkles, ChevronLeft, ChevronRight } from 'lucide-vue-next';
import type { MovieItem } from '../../types/movie';
import { useLibraryStore } from '../../stores/libraryStore';
import { useAnime } from '../../composables/useAnime';

const props = defineProps<{
  movies: MovieItem[];
  loading?: boolean;
}>();

const router = useRouter();
const libraryStore = useLibraryStore();
const { animateHeroSlide, animatePulse } = useAnime();

const currentIndex = ref(0);
const heroRef = ref<HTMLElement | null>(null);
let timer: ReturnType<typeof setInterval> | null = null;

const currentMovie = ref<MovieItem | null>(null);

const updateCurrentMovie = async () => {
  if (props.movies && props.movies.length > 0) {
    currentMovie.value = props.movies[currentIndex.value] || props.movies[0];
    await nextTick();
    if (heroRef.value) {
      animateHeroSlide(heroRef.value);
    }
  }
};

const goToSlide = (index: number) => {
  currentIndex.value = index;
  updateCurrentMovie();
  resetTimer();
};

const nextSlide = () => {
  if (props.movies.length === 0) return;
  currentIndex.value = (currentIndex.value + 1) % props.movies.length;
  updateCurrentMovie();
  resetTimer();
};

const prevSlide = () => {
  if (props.movies.length === 0) return;
  currentIndex.value = (currentIndex.value - 1 + props.movies.length) % props.movies.length;
  updateCurrentMovie();
  resetTimer();
};

const resetTimer = () => {
  if (timer) clearInterval(timer);
  timer = setInterval(() => {
    nextSlide();
  }, 7000);
};

const watchNow = (movie: MovieItem) => {
  router.push(`/phim/${movie.slug}`);
};

const toggleFav = (movie: MovieItem, e: Event) => {
  animatePulse(e.currentTarget as HTMLElement);
  libraryStore.toggleFavorite(movie);
};

watch(() => props.movies, (newMovies) => {
  if (newMovies && newMovies.length > 0) {
    updateCurrentMovie();
    resetTimer();
  }
}, { immediate: true });

onMounted(() => {
  resetTimer();
});

onUnmounted(() => {
  if (timer) clearInterval(timer);
});
</script>

<template>
  <div ref="heroRef" class="hero-banner-container">
    <div v-if="loading || !currentMovie" class="hero-skeleton skeleton-shimmer"></div>

    <div v-else class="hero-content-wrapper">
      <!-- Backdrop Image Background with Parallax Gradient -->
      <div class="hero-backdrop">
        <img 
          :src="currentMovie.poster_url || currentMovie.thumb_url" 
          :alt="currentMovie.name"
          class="hero-backdrop-img" 
        />
        <div class="hero-overlay-layer"></div>
      </div>

      <!-- Hero Text Info -->
      <div class="container-custom hero-inner">
        <div class="hero-info">
          <!-- Spotlight Badge -->
          <div class="hero-badge">
            <Sparkles :size="14" class="sparkle-icon" />
            <span>NỔI BẬT HÔM NAY • #{{ currentIndex + 1 }}</span>
          </div>

          <!-- Movie Title -->
          <h1 class="hero-title">{{ currentMovie.name }}</h1>

          <!-- Meta Info -->
          <div class="hero-meta">
            <span v-if="currentMovie.quality" class="badge-quality">{{ currentMovie.quality }}</span>
            <span v-if="currentMovie.current_episode" class="badge-episode">{{ currentMovie.current_episode }}</span>
            <span v-if="currentMovie.year" class="badge-year">{{ currentMovie.year }}</span>
            <span v-if="currentMovie.original_name" class="hero-orig-title">{{ currentMovie.original_name }}</span>
          </div>

          <!-- Description -->
          <p class="hero-desc">
            {{ currentMovie.description || 'Khám phá ngay bộ phim bom tấn với chất lượng hình ảnh sắc nét và âm thanh sống động trên Flurt.' }}
          </p>

          <!-- Action Buttons -->
          <div class="hero-actions">
            <button 
              class="btn-primary hero-btn-watch" 
              @click="watchNow(currentMovie)"
              data-tv-focus
              tabindex="0"
            >
              <Play :size="20" fill="#ffffff" />
              <span>Xem Phim Ngay</span>
            </button>

            <button 
              class="btn-secondary hero-btn-fav"
              :class="{ 'is-fav': libraryStore.isFavorite(currentMovie.slug) }"
              @click="toggleFav(currentMovie, $event)"
              data-tv-focus
              tabindex="0"
            >
              <Bookmark :size="18" :fill="libraryStore.isFavorite(currentMovie.slug) ? '#e50914' : 'none'" />
              <span>{{ libraryStore.isFavorite(currentMovie.slug) ? 'Đã Lưu' : 'Lưu Danh Sách' }}</span>
            </button>

            <button 
              class="btn-secondary hero-btn-info" 
              @click="watchNow(currentMovie)"
              data-tv-focus
              tabindex="0"
            >
              <Info :size="18" />
              <span>Chi Tiết</span>
            </button>
          </div>
        </div>
      </div>

      <!-- Slide Navigation Controls -->
      <div class="hero-controls">
        <button 
          class="hero-arrow-btn prev-btn" 
          @click="prevSlide" 
          title="Phim trước"
          data-tv-focus
          tabindex="0"
        >
          <ChevronLeft :size="22" />
        </button>

        <!-- Dots -->
        <div class="hero-dots">
          <button
            v-for="(item, idx) in movies.slice(0, 5)"
            :key="item.slug"
            class="hero-dot"
            :class="{ 'is-active': idx === currentIndex }"
            @click="goToSlide(idx)"
            data-tv-focus
            tabindex="0"
            :title="item.name"
          ></button>
        </div>

        <button 
          class="hero-arrow-btn next-btn" 
          @click="nextSlide" 
          title="Phim tiếp"
          data-tv-focus
          tabindex="0"
        >
          <ChevronRight :size="22" />
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.hero-banner-container {
  position: relative;
  width: 100%;
  height: 80vh;
  min-height: 540px;
  max-height: 720px;
  margin-bottom: 30px;
  overflow: hidden;
  background: var(--bg-main);
}

.hero-skeleton {
  width: 100%;
  height: 100%;
}

.hero-content-wrapper {
  position: relative;
  width: 100%;
  height: 100%;
}

/* Backdrop */
.hero-backdrop {
  position: absolute;
  inset: 0;
  overflow: hidden;
}

.hero-backdrop-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center 20%;
  transform-origin: center;
}

.hero-overlay-layer {
  position: absolute;
  inset: 0;
  background: 
    linear-gradient(180deg, rgba(7, 8, 12, 0.2) 0%, rgba(7, 8, 12, 0.65) 60%, #07080c 100%),
    linear-gradient(90deg, rgba(7, 8, 12, 0.95) 0%, rgba(7, 8, 12, 0.75) 45%, rgba(7, 8, 12, 0.2) 100%);
}

/* Inner Text Info */
.hero-inner {
  position: relative;
  height: 100%;
  display: flex;
  align-items: center;
  z-index: 5;
}

.hero-info {
  max-width: 680px;
  padding-top: 50px;
}

.hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: rgba(229, 9, 20, 0.2);
  border: 1px solid rgba(229, 9, 20, 0.4);
  color: #ff4d58;
  font-size: 12px;
  font-weight: 700;
  padding: 6px 14px;
  border-radius: var(--radius-full);
  margin-bottom: 16px;
  letter-spacing: 0.5px;
}

.sparkle-icon {
  color: #ff4d58;
}

.hero-title {
  font-size: 46px;
  font-weight: 900;
  line-height: 1.15;
  color: #ffffff;
  margin-bottom: 14px;
  text-shadow: 0 4px 20px rgba(0, 0, 0, 0.8);
}

.hero-meta {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 16px;
}

.hero-orig-title {
  color: var(--text-muted);
  font-size: 14px;
  font-weight: 500;
}

.hero-desc {
  font-size: 15px;
  color: #d1d5db;
  line-height: 1.6;
  margin-bottom: 26px;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.7);
}

/* Actions */
.hero-actions {
  display: flex;
  align-items: center;
  gap: 14px;
  flex-wrap: wrap;
}

.hero-btn-watch {
  font-size: 15px;
  padding: 14px 30px;
}

.hero-btn-fav.is-fav {
  border-color: var(--primary);
  color: #ffffff;
  background: rgba(229, 9, 20, 0.2);
}

/* Slide Controls */
.hero-controls {
  position: absolute;
  bottom: 30px;
  right: 40px;
  display: flex;
  align-items: center;
  gap: 12px;
  z-index: 10;
}

.hero-arrow-btn {
  width: 40px;
  height: 40px;
  border-radius: var(--radius-full);
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(8px);
  border: 1px solid var(--border-glass);
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.hero-arrow-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: scale(1.08);
}

.hero-dots {
  display: flex;
  gap: 8px;
  align-items: center;
}

.hero-dot {
  width: 10px;
  height: 10px;
  border-radius: var(--radius-full);
  background: rgba(255, 255, 255, 0.3);
  border: none;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.hero-dot.is-active {
  width: 28px;
  background: var(--primary);
  box-shadow: 0 0 10px var(--primary-glow);
}

@media (max-width: 900px) {
  .hero-banner-container {
    height: 70vh;
    min-height: 480px;
  }
  .hero-title {
    font-size: 32px;
  }
  .hero-desc {
    font-size: 14px;
    -webkit-line-clamp: 2;
  }
  .hero-controls {
    bottom: 20px;
    right: 20px;
  }
}

@media (max-width: 600px) {
  .hero-banner-container {
    height: 65vh;
  }
  .hero-title {
    font-size: 26px;
  }
  .hero-actions {
    gap: 10px;
  }
  .hero-btn-watch {
    padding: 10px 20px;
    font-size: 14px;
  }
  .hero-btn-info span, .hero-btn-fav span {
    display: none;
  }
  .hero-btn-info, .hero-btn-fav {
    padding: 10px;
    border-radius: var(--radius-full);
  }
}
</style>
