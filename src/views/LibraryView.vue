<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useLibraryStore } from '../stores/libraryStore';
import MovieCard from '../components/common/MovieCard.vue';
import { Bookmark, History, Trash2, Play, Compass, Film } from 'lucide-vue-next';

const router = useRouter();
const libraryStore = useLibraryStore();

const activeTab = ref<'favorites' | 'history'>('favorites');

const formatTimeAgo = (timestamp: number) => {
  const diff = Date.now() - timestamp;
  const minutes = Math.floor(diff / (1000 * 60));
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);

  if (minutes < 1) return 'Vừa xong';
  if (minutes < 60) return `${minutes} phút trước`;
  if (hours < 24) return `${hours} giờ trước`;
  return `${days} ngày trước`;
};

const playHistoryMovie = (slug: string) => {
  router.push(`/phim/${slug}`);
};
</script>

<template>
  <div class="library-view">
    <div class="container-custom">
      <!-- Library Header -->
      <div class="library-header glass-panel">
        <div class="header-text">
          <h1 class="library-title">Thư Viện Của Tôi</h1>
          <p class="library-desc">Quản lý danh sách phim đã lưu yêu thích và lịch sử các phim bạn đã xem trên Flurt.</p>
        </div>

        <!-- Tab Selector -->
        <div class="library-tabs">
          <button
            class="lib-tab-btn"
            :class="{ 'is-active': activeTab === 'favorites' }"
            @click="activeTab = 'favorites'"
            data-tv-focus
            tabindex="0"
          >
            <Bookmark :size="16" />
            <span>Phim Yêu Thích ({{ libraryStore.favorites.length }})</span>
          </button>

          <button
            class="lib-tab-btn"
            :class="{ 'is-active': activeTab === 'history' }"
            @click="activeTab = 'history'"
            data-tv-focus
            tabindex="0"
          >
            <History :size="16" />
            <span>Lịch Sử Xem ({{ libraryStore.history.length }})</span>
          </button>
        </div>
      </div>

      <!-- Favorites Tab Content -->
      <div v-if="activeTab === 'favorites'">
        <div v-if="libraryStore.favorites.length > 0" class="cards-grid">
          <div v-for="movie in libraryStore.favorites" :key="movie.slug" class="grid-item">
            <MovieCard :movie="movie" />
          </div>
        </div>

        <div v-else class="empty-state glass-panel">
          <Bookmark :size="52" class="empty-icon" />
          <h3>Chưa có phim nào trong danh sách yêu thích</h3>
          <p>Bấm vào biểu tượng bookmark trên poster phim để lưu lại xem sau.</p>
          <router-link to="/" class="btn-primary" data-tv-focus tabindex="0">
            <Compass :size="18" />
            <span>Khám phá phim ngay</span>
          </router-link>
        </div>
      </div>

      <!-- History Tab Content -->
      <div v-else-if="activeTab === 'history'">
        <div v-if="libraryStore.history.length > 0">
          <div class="history-actions-bar">
            <span class="history-count">Đã xem gần đây ({{ libraryStore.history.length }} phim)</span>
            <button 
              class="clear-all-btn" 
              @click="libraryStore.clearHistory"
              data-tv-focus
              tabindex="0"
            >
              <Trash2 :size="14" />
              <span>Xóa toàn bộ lịch sử</span>
            </button>
          </div>

          <div class="history-list">
            <div 
              v-for="item in libraryStore.history" 
              :key="item.movie.slug" 
              class="history-item-row glass-panel"
            >
              <!-- Poster Thumbnail -->
              <div class="history-thumb" @click="playHistoryMovie(item.movie.slug)">
                <img :src="item.movie.thumb_url || item.movie.poster_url" :alt="item.movie.name" />
                <div class="thumb-play-overlay">
                  <Play :size="20" fill="#ffffff" />
                </div>
              </div>

              <!-- Movie & Episode Info -->
              <div class="history-info" @click="playHistoryMovie(item.movie.slug)">
                <h3 class="history-movie-name">{{ item.movie.name }}</h3>
                <p class="history-ep-status">
                  Tập đang xem: <strong>Tập {{ item.lastEpisodeName }}</strong>
                </p>
                <span class="history-time">{{ formatTimeAgo(item.watchedAt) }}</span>
              </div>

              <!-- Actions -->
              <div class="history-item-actions">
                <button 
                  class="btn-primary btn-sm" 
                  @click="playHistoryMovie(item.movie.slug)"
                  data-tv-focus
                  tabindex="0"
                >
                  <Play :size="14" fill="#ffffff" />
                  <span>Xem tiếp</span>
                </button>

                <button 
                  class="remove-hist-btn" 
                  @click="libraryStore.removeFromHistory(item.movie.slug)" 
                  title="Xóa khỏi lịch sử"
                  data-tv-focus
                  tabindex="0"
                >
                  <Trash2 :size="16" />
                </button>
              </div>
            </div>
          </div>
        </div>

        <div v-else class="empty-state glass-panel">
          <History :size="52" class="empty-icon" />
          <h3>Chưa có lịch sử xem phim</h3>
          <p>Các bộ phim bạn đã xem sẽ tự động được lưu lại ở đây để tiện xem tiếp.</p>
          <router-link to="/" class="btn-primary" data-tv-focus tabindex="0">
            <Compass :size="18" />
            <span>Khám phá phim ngay</span>
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.library-view {
  min-height: 100vh;
  padding-top: 100px;
  padding-bottom: 60px;
}

.library-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 32px;
  border-radius: var(--radius-xl);
  margin-bottom: 36px;
  background: linear-gradient(135deg, rgba(229, 9, 20, 0.08) 0%, rgba(13, 15, 22, 0.95) 100%);
}

.library-title {
  font-size: 32px;
  font-weight: 800;
  margin-bottom: 6px;
  color: #ffffff;
}

.library-desc {
  font-size: 14px;
  color: var(--text-muted);
}

.library-tabs {
  display: flex;
  gap: 10px;
  background: rgba(255, 255, 255, 0.05);
  padding: 4px;
  border-radius: var(--radius-full);
  border: 1px solid var(--border-glass);
}

.lib-tab-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  background: transparent;
  border: none;
  color: var(--text-muted);
  padding: 10px 20px;
  border-radius: var(--radius-full);
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.lib-tab-btn:hover {
  color: #ffffff;
}

.lib-tab-btn.is-active {
  background: #ffffff;
  color: #000000;
  box-shadow: 0 2px 10px rgba(255, 255, 255, 0.3);
}

/* Favorites Grid */
.cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 24px;
}

/* History List */
.history-actions-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18px;
}

.history-count {
  font-size: 14px;
  color: var(--text-muted);
}

.clear-all-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--border-glass);
  color: #ff6b6b;
  padding: 6px 14px;
  border-radius: var(--radius-sm);
  font-size: 13px;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.clear-all-btn:hover {
  background: rgba(255, 107, 107, 0.15);
  border-color: #ff6b6b;
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.history-item-row {
  display: flex;
  align-items: center;
  padding: 14px 20px;
  border-radius: var(--radius-lg);
  gap: 20px;
  transition: transform var(--transition-fast), border-color var(--transition-fast);
}

.history-item-row:hover {
  transform: translateX(4px);
  border-color: rgba(255, 255, 255, 0.2);
}

.history-thumb {
  position: relative;
  width: 90px;
  height: 60px;
  border-radius: var(--radius-sm);
  overflow: hidden;
  cursor: pointer;
  flex-shrink: 0;
}

.history-thumb img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.thumb-play-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity var(--transition-fast);
}

.history-thumb:hover .thumb-play-overlay {
  opacity: 1;
}

.history-info {
  flex: 1;
  cursor: pointer;
}

.history-movie-name {
  font-size: 16px;
  font-weight: 700;
  color: #ffffff;
  margin-bottom: 4px;
}

.history-ep-status {
  font-size: 13px;
  color: var(--accent-cyan);
  margin-bottom: 2px;
}

.history-time {
  font-size: 11px;
  color: var(--text-dim);
}

.history-item-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.btn-sm {
  padding: 8px 16px;
  font-size: 13px;
}

.remove-hist-btn {
  width: 36px;
  height: 36px;
  border-radius: var(--radius-sm);
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--border-glass);
  color: var(--text-muted);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.remove-hist-btn:hover {
  background: rgba(255, 107, 107, 0.2);
  color: #ff6b6b;
  border-color: #ff6b6b;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 80px 20px;
  border-radius: var(--radius-xl);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
}

.empty-icon {
  color: var(--text-dim);
}

.empty-state h3 {
  font-size: 20px;
  color: #ffffff;
}

.empty-state p {
  color: var(--text-muted);
  max-width: 450px;
  font-size: 14px;
  margin-bottom: 8px;
}

@media (max-width: 900px) {
  .library-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 20px;
    padding: 20px;
  }
  .library-title {
    font-size: 24px;
  }
  .history-item-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  .history-item-actions {
    width: 100%;
    justify-content: space-between;
  }
}
</style>
