<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue';
import { 
  Play, 
  SkipBack, 
  SkipForward, 
  Tv, 
  Layers, 
  Maximize, 
  Moon, 
  Sun,
  Search,
  CheckCircle2
} from 'lucide-vue-next';
import type { MovieDetail, EpisodeServer, EpisodeItem } from '../../types/movie';
import { useLibraryStore } from '../../stores/libraryStore';

const props = defineProps<{
  movie: MovieDetail;
  initialEpisodeSlug?: string;
}>();

const emit = defineEmits<{
  (e: 'change-episode', ep: EpisodeItem): void;
}>();

const libraryStore = useLibraryStore();

const currentServerIndex = ref(0);
const currentEpisodeSlug = ref('');
const isTheaterMode = ref(false);
const isCinemaLightsOff = ref(false);
const episodeSearchQuery = ref('');

const currentServer = computed<EpisodeServer | null>(() => {
  if (!props.movie.episodes || props.movie.episodes.length === 0) return null;
  return props.movie.episodes[currentServerIndex.value] || props.movie.episodes[0];
});

const currentEpisode = computed<EpisodeItem | null>(() => {
  if (!currentServer.value || currentServer.value.items.length === 0) return null;
  if (!currentEpisodeSlug.value) {
    return currentServer.value.items[0];
  }
  return currentServer.value.items.find(e => e.slug === currentEpisodeSlug.value) || currentServer.value.items[0];
});

const currentEpisodeIndex = computed(() => {
  if (!currentServer.value || !currentEpisode.value) return 0;
  return currentServer.value.items.findIndex(e => e.slug === currentEpisode.value?.slug);
});

const filteredEpisodes = computed(() => {
  if (!currentServer.value) return [];
  if (!episodeSearchQuery.value.trim()) return currentServer.value.items;
  return currentServer.value.items.filter(item => 
    item.name.toLowerCase().includes(episodeSearchQuery.value.toLowerCase()) ||
    item.slug.toLowerCase().includes(episodeSearchQuery.value.toLowerCase())
  );
});

const hasPrevEpisode = computed(() => currentEpisodeIndex.value > 0);
const hasNextEpisode = computed(() => {
  if (!currentServer.value) return false;
  return currentEpisodeIndex.value < currentServer.value.items.length - 1;
});

const selectEpisode = (ep: EpisodeItem) => {
  currentEpisodeSlug.value = ep.slug;
  emit('change-episode', ep);
  // Save to history
  libraryStore.addToHistory(props.movie, ep.slug, ep.name);
};

const selectServer = (idx: number) => {
  currentServerIndex.value = idx;
  if (currentServer.value && currentServer.value.items.length > 0) {
    // try to find matching episode name in new server
    const targetName = currentEpisode.value?.name;
    const match = currentServer.value.items.find(e => e.name === targetName);
    if (match) {
      selectEpisode(match);
    } else {
      selectEpisode(currentServer.value.items[0]);
    }
  }
};

const prevEpisode = () => {
  if (hasPrevEpisode.value && currentServer.value) {
    selectEpisode(currentServer.value.items[currentEpisodeIndex.value - 1]);
  }
};

const nextEpisode = () => {
  if (hasNextEpisode.value && currentServer.value) {
    selectEpisode(currentServer.value.items[currentEpisodeIndex.value + 1]);
  }
};

const toggleTheater = () => {
  isTheaterMode.value = !isTheaterMode.value;
};

const toggleCinemaLights = () => {
  isCinemaLightsOff.value = !isCinemaLightsOff.value;
};

watch(() => props.movie, (newMovie) => {
  if (newMovie && newMovie.episodes && newMovie.episodes.length > 0) {
    currentServerIndex.value = 0;
    const firstEp = newMovie.episodes[0]?.items[0];
    if (firstEp) {
      currentEpisodeSlug.value = props.initialEpisodeSlug || firstEp.slug;
      libraryStore.addToHistory(newMovie, currentEpisodeSlug.value, firstEp.name);
    }
  }
}, { immediate: true });

onMounted(() => {
  if (props.initialEpisodeSlug) {
    currentEpisodeSlug.value = props.initialEpisodeSlug;
  } else if (currentEpisode.value) {
    libraryStore.addToHistory(props.movie, currentEpisode.value.slug, currentEpisode.value.name);
  }
});
</script>

<template>
  <div 
    class="video-player-root" 
    :class="{ 
      'is-theater-mode': isTheaterMode, 
      'cinema-lights-off': isCinemaLightsOff 
    }"
  >
    <!-- Cinema Backdrop Dimmer Overlay -->
    <div v-if="isCinemaLightsOff" class="cinema-dimmer-overlay" @click="isCinemaLightsOff = false"></div>

    <!-- Main Player Frame Section -->
    <div class="player-container">
      <div class="player-screen-wrapper">
        <iframe
          v-if="currentEpisode?.embed"
          :key="currentEpisode.embed"
          :src="currentEpisode.embed"
          class="player-iframe"
          allow="autoplay; encrypted-media; fullscreen; picture-in-picture"
          allowfullscreen
          title="Video Player"
        ></iframe>

        <div v-else class="no-stream-box">
          <p>Chưa có nguồn phát cho tập phim này.</p>
        </div>
      </div>

      <!-- Quick Control Bar below video -->
      <div class="player-quick-bar">
        <!-- Episode Navigation -->
        <div class="quick-nav-left">
          <button 
            class="control-btn"
            :disabled="!hasPrevEpisode"
            @click="prevEpisode"
            title="Tập trước"
            data-tv-focus
            tabindex="0"
          >
            <SkipBack :size="16" />
            <span>Tập trước</span>
          </button>

          <div class="current-ep-pill">
            <span class="ep-prefix">Đang phát:</span>
            <span class="ep-badge-current">Tập {{ currentEpisode?.name }}</span>
          </div>

          <button 
            class="control-btn"
            :disabled="!hasNextEpisode"
            @click="nextEpisode"
            title="Tập kế tiếp"
            data-tv-focus
            tabindex="0"
          >
            <span>Tập tiếp</span>
            <SkipForward :size="16" />
          </button>
        </div>

        <!-- Cinema Mode Controls -->
        <div class="quick-nav-right">
          <button 
            class="control-icon-btn"
            :class="{ 'active': isCinemaLightsOff }"
            @click="toggleCinemaLights"
            :title="isCinemaLightsOff ? 'Bật đèn' : 'Tắt đèn rạp chiếu'"
            data-tv-focus
            tabindex="0"
          >
            <component :is="isCinemaLightsOff ? Sun : Moon" :size="16" />
          </button>

          <button 
            class="control-icon-btn"
            :class="{ 'active': isTheaterMode }"
            @click="toggleTheater"
            title="Chế độ rạp chiếu (Theater mode)"
            data-tv-focus
            tabindex="0"
          >
            <Maximize :size="16" />
          </button>
        </div>
      </div>
    </div>

    <!-- Episode & Server Selection Section -->
    <div class="episode-manager-box glass-panel">
      <!-- Server Selection Tabs -->
      <div class="server-tabs-bar" v-if="movie.episodes && movie.episodes.length > 1">
        <div class="server-tabs-label">
          <Layers :size="16" />
          <span>Chọn Server:</span>
        </div>
        <div class="server-tabs-list">
          <button
            v-for="(server, sIdx) in movie.episodes"
            :key="server.server_name"
            class="server-tab-btn"
            :class="{ 'is-active': sIdx === currentServerIndex }"
            @click="selectServer(sIdx)"
            data-tv-focus
            tabindex="0"
          >
            {{ server.server_name }}
          </button>
        </div>
      </div>

      <!-- Episode Header & Search Filter -->
      <div class="episodes-header-row">
        <div class="ep-count-title">
          <Tv :size="18" />
          <h3>Danh Sách Tập ({{ currentServer?.items?.length || 0 }} tập)</h3>
        </div>

        <!-- Episode Search for Long Series -->
        <div v-if="(currentServer?.items?.length || 0) > 15" class="ep-search-wrapper">
          <Search :size="14" class="ep-search-icon" />
          <input
            v-model="episodeSearchQuery"
            type="text"
            placeholder="Tìm số tập..."
            class="ep-search-input"
          />
        </div>
      </div>

      <!-- Episode Grid Buttons -->
      <div class="episodes-grid no-scrollbar">
        <button
          v-for="ep in filteredEpisodes"
          :key="ep.slug"
          class="ep-btn"
          :class="{ 'is-active': ep.slug === currentEpisode?.slug }"
          @click="selectEpisode(ep)"
          data-tv-focus
          tabindex="0"
        >
          <Play v-if="ep.slug === currentEpisode?.slug" :size="12" fill="currentColor" class="ep-play-icon" />
          <span>{{ ep.name }}</span>
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.video-player-root {
  position: relative;
  width: 100%;
  margin-bottom: 40px;
}

/* Cinema Dimmer */
.cinema-dimmer-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.92);
  z-index: 100;
  cursor: pointer;
}

/* Theater Mode Expansion */
.video-player-root.is-theater-mode .player-container {
  max-width: 100vw;
  margin-left: calc(-50vw + 50%);
  margin-right: calc(-50vw + 50%);
  border-radius: 0;
}

.video-player-root.cinema-lights-off .player-container {
  position: relative;
  z-index: 150;
}

.player-container {
  width: 100%;
  background: #000000;
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.8), 0 0 30px rgba(0, 210, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.08);
  margin-bottom: 20px;
  transition: all 0.35s cubic-bezier(0.16, 1, 0.3, 1);
}

.player-screen-wrapper {
  position: relative;
  width: 100%;
  aspect-ratio: 16 / 9;
  background: #000;
}

.player-iframe {
  width: 100%;
  height: 100%;
  border: none;
  display: block;
}

.no-stream-box {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: var(--text-muted);
  font-size: 15px;
}

/* Quick Control Bar */
.player-quick-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 20px;
  background: #0d0f16;
  border-top: 1px solid rgba(255, 255, 255, 0.06);
}

.quick-nav-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.control-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid var(--border-glass);
  color: #ffffff;
  padding: 6px 14px;
  border-radius: var(--radius-sm);
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.control-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.18);
  transform: scale(1.03);
}

.control-btn:disabled {
  opacity: 0.35;
  cursor: not-allowed;
}

.current-ep-pill {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
}

.ep-prefix {
  color: var(--text-muted);
}

.ep-badge-current {
  color: var(--accent-cyan);
  font-weight: 700;
}

.quick-nav-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.control-icon-btn {
  width: 34px;
  height: 34px;
  border-radius: var(--radius-sm);
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid var(--border-glass);
  color: var(--text-muted);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.control-icon-btn:hover, .control-icon-btn.active {
  background: rgba(255, 255, 255, 0.2);
  color: #ffffff;
  border-color: rgba(255, 255, 255, 0.3);
}

/* Episode Manager Box */
.episode-manager-box {
  padding: 24px;
  border-radius: var(--radius-lg);
}

/* Server Tabs */
.server-tabs-bar {
  display: flex;
  align-items: center;
  gap: 12px;
  padding-bottom: 18px;
  margin-bottom: 18px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}

.server-tabs-label {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: var(--text-muted);
  font-weight: 600;
}

.server-tabs-list {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.server-tab-btn {
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--border-glass);
  color: var(--text-muted);
  padding: 6px 14px;
  border-radius: var(--radius-sm);
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.server-tab-btn:hover {
  background: rgba(255, 255, 255, 0.12);
  color: #ffffff;
}

.server-tab-btn.is-active {
  background: var(--primary);
  color: #ffffff;
  border-color: var(--primary);
  box-shadow: 0 0 12px var(--primary-glow);
}

/* Episode Header */
.episodes-header-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.ep-count-title {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #ffffff;
}

.ep-count-title h3 {
  font-size: 16px;
}

.ep-search-wrapper {
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--border-glass);
  padding: 6px 12px;
  border-radius: var(--radius-sm);
}

.ep-search-icon {
  color: var(--text-muted);
}

.ep-search-input {
  background: transparent;
  border: none;
  color: #ffffff;
  font-size: 12px;
  outline: none;
  width: 100px;
}

/* Grid of Episodes */
.episodes-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(64px, 1fr));
  gap: 8px;
  max-height: 260px;
  overflow-y: auto;
  padding-right: 4px;
}

.ep-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  height: 42px;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--border-glass);
  color: var(--text-muted);
  border-radius: var(--radius-sm);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all var(--transition-fast);
  outline: none;
}

.ep-btn:hover {
  background: rgba(255, 255, 255, 0.15);
  color: #ffffff;
  border-color: rgba(255, 255, 255, 0.25);
  transform: translateY(-2px);
}

.ep-btn.is-active {
  background: linear-gradient(135deg, #ff0055 0%, #e50914 100%);
  color: #ffffff;
  border-color: transparent;
  box-shadow: 0 0 15px var(--primary-glow);
  transform: scale(1.05);
}

.ep-play-icon {
  animation: pulse 1.5s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

@media (max-width: 768px) {
  .player-quick-bar {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
  }
  .quick-nav-left {
    justify-content: space-between;
  }
  .quick-nav-right {
    justify-content: flex-end;
  }
  .episodes-grid {
    grid-template-columns: repeat(auto-fill, minmax(50px, 1fr));
  }
}
</style>
