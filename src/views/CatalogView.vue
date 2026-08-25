<script setup lang="ts">
import { ref, watch, computed, nextTick } from 'vue';
import { useRoute } from 'vue-router';
import { movieApi } from '../api/movieApi';
import type { MovieItem, Paginate } from '../types/movie';
import MovieCard from '../components/common/MovieCard.vue';
import Skeleton from '../components/common/Skeleton.vue';
import { ChevronLeft, ChevronRight, Film, Tv, Radio, Flame, Sparkles } from 'lucide-vue-next';
import { useAnime } from '../composables/useAnime';

const props = defineProps<{
  slug: string;
}>();

const route = useRoute();
const { animateCardGrid } = useAnime();

const movies = ref<MovieItem[]>([]);
const pagination = ref<Paginate | null>(null);
const currentPage = ref(Number(route.query.page) || 1);
const loading = ref(true);
const gridContainer = ref<HTMLElement | null>(null);

const catalogTitles: Record<string, { title: string; desc: string; icon: any }> = {
  'phim-moi-cap-nhat': {
    title: 'Phim Mới Cập Nhật',
    desc: 'Danh sách các bộ phim và tập mới nhất vừa được cập nhật trên hệ thống.',
    icon: Sparkles
  },
  'phim-bo': {
    title: 'Phim Bộ Đặc Sắc',
    desc: 'Tổng hợp các bộ phim truyền hình nhiều tập hấp dẫn từ Hàn Quốc, Trung Quốc, Âu Mỹ, Thái Lan.',
    icon: Tv
  },
  'phim-le': {
    title: 'Phim Lẻ Chiếu Rạp',
    desc: 'Tuyển tập các tác phẩm điện ảnh bom tấn, phim chiếu rạp và phim lẻ đỉnh cao thế giới.',
    icon: Film
  },
  'tv-shows': {
    title: 'TV Shows & Gameshow',
    desc: 'Chương trình truyền hình thực tế, gameshow giải trí và talkshow đặc sắc.',
    icon: Radio
  },
  'dang-chieu': {
    title: 'Phim Đang Chiếu Rạp',
    desc: 'Những bộ phim đang làm mưa làm gió tại các cụm rạp trong nước và quốc tế.',
    icon: Flame
  }
};

const currentCatalog = computed(() => {
  return catalogTitles[props.slug] || {
    title: props.slug.replace(/-/g, ' ').toUpperCase(),
    desc: 'Danh sách phim chất lượng cao được tuyển chọn.',
    icon: Film
  };
});

const loadMovies = async () => {
  loading.value = true;
  movies.value = [];
  try {
    let res;
    if (props.slug === 'phim-moi-cap-nhat') {
      res = await movieApi.getNewUpdated(currentPage.value);
    } else {
      res = await movieApi.getByCategory(props.slug, currentPage.value);
    }
    movies.value = res.items || [];
    pagination.value = res.paginate;

    await nextTick();
    if (gridContainer.value) {
      const cards = gridContainer.value.querySelectorAll('.movie-card');
      if (cards.length > 0) {
        animateCardGrid(cards);
      }
    }
  } catch (e) {
    console.error('Error loading catalog movies:', e);
  } finally {
    loading.value = false;
  }
};

const changePage = (page: number) => {
  if (page < 1 || (pagination.value && page > pagination.value.total_page)) return;
  currentPage.value = page;
  window.scrollTo({ top: 0, behavior: 'smooth' });
  loadMovies();
};

watch([() => props.slug, () => route.query.page], () => {
  currentPage.value = Number(route.query.page) || 1;
  loadMovies();
}, { immediate: true });
</script>

<template>
  <div class="catalog-view">
    <div class="container-custom">
      <!-- Header Banner -->
      <div class="catalog-header glass-panel">
        <div class="header-icon-box">
          <component :is="currentCatalog.icon" :size="32" class="header-icon" />
        </div>
        <div class="header-text">
          <h1 class="catalog-title">{{ currentCatalog.title }}</h1>
          <p class="catalog-desc">{{ currentCatalog.desc }}</p>
        </div>
      </div>

      <!-- Loading Skeleton -->
      <div v-if="loading" class="skeleton-wrapper">
        <Skeleton type="card" :count="12" />
      </div>

      <!-- Movies Grid -->
      <div v-else-if="movies.length > 0">
        <div ref="gridContainer" class="catalog-grid">
          <div v-for="movie in movies" :key="movie.slug" class="grid-item">
            <MovieCard :movie="movie" />
          </div>
        </div>

        <!-- Pagination Controls -->
        <div v-if="pagination && pagination.total_page > 1" class="pagination-bar">
          <button
            class="page-nav-btn"
            :disabled="currentPage <= 1"
            @click="changePage(currentPage - 1)"
            data-tv-focus
            tabindex="0"
          >
            <ChevronLeft :size="18" />
            <span>Trang trước</span>
          </button>

          <div class="page-indicators">
            <span class="page-info">
              Trang <strong>{{ currentPage }}</strong> / {{ pagination.total_page }}
            </span>
          </div>

          <button
            class="page-nav-btn"
            :disabled="currentPage >= pagination.total_page"
            @click="changePage(currentPage + 1)"
            data-tv-focus
            tabindex="0"
          >
            <span>Trang tiếp</span>
            <ChevronRight :size="18" />
          </button>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="empty-state glass-panel">
        <Film :size="48" class="empty-icon" />
        <h3>Chưa có phim trong danh mục này</h3>
        <p>Vui lòng quay lại sau hoặc khám phá các danh mục khác</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.catalog-view {
  min-height: 100vh;
  padding-top: 100px;
  padding-bottom: 60px;
}

/* Header */
.catalog-header {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 32px;
  border-radius: var(--radius-xl);
  margin-bottom: 36px;
  background: linear-gradient(135deg, rgba(229, 9, 20, 0.12) 0%, rgba(13, 15, 22, 0.95) 100%);
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.header-icon-box {
  width: 64px;
  height: 64px;
  border-radius: var(--radius-lg);
  background: linear-gradient(135deg, #ff0055 0%, #e50914 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #ffffff;
  box-shadow: 0 0 25px var(--primary-glow);
  flex-shrink: 0;
}

.catalog-title {
  font-size: 32px;
  font-weight: 800;
  margin-bottom: 6px;
  color: #ffffff;
}

.catalog-desc {
  font-size: 15px;
  color: var(--text-muted);
}

/* Grid */
.catalog-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 24px;
  margin-bottom: 48px;
}

.skeleton-wrapper {
  margin-bottom: 48px;
}

/* Pagination */
.pagination-bar {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 18px;
  padding: 20px;
}

.page-nav-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid var(--border-glass);
  color: #ffffff;
  padding: 10px 20px;
  border-radius: var(--radius-md);
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.page-nav-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
  border-color: rgba(255, 255, 255, 0.3);
}

.page-nav-btn:disabled {
  opacity: 0.3;
  cursor: not-allowed;
}

.page-info {
  font-size: 15px;
  color: var(--text-muted);
}

.page-info strong {
  color: var(--accent-cyan);
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 60px 20px;
  border-radius: var(--radius-xl);
}

.empty-icon {
  color: var(--text-dim);
  margin-bottom: 16px;
}

.empty-state h3 {
  font-size: 20px;
  margin-bottom: 8px;
}

.empty-state p {
  color: var(--text-muted);
}

@media (max-width: 768px) {
  .catalog-header {
    flex-direction: column;
    align-items: flex-start;
    padding: 20px;
  }
  .catalog-title {
    font-size: 24px;
  }
  .catalog-grid {
    grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
    gap: 14px;
  }
}
</style>
