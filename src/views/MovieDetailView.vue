<script setup lang="ts">
import { ref, watch, computed, nextTick } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { movieApi } from '../api/movieApi';
import type { MovieDetail, MovieItem } from '../types/movie';
import VideoPlayer from '../components/player/VideoPlayer.vue';
import MovieRow from '../components/common/MovieRow.vue';
import Skeleton from '../components/common/Skeleton.vue';
import { 
  Bookmark, 
  Share2, 
  Clock, 
  Calendar, 
  Globe, 
  Film, 
  User, 
  Users, 
  Sparkles,
  Check
} from 'lucide-vue-next';
import { useLibraryStore } from '../stores/libraryStore';
import { useAnime } from '../composables/useAnime';

const props = defineProps<{
  slug: string;
}>();

const route = useRoute();
const router = useRouter();
const libraryStore = useLibraryStore();
const { animatePulse } = useAnime();

const movie = ref<MovieDetail | null>(null);
const relatedMovies = ref<MovieItem[]>([]);
const loading = ref(true);
const loadingRelated = ref(true);
const isCopied = ref(false);

const currentEpisodeSlug = ref<string>('');

const categoriesList = computed(() => {
  if (!movie.value?.category) return [];
  const list: { groupName: string; items: { id: string; name: string }[] }[] = [];
  for (const key in movie.value.category) {
    const group = movie.value.category[key];
    if (group && group.group) {
      list.push({
        groupName: group.group.name,
        items: group.list || []
      });
    }
  }
  return list;
});

const loadMovieDetail = async () => {
  loading.value = true;
  movie.value = null;
  relatedMovies.value = [];
  
  try {
    const res = await movieApi.getDetail(props.slug);
    movie.value = res.movie;
    document.title = `${res.movie.name} - Xem Phim Online HD | Flurt`;

    // Load related movies by first genre or new updated
    loadRelated();
  } catch (e) {
    console.error('Error fetching movie detail:', e);
  } finally {
    loading.value = false;
  }
};

const loadRelated = async () => {
  loadingRelated.value = true;
  try {
    const res = await movieApi.getByCategory('phim-bo', 1);
    relatedMovies.value = res.items.filter(m => m.slug !== props.slug).slice(0, 10);
  } catch (e) {
    console.error('Error fetching related:', e);
  } finally {
    loadingRelated.value = false;
  }
};

const toggleFav = (e: Event) => {
  if (!movie.value) return;
  animatePulse(e.currentTarget as HTMLElement);
  libraryStore.toggleFavorite(movie.value);
};

const copyShareLink = () => {
  navigator.clipboard.writeText(window.location.href);
  isCopied.value = true;
  setTimeout(() => {
    isCopied.value = false;
  }, 2000);
};

watch(() => props.slug, () => {
  loadMovieDetail();
  window.scrollTo({ top: 0, behavior: 'smooth' });
}, { immediate: true });
</script>

<template>
  <div class="movie-detail-view">
    <!-- Loading State -->
    <div v-if="loading" class="container-custom skeleton-detail-page">
      <Skeleton type="banner" />
      <Skeleton type="card" :count="6" />
    </div>

    <!-- Movie Content -->
    <div v-else-if="movie" class="detail-content-wrapper">
      <!-- Backdrop Atmospheric Image -->
      <div class="detail-backdrop">
        <img 
          :src="movie.poster_url || movie.thumb_url" 
          :alt="movie.name" 
          class="detail-backdrop-img"
        />
        <div class="detail-backdrop-overlay"></div>
      </div>

      <div class="container-custom detail-inner">
        <!-- Video Player Component -->
        <VideoPlayer 
          :movie="movie" 
          :initial-episode-slug="currentEpisodeSlug"
          @change-episode="ep => currentEpisodeSlug = ep.slug"
        />

        <!-- Movie Information Card -->
        <div class="movie-meta-card glass-panel">
          <div class="meta-card-top">
            <!-- Left Poster Preview -->
            <div class="meta-poster-box">
              <img :src="movie.thumb_url || movie.poster_url" :alt="movie.name" class="meta-poster-img" />
              <button 
                class="meta-fav-btn"
                :class="{ 'is-fav': libraryStore.isFavorite(movie.slug) }"
                @click="toggleFav"
                data-tv-focus
                tabindex="0"
              >
                <Bookmark :size="18" :fill="libraryStore.isFavorite(movie.slug) ? '#e50914' : 'none'" />
                <span>{{ libraryStore.isFavorite(movie.slug) ? 'Đã Lưu Yêu Thích' : 'Thêm Vào Yêu Thích' }}</span>
              </button>

              <button 
                class="meta-share-btn"
                @click="copyShareLink"
                data-tv-focus
                tabindex="0"
              >
                <component :is="isCopied ? Check : Share2" :size="16" />
                <span>{{ isCopied ? 'Đã Copy Link!' : 'Chia Sẻ Phim' }}</span>
              </button>
            </div>

            <!-- Right Main Info -->
            <div class="meta-main-info">
              <!-- Title & Original Title -->
              <h1 class="movie-main-title">{{ movie.name }}</h1>
              <h2 v-if="movie.original_name" class="movie-orig-title">{{ movie.original_name }}</h2>

              <!-- Key Badges -->
              <div class="badges-row">
                <span v-if="movie.quality" class="badge-quality">{{ movie.quality }}</span>
                <span v-if="movie.language" class="badge-lang">{{ movie.language }}</span>
                <span v-if="movie.current_episode" class="badge-episode">{{ movie.current_episode }}</span>
                <span v-if="movie.year" class="badge-year">Năm {{ movie.year }}</span>
              </div>

              <!-- Metadata Grid -->
              <div class="info-grid">
                <div v-if="movie.time" class="info-item">
                  <Clock :size="16" class="info-icon" />
                  <span class="info-label">Thời lượng:</span>
                  <span class="info-value">{{ movie.time }}</span>
                </div>

                <div v-if="movie.total_episodes" class="info-item">
                  <Film :size="16" class="info-icon" />
                  <span class="info-label">Tổng số tập:</span>
                  <span class="info-value">{{ movie.total_episodes }} tập</span>
                </div>

                <div v-if="movie.director" class="info-item">
                  <User :size="16" class="info-icon" />
                  <span class="info-label">Đạo diễn:</span>
                  <span class="info-value">{{ movie.director }}</span>
                </div>

                <div v-if="movie.casts" class="info-item">
                  <Users :size="16" class="info-icon" />
                  <span class="info-label">Diễn viên:</span>
                  <span class="info-value">{{ movie.casts }}</span>
                </div>
              </div>

              <!-- Category / Genre Tags -->
              <div class="tags-sections-list" v-if="categoriesList.length > 0">
                <div v-for="catGroup in categoriesList" :key="catGroup.groupName" class="cat-group-row">
                  <span class="cat-group-name">{{ catGroup.groupName }}:</span>
                  <div class="cat-tags-list">
                    <span 
                      v-for="item in catGroup.items" 
                      :key="item.id" 
                      class="cat-tag-pill"
                    >
                      {{ item.name }}
                    </span>
                  </div>
                </div>
              </div>

              <!-- Synopsis / Description -->
              <div class="synopsis-box">
                <h3 class="synopsis-title">Nội Dung Phim</h3>
                <p class="synopsis-text">
                  {{ movie.description || 'Nội dung chi tiết của bộ phim đang được cập nhật...' }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Related Recommended Movies -->
        <div class="related-section">
          <MovieRow 
            title="Phim Liên Quan Đề Xuất" 
            :movies="relatedMovies" 
            :loading="loadingRelated" 
          />
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.movie-detail-view {
  min-height: 100vh;
  padding-top: 85px;
  padding-bottom: 60px;
  position: relative;
}

.skeleton-detail-page {
  padding-top: 20px;
}

/* Atmospheric Backdrop */
.detail-backdrop {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 500px;
  overflow: hidden;
  z-index: 1;
}

.detail-backdrop-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  filter: blur(40px) brightness(0.25);
  transform: scale(1.1);
}

.detail-backdrop-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(7, 8, 12, 0.4) 0%, #07080c 100%);
}

.detail-inner {
  position: relative;
  z-index: 10;
}

/* Meta Card */
.movie-meta-card {
  padding: 32px;
  border-radius: var(--radius-xl);
  margin-bottom: 48px;
}

.meta-card-top {
  display: flex;
  gap: 36px;
}

/* Left Poster */
.meta-poster-box {
  width: 240px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.meta-poster-img {
  width: 100%;
  aspect-ratio: 2 / 3;
  object-fit: cover;
  border-radius: var(--radius-md);
  border: 1px solid var(--border-glass);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.7);
}

.meta-fav-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid var(--border-glass);
  color: #ffffff;
  padding: 10px;
  border-radius: var(--radius-md);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.meta-fav-btn:hover {
  background: rgba(255, 255, 255, 0.18);
  transform: translateY(-2px);
}

.meta-fav-btn.is-fav {
  border-color: var(--primary);
  background: rgba(229, 9, 20, 0.2);
}

.meta-share-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid var(--border-glass);
  color: var(--text-muted);
  padding: 9px;
  border-radius: var(--radius-md);
  font-size: 13px;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.meta-share-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  color: #ffffff;
}

/* Right Main Info */
.meta-main-info {
  flex: 1;
}

.movie-main-title {
  font-size: 36px;
  font-weight: 900;
  line-height: 1.2;
  color: #ffffff;
  margin-bottom: 6px;
}

.movie-orig-title {
  font-size: 18px;
  font-weight: 500;
  color: var(--text-muted);
  margin-bottom: 18px;
}

.badges-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 22px;
}

.badge-lang {
  background: rgba(255, 255, 255, 0.12);
  color: #ffffff;
  font-size: 11px;
  font-weight: 600;
  padding: 3px 8px;
  border-radius: var(--radius-sm);
}

/* Info Grid */
.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px 24px;
  margin-bottom: 24px;
  padding-bottom: 20px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}

.info-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
}

.info-icon {
  color: var(--accent-cyan);
  flex-shrink: 0;
}

.info-label {
  color: var(--text-muted);
}

.info-value {
  color: #ffffff;
  font-weight: 500;
}

/* Category Tags */
.tags-sections-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 24px;
}

.cat-group-row {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}

.cat-group-name {
  font-size: 13px;
  color: var(--text-dim);
  min-width: 70px;
}

.cat-tags-list {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.cat-tag-pill {
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--border-glass);
  color: var(--text-muted);
  font-size: 12px;
  padding: 3px 10px;
  border-radius: var(--radius-full);
}

/* Synopsis */
.synopsis-box {
  background: rgba(0, 0, 0, 0.25);
  padding: 20px;
  border-radius: var(--radius-lg);
  border: 1px solid rgba(255, 255, 255, 0.04);
}

.synopsis-title {
  font-size: 16px;
  font-weight: 700;
  color: #ffffff;
  margin-bottom: 8px;
}

.synopsis-text {
  font-size: 14px;
  color: #d1d5db;
  line-height: 1.7;
}

.related-section {
  margin-top: 20px;
}

@media (max-width: 900px) {
  .meta-card-top {
    flex-direction: column;
    align-items: center;
  }
  .meta-poster-box {
    width: 200px;
  }
  .info-grid {
    grid-template-columns: 1fr;
  }
  .movie-main-title {
    font-size: 26px;
  }
}
</style>
