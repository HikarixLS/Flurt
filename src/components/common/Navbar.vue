<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { 
  Film, 
  Search, 
  Bookmark, 
  Tv, 
  Compass, 
  Menu, 
  X, 
  Home, 
  Settings,
  Sparkles
} from 'lucide-vue-next';
import { useTvStore } from '../../stores/tvStore';
import SearchModal from '../search/SearchModal.vue';

const router = useRouter();
const route = useRoute();
const tvStore = useTvStore();

const isScrolled = ref(false);
const isMobileMenuOpen = ref(false);
const isSearchOpen = ref(false);

const navLinks = [
  { name: 'Trang Chủ', path: '/', icon: Home },
  { name: 'Phim Bộ', path: '/danh-sach/phim-bo', icon: Tv },
  { name: 'Phim Lẻ', path: '/danh-sach/phim-le', icon: Film },
  { name: 'TV Shows', path: '/danh-sach/tv-shows', icon: Sparkles },
  { name: 'Khám Phá', path: '/kham-pha', icon: Compass },
  { name: 'Thư Viện', path: '/thu-vien', icon: Bookmark },
];

const handleScroll = () => {
  isScrolled.value = window.scrollY > 30;
};

const openSearch = () => {
  isSearchOpen.value = true;
};

const closeSearch = () => {
  isSearchOpen.value = false;
};

const toggleMobileMenu = () => {
  isMobileMenuOpen.value = !isMobileMenuOpen.value;
};

const toggleTvMode = () => {
  tvStore.setTvMode(!tvStore.isTvMode);
};

onMounted(() => {
  window.addEventListener('scroll', handleScroll);
});

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll);
});
</script>

<template>
  <header 
    class="navbar-header"
    :class="{ 'navbar-scrolled': isScrolled, 'tv-header': tvStore.isTvMode }"
  >
    <div class="container-custom navbar-inner">
      <!-- Brand Logo -->
      <router-link to="/" class="logo-brand" data-tv-focus tabindex="0">
        <div class="logo-icon">
          <svg viewBox="0 0 100 100" class="logo-svg">
            <defs>
              <linearGradient id="logoGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stop-color="#ff0055" />
                <stop offset="50%" stop-color="#e50914" />
                <stop offset="100%" stop-color="#00d2ff" />
              </linearGradient>
            </defs>
            <path d="M28 26 H72 C74.2 26 76 27.8 76 30 C76 32.2 74.2 34 72 34 H36 V48 H66 C68.2 48 70 49.8 70 52 C70 54.2 68.2 56 66 56 H36 V74 C36 76.2 34.2 78 32 78 C29.8 78 28 76.2 28 74 V26 Z" fill="url(#logoGrad)" />
            <circle cx="74" cy="72" r="7" fill="#00d2ff" />
          </svg>
        </div>
        <span class="logo-text">FLURT<span class="logo-dot">.</span></span>
      </router-link>

      <!-- Desktop Nav Items -->
      <nav class="desktop-nav">
        <router-link
          v-for="link in navLinks"
          :key="link.path"
          :to="link.path"
          class="nav-link"
          :class="{ 'active': route.path === link.path }"
          data-tv-focus
          tabindex="0"
        >
          <component :is="link.icon" :size="16" class="nav-link-icon" />
          <span>{{ link.name }}</span>
        </router-link>
      </nav>

      <!-- Action Items -->
      <div class="navbar-actions">
        <!-- Search Trigger -->
        <button 
          class="action-btn search-btn" 
          @click="openSearch" 
          title="Tìm kiếm (Ctrl+K)"
          data-tv-focus
          tabindex="0"
        >
          <Search :size="18" />
          <span class="search-label">Tìm kiếm...</span>
          <span class="search-shortcut">/</span>
        </button>

        <!-- TV Mode Toggle -->
        <button 
          class="action-icon-btn tv-toggle-btn"
          :class="{ 'is-tv-active': tvStore.isTvMode }"
          @click="toggleTvMode" 
          :title="tvStore.isTvMode ? 'Tắt chế độ TV (10-foot UI)' : 'Bật chế độ TV Remote'"
          data-tv-focus
          tabindex="0"
        >
          <Tv :size="18" />
          <span class="tv-badge" v-if="tvStore.isTvMode">TV</span>
        </button>

        <!-- Settings Button -->
        <router-link 
          to="/cai-dat" 
          class="action-icon-btn" 
          title="Cài đặt"
          data-tv-focus
          tabindex="0"
        >
          <Settings :size="18" />
        </router-link>

        <!-- Mobile Menu Toggle -->
        <button 
          class="action-icon-btn mobile-menu-btn" 
          @click="toggleMobileMenu"
          data-tv-focus
          tabindex="0"
        >
          <component :is="isMobileMenuOpen ? X : Menu" :size="20" />
        </button>
      </div>
    </div>

    <!-- Mobile Drawer Menu -->
    <div class="mobile-drawer" :class="{ 'is-open': isMobileMenuOpen }">
      <div class="mobile-nav-list">
        <router-link
          v-for="link in navLinks"
          :key="link.path"
          :to="link.path"
          class="mobile-nav-link"
          :class="{ 'active': route.path === link.path }"
          @click="isMobileMenuOpen = false"
        >
          <component :is="link.icon" :size="20" />
          <span>{{ link.name }}</span>
        </router-link>
      </div>
    </div>

    <!-- Global Search Modal -->
    <SearchModal :is-open="isSearchOpen" @close="closeSearch" />
  </header>
</template>

<style scoped>
.navbar-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: 72px;
  z-index: 1000;
  transition: all 0.35s ease;
  background: linear-gradient(180deg, rgba(7, 8, 12, 0.9) 0%, rgba(7, 8, 12, 0) 100%);
}

.navbar-scrolled {
  background: rgba(7, 8, 12, 0.92);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
  height: 64px;
  box-shadow: 0 4px 30px rgba(0, 0, 0, 0.6);
}

.navbar-inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 100%;
}

/* Logo */
.logo-brand {
  display: flex;
  align-items: center;
  gap: 10px;
  outline: none;
  border-radius: 8px;
}

.logo-icon {
  width: 38px;
  height: 38px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.logo-svg {
  width: 100%;
  height: 100%;
  filter: drop-shadow(0 0 10px rgba(229, 9, 20, 0.6));
}

.logo-text {
  font-family: var(--font-heading);
  font-weight: 900;
  font-size: 24px;
  letter-spacing: 1px;
  color: #ffffff;
}

.logo-dot {
  color: var(--primary);
}

/* Desktop Nav */
.desktop-nav {
  display: flex;
  align-items: center;
  gap: 6px;
  background: rgba(255, 255, 255, 0.04);
  padding: 4px 6px;
  border-radius: var(--radius-full);
  border: 1px solid rgba(255, 255, 255, 0.06);
}

.nav-link {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  border-radius: var(--radius-full);
  font-size: 14px;
  font-weight: 500;
  color: var(--text-muted);
  transition: all var(--transition-fast);
}

.nav-link:hover {
  color: #ffffff;
  background: rgba(255, 255, 255, 0.08);
}

.nav-link.active {
  color: #ffffff;
  background: linear-gradient(135deg, rgba(229, 9, 20, 0.9) 0%, rgba(180, 0, 10, 0.9) 100%);
  font-weight: 600;
  box-shadow: 0 2px 12px var(--primary-glow);
}

/* Actions */
.navbar-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.search-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 14px;
  border-radius: var(--radius-full);
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--border-glass);
  color: var(--text-muted);
  font-size: 13px;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.search-btn:hover {
  background: rgba(255, 255, 255, 0.12);
  color: #ffffff;
  border-color: rgba(255, 255, 255, 0.2);
}

.search-shortcut {
  background: rgba(255, 255, 255, 0.1);
  padding: 1px 6px;
  border-radius: 4px;
  font-size: 11px;
}

.action-icon-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 38px;
  height: 38px;
  border-radius: var(--radius-full);
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--border-glass);
  color: var(--text-muted);
  cursor: pointer;
  position: relative;
  transition: all var(--transition-fast);
}

.action-icon-btn:hover {
  color: #ffffff;
  background: rgba(255, 255, 255, 0.15);
  transform: scale(1.05);
}

.tv-toggle-btn.is-tv-active {
  background: rgba(0, 210, 255, 0.2);
  border-color: var(--accent-cyan);
  color: var(--accent-cyan);
  box-shadow: 0 0 15px var(--accent-cyan-glow);
}

.tv-badge {
  position: absolute;
  top: -4px;
  right: -4px;
  font-size: 9px;
  font-weight: 800;
  padding: 1px 4px;
  border-radius: 4px;
  background: var(--accent-cyan);
  color: #000;
}

.mobile-menu-btn {
  display: none;
}

/* Mobile Drawer */
.mobile-drawer {
  display: none;
}

@media (max-width: 900px) {
  .desktop-nav {
    display: none;
  }
  .search-label, .search-shortcut {
    display: none;
  }
  .search-btn {
    padding: 8px;
    border-radius: var(--radius-full);
  }
  .mobile-menu-btn {
    display: flex;
  }

  .mobile-drawer {
    display: block;
    position: fixed;
    top: 72px;
    left: 0;
    right: 0;
    background: rgba(10, 12, 18, 0.98);
    backdrop-filter: blur(25px);
    -webkit-backdrop-filter: blur(25px);
    border-bottom: 1px solid var(--border-glass);
    padding: 20px;
    transform: translateY(-120%);
    opacity: 0;
    pointer-events: none;
    transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  }

  .mobile-drawer.is-open {
    transform: translateY(0);
    opacity: 1;
    pointer-events: auto;
  }

  .mobile-nav-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .mobile-nav-link {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 16px;
    border-radius: var(--radius-md);
    font-size: 16px;
    font-weight: 500;
    color: var(--text-muted);
  }

  .mobile-nav-link.active {
    background: linear-gradient(135deg, rgba(229, 9, 20, 0.8) 0%, rgba(180, 0, 10, 0.8) 100%);
    color: #ffffff;
  }
}
</style>
