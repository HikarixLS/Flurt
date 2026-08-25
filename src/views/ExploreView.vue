<script setup lang="ts">
import { ref, watch, nextTick } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { movieApi } from '../api/movieApi';
import type { MovieItem, Paginate } from '../types/movie';
import { GENRES, COUNTRIES, CATEGORIES, YEARS } from '../types/movie';
import MovieCard from '../components/common/MovieCard.vue';
import Skeleton from '../components/common/Skeleton.vue';
import { Compass, Filter, ChevronLeft, ChevronRight } from 'lucide-vue-next';
import { useAnime } from '../composables/useAnime';

const props = defineProps<{
  type?: 'genre' | 'country' | 'year';
  slug?: string;
}>();

const route = useRoute();
const router = useRouter();
const { animateCardGrid, animatePulse } = useAnime();

const filterType = ref<'genre' | 'country' | 'year' | 'category'>('genre');
const activeSlug = ref<string>('');
const currentPage = ref(1);

const movies = ref<MovieItem[]>([]);
const pagination = ref<Paginate | null>(null);
const loading = ref(true);
const gridContainer = ref<HTMLElement | null>(null);

const initFromPropsOrRoute = () => {
  if (props.type === 'genre' || route.path.startsWith('/the-loai')) {
    filterType.value = 'genre';
    activeSlug.value = props.slug || (route.params.slug as string) || GENRES[0].slug;
  } else if (props.type === 'country' || route.path.startsWith('/quoc-gia')) {
    filterType.value = 'country';
    activeSlug.value = props.slug || (route.params.slug as string) || COUNTRIES[0].slug;
  } else if (props.type === 'year' || route.path.startsWith('/nam')) {
    filterType.value = 'year';
    activeSlug.value = props.slug || (route.params.year as string) || String(YEARS[0]);
  } else {
    filterType.value = 'genre';
    activeSlug.value = GENRES[0].slug;
  }
};

const loadFilteredMovies = async () => {
  loading.value = true;
  movies.value = [];
  try {
    let res;
    if (filterType.value === 'genre') {
      res = await movieApi.getByGenre(activeSlug.value, currentPage.value);
    } else if (filterType.value === 'country') {
      res = await movieApi.getByCountry(activeSlug.value, currentPage.value);
    } else if (filterType.value === 'year') {
      res = await movieApi.getByYear(activeSlug.value, currentPage.value);
    } else if (filterType.value === 'category') {
      res = await movieApi.getByCategory(activeSlug.value, currentPage.value);
    }
    
    if (res) {
      movies.value = res.items || [];
      pagination.value = res.paginate;
    }

    await nextTick();
    if (gridContainer.value) {
      const cards = gridContainer.value.querySelectorAll('.movie-card');
      if (cards.length > 0) {
        animateCardGrid(cards);
      }
    }
  } catch (e) {
    console.error('Error fetching explore movies:', e);
  } finally {
    loading.value = false;
  }
};

const switchTab = (type: 'genre' | 'country' | 'year' | 'category') => {
  filterType.value = type;
  currentPage.value = 1;
  if (type === 'genre') activeSlug.value = GENRES[0].slug;
  else if (type === 'country') activeSlug.value = COUNTRIES[0].slug;
  else if (type === 'year') activeSlug.value = String(YEARS[0]);
  else if (type === 'category') activeSlug.value = CATEGORIES[0].slug;
  loadFilteredMovies();
};

const selectPill = (slug: string, e: Event) => {
  animatePulse(e.currentTarget as HTMLElement);
  activeSlug.value = slug;
  currentPage.value = 1;
  loadFilteredMovies();
};

const changePage = (page: number) => {
  if (page < 1 || (pagination.value && page > pagination.value.total_page)) return;
  currentPage.value = page;
  window.scrollTo({ top: 300, behavior: 'smooth' });
  loadFilteredMovies();
};

watch(() => [props.type, props.slug, route.path], () => {
  initFromPropsOrRoute();
  loadFilteredMovies();
}, { immediate: true });
</script>

<template>
  <div class="explore-view">
    <div class="container-custom">
      <!-- Explore Header -->
      <div class="explore-header glass-panel">
        <div class="header-icon-box">
          <Compass :size="32" />
        </div>
        <div class="header-text">
          <h1 class="explore-title">Khám Phá Phim</h1>
          <p class="explore-desc">Bộ lọc đa chiều theo thể loại, quốc gia sản xuất và năm phát hành.</p>
        </div>
      </div>

      <!-- Filter Controls Box -->
      <div class="filter-controls-box glass-panel">
        <!-- Main Filter Type Tabs -->
        <div class="filter-type-tabs">
          <button
            class="filter-tab-btn"
            :class="{ 'is-active': filterType === 'genre' }"
            @click="switchTab('genre')"
            data-tv-focus
            tabindex="0"
          >
            Thể Loại ({{ GENRES.length }})
          </button>
          <button
            class="filter-tab-btn"
            :class="{ 'is-active': filterType === 'country' }"
            @click="switchTab('country')"
            data-tv-focus
            tabindex="0"
          >
            Quốc Gia ({{ COUNTRIES.length }})
          </button>
          <button
            class="filter-tab-btn"
            :class="{ 'is-active': filterType === 'year' }"
            @click="switchTab('year')"
            data-tv-focus
            tabindex="0"
          >
            Năm Phát Hành
          </button>
          <button
            class="filter-tab-btn"
            :class="{ 'is-active': filterType === 'category' }"
            @click="switchTab('category')"
            data-tv-focus
            tabindex="0"
          >
            Định Dạng
          </button>
        </div>

        <!-- Filter Sub-Pills Bar -->
        <div class="filter-pills-scroll no-scrollbar">
          <!-- Genre Pills -->
          <template v-if="filterType === 'genre'">
            <button
              v-for="g in GENRES"
              :key="g.slug"
              class="sub-pill-btn"
              :class="{ 'is-selected': activeSlug === g.slug }"
              @click="selectPill(g.slug, $event)"
              data-tv-focus
              tabindex="0"
            >
              {{ g.name }}
            </button>
          </template>

          <!-- Country Pills -->
          <template v-else-if="filterType === 'country'">
            <button
              v-for="c in COUNTRIES"
              :key="c.slug"
              class="sub-pill-btn"
              :class="{ 'is-selected': activeSlug === c.slug }"
              @click="selectPill(c.slug, $event)"
              data-tv-focus
              tabindex="0"
            >
              {{ c.name }}
            </button>
          </template>

          <!-- Year Pills -->
          <template v-else-if="filterType === 'year'">
            <button
              v-for="y in YEARS"
              :key="y"
              class="sub-pill-btn"
              :class="{ 'is-selected': activeSlug === String(y) }"
              @click="selectPill(String(y), $event)"
              data-tv-focus
              tabindex="0"
            >
              Năm {{ y }}
            </button>
          </template>

          <!-- Category Pills -->
          <template v-else-if="filterType === 'category'">
            <button
              v-for="cat in CATEGORIES"
              :key="cat.slug"
              class="sub-pill-btn"
              :class="{ 'is-selected': activeSlug === cat.slug }"
              @click="selectPill(cat.slug, $event)"
              data-tv-focus
              tabindex="0"
            >
              {{ cat.name }}
            </button>
          </template>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="skeleton-wrapper">
        <Skeleton type="card" :count="12" />
      </div>

      <!-- Results Grid -->
      <div v-else-if="movies.length > 0">
        <div ref="gridContainer" class="explore-grid">
          <div v-for="movie in movies" :key="movie.slug" class="grid-item">
            <MovieCard :movie="movie" />
          </div>
        </div>

        <!-- Pagination -->
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
        <h3>Không có phim phù hợp với tiêu chí lọc này</h3>
        <p>Vui lòng thử chọn thể loại hoặc quốc gia khác</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.explore-view {
  min-height: 100vh;
  padding-top: 100px;
  padding-bottom: 60px;
}

/* Header */
.explore-header {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 28px 32px;
  border-radius: var(--radius-xl);
  margin-bottom: 24px;
  background: linear-gradient(135deg, rgba(0, 210, 255, 0.12) 0%, rgba(13, 15, 22, 0.95) 100%);
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.header-icon-box {
  width: 60px;
  height: 60px;
  border-radius: var(--radius-lg);
  background: linear-gradient(135deg, #00d2ff 0%, #0072ff 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #000;
  box-shadow: 0 0 25px var(--accent-cyan-glow);
  flex-shrink: 0;
}

.explore-title {
  font-size: 30px;
  font-weight: 800;
  margin-bottom: 4px;
  color: #ffffff;
}

.explore-desc {
  font-size: 14px;
  color: var(--text-muted);
}

/* Filter Controls Box */
.filter-controls-box {
  padding: 20px 24px;
  border-radius: var(--radius-xl);
  margin-bottom: 36px;
}

.filter-type-tabs {
  display: flex;
  gap: 10px;
  margin-bottom: 16px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
  padding-bottom: 14px;
  flex-wrap: wrap;
}

.filter-tab-btn {
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid var(--border-glass);
  color: var(--text-muted);
  padding: 8px 18px;
  border-radius: var(--radius-full);
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.filter-tab-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  color: #ffffff;
}

.filter-tab-btn.is-active {
  background: #ffffff;
  color: #000000;
  border-color: #ffffff;
  box-shadow: 0 0 15px rgba(255, 255, 255, 0.4);
}

.filter-pills-scroll {
  display: flex;
  gap: 8px;
  overflow-x: auto;
  padding: 4px 0 8px;
  flex-wrap: wrap;
}

.sub-pill-btn {
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--border-glass);
  color: var(--text-muted);
  padding: 6px 14px;
  border-radius: var(--radius-sm);
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all var(--transition-fast);
  white-space: nowrap;
}

.sub-pill-btn:hover {
  background: rgba(255, 255, 255, 0.15);
  color: #ffffff;
}

.sub-pill-btn.is-selected {
  background: var(--primary);
  color: #ffffff;
  border-color: var(--primary);
  box-shadow: 0 0 12px var(--primary-glow);
}

/* Grid */
.explore-grid {
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

.empty-state {
  text-align: center;
  padding: 60px 20px;
  border-radius: var(--radius-xl);
}

@media (max-width: 768px) {
  .explore-header {
    flex-direction: column;
    align-items: flex-start;
    padding: 20px;
  }
  .explore-title {
    font-size: 24px;
  }
  .explore-grid {
    grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
    gap: 14px;
  }
}
</style>
