<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { movieApi } from '../api/movieApi';
import type { MovieItem } from '../types/movie';
import { GENRES } from '../types/movie';
import { useLibraryStore } from '../stores/libraryStore';
import HeroBanner from '../components/home/HeroBanner.vue';
import MovieRow from '../components/common/MovieRow.vue';
import MovieCard from '../components/common/MovieCard.vue';
import { Sparkles, History, Compass, ArrowRight } from 'lucide-vue-next';

const libraryStore = useLibraryStore();

const heroMovies = ref<MovieItem[]>([]);
const newUpdatedMovies = ref<MovieItem[]>([]);
const seriesMovies = ref<MovieItem[]>([]);
const singleMovies = ref<MovieItem[]>([]);
const tvShowsMovies = ref<MovieItem[]>([]);
const nowShowingMovies = ref<MovieItem[]>([]);
const animeMovies = ref<MovieItem[]>([]);

const loadingHero = ref(true);
const loadingNew = ref(true);
const loadingSeries = ref(true);
const loadingSingle = ref(true);
const loadingTv = ref(true);
const loadingNow = ref(true);
const loadingAnime = ref(true);

const loadData = async () => {
  // Load New Updated & Hero
  try {
    const resNew = await movieApi.getNewUpdated(1);
    newUpdatedMovies.value = resNew.items || [];
    heroMovies.value = newUpdatedMovies.value.slice(0, 6);
  } catch (e) {
    console.error('Error fetching new updated movies:', e);
  } finally {
    loadingHero.value = false;
    loadingNew.value = false;
  }

  // Load Phim Bo (Series)
  try {
    const resSeries = await movieApi.getByCategory('phim-bo', 1);
    seriesMovies.value = resSeries.items || [];
  } catch (e) {
    console.error('Error fetching series:', e);
  } finally {
    loadingSeries.value = false;
  }

  // Load Phim Le (Single)
  try {
    const resSingle = await movieApi.getByCategory('phim-le', 1);
    singleMovies.value = resSingle.items || [];
  } catch (e) {
    console.error('Error fetching single movies:', e);
  } finally {
    loadingSingle.value = false;
  }

  // Load TV Shows
  try {
    const resTv = await movieApi.getByCategory('tv-shows', 1);
    tvShowsMovies.value = resTv.items || [];
  } catch (e) {
    console.error('Error fetching tv shows:', e);
  } finally {
    loadingTv.value = false;
  }

  // Load Dang Chieu (Now Showing)
  try {
    const resNow = await movieApi.getByCategory('dang-chieu', 1);
    nowShowingMovies.value = resNow.items || [];
  } catch (e) {
    console.error('Error fetching now showing:', e);
  } finally {
    loadingNow.value = false;
  }

  // Load Hoat Hinh / Anime
  try {
    const resAnime = await movieApi.getByGenre('hoat-hinh', 1);
    animeMovies.value = resAnime.items || [];
  } catch (e) {
    console.error('Error fetching anime:', e);
  } finally {
    loadingAnime.value = false;
  }
};

onMounted(() => {
  loadData();
});
</script>

<template>
  <div class="home-view">
    <!-- Hero Featured Spotlight Banner -->
    <HeroBanner :movies="heroMovies" :loading="loadingHero" />

    <div class="container-custom home-content">
      <!-- Continue Watching Bar (if history exists) -->
      <section v-if="libraryStore.history.length > 0" class="continue-watching-section">
        <div class="section-title-bar">
          <div class="title-with-icon">
            <History :size="20" class="history-icon" />
            <h2 class="section-title">Tiếp Tục Xem</h2>
          </div>
          <router-link to="/thu-vien" class="view-all-link" data-tv-focus tabindex="0">
            <span>Xem lịch sử</span>
            <ArrowRight :size="14" />
          </router-link>
        </div>

        <div class="continue-grid no-scrollbar">
          <div 
            v-for="item in libraryStore.history.slice(0, 6)" 
            :key="item.movie.slug" 
            class="continue-card-wrapper"
          >
            <MovieCard :movie="item.movie" />
            <div class="continue-ep-tag">
              <span>Đang xem: Tập {{ item.lastEpisodeName }}</span>
            </div>
          </div>
        </div>
      </section>

      <!-- Phim Mới Cập Nhật -->
      <MovieRow 
        title="Phim Mới Cập Nhật" 
        :movies="newUpdatedMovies" 
        :loading="loadingNew" 
        view-all-link="/danh-sach/phim-moi-cap-nhat"
      />

      <!-- Phim Bộ Nổi Bật -->
      <MovieRow 
        title="Phim Bộ Đặc Sắc" 
        :movies="seriesMovies" 
        :loading="loadingSeries" 
        view-all-link="/danh-sach/phim-bo"
      />

      <!-- Phim Lẻ Chọn Lọc -->
      <MovieRow 
        title="Phim Lẻ Bom Tấn" 
        :movies="singleMovies" 
        :loading="loadingSingle" 
        view-all-link="/danh-sach/phim-le"
      />

      <!-- Hoạt Hình & Anime -->
      <MovieRow 
        title="Hoạt Hình & Anime" 
        :movies="animeMovies" 
        :loading="loadingAnime" 
        view-all-link="/the-loai/hoat-hinh"
      />

      <!-- TV Shows & Chương Trình Truyền Hình -->
      <MovieRow 
        title="TV Shows & Gameshow" 
        :movies="tvShowsMovies" 
        :loading="loadingTv" 
        view-all-link="/danh-sach/tv-shows"
      />

      <!-- Phim Đang Chiếu Rạp -->
      <MovieRow 
        title="Phim Đang Chiếu Rạp" 
        :movies="nowShowingMovies" 
        :loading="loadingNow" 
        view-all-link="/danh-sach/dang-chieu"
      />

      <!-- Quick Genre Grid Banner -->
      <section class="explore-genres-banner glass-panel">
        <div class="banner-header">
          <div class="title-with-icon">
            <Compass :size="24" class="compass-icon" />
            <h2>Khám Phá Theo Thể Loại</h2>
          </div>
          <router-link to="/kham-pha" class="btn-secondary" data-tv-focus tabindex="0">
            Xem Tất Cả Thể Loại
          </router-link>
        </div>

        <div class="genre-cards-grid">
          <router-link
            v-for="genre in GENRES.slice(0, 8)"
            :key="genre.slug"
            :to="`/the-loai/${genre.slug}`"
            class="genre-box-card"
            data-tv-focus
            tabindex="0"
          >
            <span class="genre-name">{{ genre.name }}</span>
            <span class="genre-explore-label">Khám phá &rarr;</span>
          </router-link>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped>
.home-view {
  min-height: 100vh;
  padding-bottom: 40px;
}

.home-content {
  position: relative;
  z-index: 10;
}

/* Continue Watching */
.continue-watching-section {
  margin-bottom: 48px;
  background: rgba(229, 9, 20, 0.04);
  border: 1px solid rgba(229, 9, 20, 0.15);
  border-radius: var(--radius-xl);
  padding: 24px;
}

.section-title-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18px;
}

.title-with-icon {
  display: flex;
  align-items: center;
  gap: 10px;
}

.history-icon {
  color: var(--primary);
}

.section-title {
  font-size: 22px;
  font-weight: 700;
  color: #ffffff;
}

.view-all-link {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: var(--accent-cyan);
  font-size: 13px;
  font-weight: 600;
}

.continue-grid {
  display: flex;
  gap: 16px;
  overflow-x: auto;
  padding-bottom: 8px;
}

.continue-card-wrapper {
  flex: 0 0 170px;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.continue-ep-tag {
  background: rgba(0, 210, 255, 0.15);
  border: 1px solid rgba(0, 210, 255, 0.3);
  color: var(--accent-cyan);
  font-size: 11px;
  font-weight: 600;
  padding: 4px 8px;
  border-radius: var(--radius-sm);
  text-align: center;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Explore Genres Banner */
.explore-genres-banner {
  padding: 36px;
  border-radius: var(--radius-xl);
  margin-top: 60px;
  background: linear-gradient(135deg, rgba(16, 20, 30, 0.85) 0%, rgba(10, 12, 18, 0.95) 100%);
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.banner-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
}

.compass-icon {
  color: var(--accent-cyan);
}

.genre-cards-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}

.genre-box-card {
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid var(--border-glass);
  padding: 20px 24px;
  border-radius: var(--radius-lg);
  display: flex;
  flex-direction: column;
  gap: 8px;
  transition: all var(--transition-fast);
}

.genre-box-card:hover {
  background: linear-gradient(135deg, rgba(229, 9, 20, 0.2) 0%, rgba(0, 210, 255, 0.1) 100%);
  border-color: rgba(255, 255, 255, 0.25);
  transform: translateY(-4px);
}

.genre-name {
  font-size: 17px;
  font-weight: 700;
  color: #ffffff;
}

.genre-explore-label {
  font-size: 12px;
  color: var(--accent-cyan);
}

@media (max-width: 900px) {
  .genre-cards-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 600px) {
  .genre-cards-grid {
    grid-template-columns: 1fr;
  }
  .explore-genres-banner {
    padding: 20px;
  }
  .banner-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 14px;
  }
}
</style>
