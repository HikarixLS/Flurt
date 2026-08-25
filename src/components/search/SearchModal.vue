<script setup lang="ts">
import { ref, watch, nextTick, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { Search, X, History, Sparkles, Film, ArrowRight, Loader2 } from 'lucide-vue-next';
import { movieApi } from '../../api/movieApi';
import type { MovieItem } from '../../types/movie';
import { GENRES } from '../../types/movie';
import MovieCard from '../common/MovieCard.vue';
import { useAnime } from '../../composables/useAnime';

const props = defineProps<{
  isOpen: boolean;
}>();

const emit = defineEmits<{
  (e: 'close'): void;
}>();

const router = useRouter();
const { animateModalIn, animateModalOut, animateCardGrid } = useAnime();

const backdropRef = ref<HTMLElement | null>(null);
const contentRef = ref<HTMLElement | null>(null);
const searchInputRef = ref<HTMLInputElement | null>(null);

const searchQuery = ref('');
const isSearching = ref(false);
const searchResults = ref<MovieItem[]>([]);
const hasSearched = ref(false);

const recentSearches = ref<string[]>([]);
let debounceTimeout: ReturnType<typeof setTimeout> | null = null;

const loadRecentSearches = () => {
  const saved = localStorage.getItem('flurt_recent_searches');
  if (saved) {
    try {
      recentSearches.value = JSON.parse(saved);
    } catch {
      recentSearches.value = [];
    }
  }
};

const saveRecentSearch = (term: string) => {
  const clean = term.trim();
  if (!clean) return;
  const filtered = recentSearches.value.filter(s => s.toLowerCase() !== clean.toLowerCase());
  filtered.unshift(clean);
  recentSearches.value = filtered.slice(0, 8);
  localStorage.setItem('flurt_recent_searches', JSON.stringify(recentSearches.value));
};

const clearRecentSearches = () => {
  recentSearches.value = [];
  localStorage.removeItem('flurt_recent_searches');
};

const handleInput = () => {
  if (debounceTimeout) clearTimeout(debounceTimeout);

  if (!searchQuery.value.trim()) {
    searchResults.value = [];
    hasSearched.value = false;
    isSearching.value = false;
    return;
  }

  isSearching.value = true;
  debounceTimeout = setTimeout(async () => {
    try {
      const res = await movieApi.search(searchQuery.value);
      searchResults.value = res.items || [];
      hasSearched.value = true;
      saveRecentSearch(searchQuery.value);

      await nextTick();
      const cards = contentRef.value?.querySelectorAll('.search-results-grid .movie-card');
      if (cards && cards.length > 0) {
        animateCardGrid(cards);
      }
    } catch (e) {
      console.error('Search error:', e);
      searchResults.value = [];
      hasSearched.value = true;
    } finally {
      isSearching.value = false;
    }
  }, 350);
};

const selectRecent = (term: string) => {
  searchQuery.value = term;
  handleInput();
};

const selectGenre = (genreSlug: string) => {
  close();
  router.push(`/the-loai/${genreSlug}`);
};

const close = () => {
  animateModalOut(backdropRef.value, contentRef.value, () => {
    emit('close');
  });
};

// Key shortcut: '/' opens search, 'Escape' closes
const handleGlobalKey = (e: KeyboardEvent) => {
  if (e.key === '/' && !props.isOpen) {
    // Only open if not typing inside an existing input
    if (document.activeElement?.tagName !== 'INPUT' && document.activeElement?.tagName !== 'TEXTAREA') {
      e.preventDefault();
      // Emitted by parent or handled via custom event
    }
  } else if (e.key === 'Escape' && props.isOpen) {
    close();
  }
};

watch(() => props.isOpen, async (open) => {
  if (open) {
    loadRecentSearches();
    await nextTick();
    animateModalIn(backdropRef.value, contentRef.value);
    searchInputRef.value?.focus();
  } else {
    searchQuery.value = '';
    searchResults.value = [];
    hasSearched.value = false;
  }
});

onMounted(() => {
  window.addEventListener('keydown', handleGlobalKey);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleGlobalKey);
});
</script>

<template>
  <div v-if="isOpen" class="search-modal-root">
    <!-- Backdrop Blur Overlay -->
    <div ref="backdropRef" class="modal-backdrop" @click="close"></div>

    <!-- Modal Content Box -->
    <div ref="contentRef" class="modal-content glass-panel-heavy">
      <!-- Search Bar -->
      <div class="search-bar-header">
        <div class="search-input-wrapper">
          <Search :size="22" class="search-icon" />
          <input
            ref="searchInputRef"
            v-model="searchQuery"
            type="text"
            placeholder="Tìm tên phim, diễn viên, anime, thể loại..."
            class="search-input"
            @input="handleInput"
            data-tv-focus
          />
          <Loader2 v-if="isSearching" :size="20" class="spinner-icon animate-spin" />
          <button 
            v-else-if="searchQuery" 
            class="clear-query-btn" 
            @click="searchQuery = ''; handleInput()"
            title="Xóa"
          >
            <X :size="18" />
          </button>
        </div>

        <button class="close-btn" @click="close" title="Đóng (Esc)" data-tv-focus tabindex="0">
          <X :size="20" />
        </button>
      </div>

      <!-- Modal Body -->
      <div class="modal-body-scroll no-scrollbar">
        <!-- Search Results -->
        <div v-if="searchResults.length > 0" class="results-section">
          <div class="section-title-bar">
            <h3>Kết quả tìm kiếm ({{ searchResults.length }})</h3>
          </div>
          <div class="search-results-grid">
            <div 
              v-for="movie in searchResults" 
              :key="movie.slug" 
              class="search-item"
              @click="close"
            >
              <MovieCard :movie="movie" />
            </div>
          </div>
        </div>

        <!-- No Results -->
        <div v-else-if="hasSearched && !isSearching" class="no-results">
          <Film :size="48" class="no-res-icon" />
          <h3>Không tìm thấy phim phù hợp</h3>
          <p>Thử tìm với từ khóa ngắn gọn hơn hoặc khám phá các thể loại bên dưới</p>
        </div>

        <!-- Default State: Recents & Quick Genres -->
        <div v-else class="default-search-view">
          <!-- Recent Searches -->
          <div v-if="recentSearches.length > 0" class="recents-section">
            <div class="section-title-bar">
              <div class="title-with-icon">
                <History :size="16" />
                <span>Tìm kiếm gần đây</span>
              </div>
              <button class="clear-history-link" @click="clearRecentSearches">Xóa lịch sử</button>
            </div>
            <div class="tags-cloud">
              <button
                v-for="term in recentSearches"
                :key="term"
                class="tag-chip"
                @click="selectRecent(term)"
                data-tv-focus
                tabindex="0"
              >
                {{ term }}
              </button>
            </div>
          </div>

          <!-- Quick Genres -->
          <div class="genres-section">
            <div class="section-title-bar">
              <div class="title-with-icon">
                <Sparkles :size="16" class="sparkle-icon" />
                <span>Khám phá theo thể loại</span>
              </div>
            </div>
            <div class="genre-pills-grid">
              <button
                v-for="genre in GENRES.slice(0, 14)"
                :key="genre.slug"
                class="genre-pill"
                @click="selectGenre(genre.slug)"
                data-tv-focus
                tabindex="0"
              >
                <span>{{ genre.name }}</span>
                <ArrowRight :size="14" class="pill-arrow" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.search-modal-root {
  position: fixed;
  inset: 0;
  z-index: 2000;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding: 60px 20px 20px;
}

.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(4, 5, 8, 0.85);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
}

.modal-content {
  position: relative;
  width: 100%;
  max-width: 860px;
  max-height: 80vh;
  border-radius: var(--radius-xl);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  box-shadow: 0 24px 60px rgba(0, 0, 0, 0.8), 0 0 35px rgba(229, 9, 20, 0.15);
  z-index: 10;
}

/* Header */
.search-bar-header {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 20px 24px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.search-input-wrapper {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12px;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: var(--radius-lg);
  padding: 10px 16px;
  transition: border-color var(--transition-fast);
}

.search-input-wrapper:focus-within {
  border-color: var(--primary);
  box-shadow: 0 0 15px var(--primary-glow);
}

.search-icon {
  color: var(--text-muted);
}

.search-input {
  flex: 1;
  background: transparent;
  border: none;
  color: #ffffff;
  font-size: 16px;
  outline: none;
}

.search-input::placeholder {
  color: var(--text-dim);
}

.clear-query-btn {
  background: transparent;
  border: none;
  color: var(--text-muted);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn {
  width: 42px;
  height: 42px;
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

.close-btn:hover {
  background: rgba(255, 255, 255, 0.15);
  color: #ffffff;
}

/* Body */
.modal-body-scroll {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
}

.section-title-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.section-title-bar h3 {
  font-size: 16px;
  color: #ffffff;
}

.title-with-icon {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 600;
  color: var(--text-muted);
}

.clear-history-link {
  background: transparent;
  border: none;
  color: var(--text-dim);
  font-size: 12px;
  cursor: pointer;
  text-decoration: underline;
}

.clear-history-link:hover {
  color: var(--primary);
}

/* Tags */
.tags-cloud {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 28px;
}

.tag-chip {
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #ffffff;
  font-size: 13px;
  padding: 6px 14px;
  border-radius: var(--radius-full);
  cursor: pointer;
  transition: all var(--transition-fast);
}

.tag-chip:hover {
  background: rgba(229, 9, 20, 0.25);
  border-color: var(--primary);
  color: #ffffff;
}

/* Genres Grid */
.genre-pills-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(170px, 1fr));
  gap: 10px;
}

.genre-pill {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid var(--border-glass);
  padding: 12px 16px;
  border-radius: var(--radius-md);
  color: var(--text-muted);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.genre-pill:hover {
  background: rgba(255, 255, 255, 0.1);
  color: #ffffff;
  border-color: rgba(255, 255, 255, 0.2);
  transform: translateX(4px);
}

.pill-arrow {
  opacity: 0.4;
  transition: opacity var(--transition-fast), transform var(--transition-fast);
}

.genre-pill:hover .pill-arrow {
  opacity: 1;
  transform: translateX(2px);
  color: var(--accent-cyan);
}

/* Results Grid */
.search-results-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 16px;
}

/* No results */
.no-results {
  text-align: center;
  padding: 50px 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}

.no-res-icon {
  color: var(--text-dim);
}

.no-results h3 {
  font-size: 18px;
  color: #ffffff;
}

.no-results p {
  color: var(--text-muted);
  font-size: 14px;
  max-width: 400px;
}

.animate-spin {
  animation: spin 1s linear infinite;
  color: var(--primary);
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

@media (max-width: 600px) {
  .search-modal-root {
    padding: 20px 10px;
  }
  .modal-content {
    max-height: 90vh;
  }
  .genre-pills-grid {
    grid-template-columns: 1fr 1fr;
  }
  .search-results-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
