<script setup lang="ts">
import { useTvStore } from '../stores/tvStore';
import { 
  Tv, 
  Settings, 
  Smartphone, 
  Keyboard, 
  Sparkles, 
  Info,
  CheckCircle2
} from 'lucide-vue-next';

const tvStore = useTvStore();

const toggleTvMode = () => {
  tvStore.setTvMode(!tvStore.isTvMode);
};
</script>

<template>
  <div class="settings-view">
    <div class="container-custom">
      <!-- Settings Header -->
      <div class="settings-header glass-panel">
        <div class="header-icon-box">
          <Settings :size="32" />
        </div>
        <div class="header-text">
          <h1 class="settings-title">Cài Đặt & Nền Tảng</h1>
          <p class="settings-desc">Tùy chỉnh chế độ hiển thị, điều khiển Android TV và xem thông tin hệ thống.</p>
        </div>
      </div>

      <div class="settings-sections-grid">
        <!-- 1. Android TV Mode Card -->
        <div class="settings-card glass-panel">
          <div class="card-header">
            <div class="card-header-left">
              <Tv :size="22" class="card-icon cyan" />
              <h3>Chế Độ Android TV (10-Foot UI)</h3>
            </div>
            <!-- Toggle Switch -->
            <button 
              class="switch-toggle" 
              :class="{ 'is-on': tvStore.isTvMode }"
              @click="toggleTvMode"
              data-tv-focus
              tabindex="0"
            >
              <span class="switch-ball"></span>
            </button>
          </div>

          <p class="card-desc">
            Khi bật, giao diện sẽ phóng to kích thước phím bấm, văn bản và kích hoạt viền focus neon phát sáng theo dõi điều khiển từ xa (Remote D-Pad) để xem phim thoải mái trên màn hình tivi lớn.
          </p>

          <div class="tv-status-badge" :class="{ 'active': tvStore.isTvMode }">
            <CheckCircle2 :size="16" />
            <span>Trạng thái: {{ tvStore.isTvMode ? 'ĐANG BẬT' : 'ĐANG TẮT' }}</span>
          </div>
        </div>

        <!-- 2. Remote & Keyboard Navigation Guide -->
        <div class="settings-card glass-panel">
          <div class="card-header">
            <div class="card-header-left">
              <Keyboard :size="22" class="card-icon red" />
              <h3>Phím Tắt Điều Khiển TV & Bàn Phím</h3>
            </div>
          </div>

          <div class="shortcuts-list">
            <div class="shortcut-item">
              <span class="key-badge">▲ ▼ ◄ ►</span>
              <span class="shortcut-desc">Di chuyển giữa các phim, nút bấm và menu</span>
            </div>
            <div class="shortcut-item">
              <span class="key-badge">Enter / OK</span>
              <span class="shortcut-desc">Chọn phim / Mở video / Kích hoạt chức năng</span>
            </div>
            <div class="shortcut-item">
              <span class="key-badge">Esc / Back</span>
              <span class="shortcut-desc">Quay lại trang trước hoặc đóng bảng tìm kiếm</span>
            </div>
            <div class="shortcut-item">
              <span class="key-badge">/</span>
              <span class="shortcut-desc">Mở nhanh ô tìm kiếm phim</span>
            </div>
          </div>
        </div>

        <!-- 3. Android & Android TV App Build Info -->
        <div class="settings-card glass-panel">
          <div class="card-header">
            <div class="card-header-left">
              <Smartphone :size="22" class="card-icon purple" />
              <h3>Đóng Gói App Android & Android TV</h3>
            </div>
          </div>

          <p class="card-desc">
            Dự án đã tích hợp sẵn <strong>Capacitor</strong> với cấu hình đầy đủ cho cả Android Phone và Android TV (Leanback launcher & non-touch screen support).
          </p>

          <div class="terminal-box">
            <code>
              # 1. Build web production<br/>
              npm run build<br/><br/>
              # 2. Đồng bộ sang Android project<br/>
              npx cap sync android<br/><br/>
              # 3. Mở Android Studio để build APK / AAB<br/>
              npx cap open android
            </code>
          </div>
        </div>

        <!-- 4. System & API Info -->
        <div class="settings-card glass-panel">
          <div class="card-header">
            <div class="card-header-left">
              <Sparkles :size="22" class="card-icon gold" />
              <h3>Thông Tin Hệ Thống</h3>
            </div>
          </div>

          <div class="system-info-list">
            <div class="sys-item">
              <span class="sys-label">Ứng dụng:</span>
              <span class="sys-value">Flurt Movie Stream v1.0.0</span>
            </div>
            <div class="sys-item">
              <span class="sys-label">Frontend Framework:</span>
              <span class="sys-value">Vue 3 (Composition API) + Vite</span>
            </div>
            <div class="sys-item">
              <span class="sys-label">Animation Engine:</span>
              <span class="sys-value">Anime.js v3</span>
            </div>
            <div class="sys-item">
              <span class="sys-label">Nguồn dữ liệu & Player:</span>
              <span class="sys-value">NguonC REST API (phim.nguonc.com)</span>
            </div>
            <div class="sys-item">
              <span class="sys-label">GitHub Repository:</span>
              <a href="https://github.com/HikarixLS/Flurt" target="_blank" class="sys-link">github.com/HikarixLS/Flurt</a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.settings-view {
  min-height: 100vh;
  padding-top: 100px;
  padding-bottom: 60px;
}

.settings-header {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 32px;
  border-radius: var(--radius-xl);
  margin-bottom: 36px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.06) 0%, rgba(13, 15, 22, 0.95) 100%);
}

.header-icon-box {
  width: 60px;
  height: 60px;
  border-radius: var(--radius-lg);
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid var(--border-glass);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #ffffff;
  flex-shrink: 0;
}

.settings-title {
  font-size: 32px;
  font-weight: 800;
  margin-bottom: 6px;
  color: #ffffff;
}

.settings-desc {
  font-size: 14px;
  color: var(--text-muted);
}

.settings-sections-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

.settings-card {
  padding: 28px;
  border-radius: var(--radius-xl);
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.card-header-left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.card-header-left h3 {
  font-size: 18px;
  font-weight: 700;
  color: #ffffff;
}

.card-icon.cyan { color: var(--accent-cyan); }
.card-icon.red { color: var(--primary); }
.card-icon.purple { color: var(--accent-purple); }
.card-icon.gold { color: var(--accent-gold); }

.card-desc {
  font-size: 14px;
  color: var(--text-muted);
  line-height: 1.6;
}

/* Switch */
.switch-toggle {
  width: 54px;
  height: 30px;
  border-radius: var(--radius-full);
  background: rgba(255, 255, 255, 0.15);
  border: 1px solid var(--border-glass);
  cursor: pointer;
  position: relative;
  transition: all var(--transition-fast);
  padding: 2px;
}

.switch-ball {
  display: block;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #ffffff;
  transition: transform var(--transition-fast);
}

.switch-toggle.is-on {
  background: var(--accent-cyan);
  border-color: var(--accent-cyan);
  box-shadow: 0 0 15px var(--accent-cyan-glow);
}

.switch-toggle.is-on .switch-ball {
  transform: translateX(24px);
  background: #000000;
}

.tv-status-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 14px;
  border-radius: var(--radius-sm);
  background: rgba(255, 255, 255, 0.05);
  color: var(--text-muted);
  font-size: 13px;
  font-weight: 600;
  width: fit-content;
}

.tv-status-badge.active {
  background: rgba(0, 210, 255, 0.15);
  border: 1px solid rgba(0, 210, 255, 0.4);
  color: var(--accent-cyan);
}

/* Shortcuts */
.shortcuts-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.shortcut-item {
  display: flex;
  align-items: center;
  gap: 14px;
}

.key-badge {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #ffffff;
  font-family: monospace;
  font-size: 12px;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: var(--radius-sm);
  min-width: 85px;
  text-align: center;
}

.shortcut-desc {
  font-size: 13px;
  color: var(--text-muted);
}

/* Terminal Box */
.terminal-box {
  background: #050608;
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: var(--radius-md);
  padding: 16px;
  font-family: 'Courier New', Courier, monospace;
  font-size: 13px;
  color: #a8ff60;
  line-height: 1.5;
}

/* System info */
.system-info-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.sys-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 13px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.04);
  padding-bottom: 8px;
}

.sys-label {
  color: var(--text-muted);
}

.sys-value {
  color: #ffffff;
  font-weight: 600;
}

.sys-link {
  color: var(--accent-cyan);
  text-decoration: underline;
}

@media (max-width: 900px) {
  .settings-sections-grid {
    grid-template-columns: 1fr;
  }
}
</style>
