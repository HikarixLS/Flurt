<script setup lang="ts">
import { Heart, Sparkles } from 'lucide-vue-next';
import { CATEGORIES, GENRES } from '../../types/movie';

const topGenres = GENRES.slice(0, 8);
</script>

<template>
  <footer class="footer-root">
    <div class="container-custom footer-inner">
      <div class="footer-top">
        <!-- Brand Info -->
        <div class="footer-col brand-col">
          <div class="logo-brand">
            <span class="logo-text">FLURT<span class="logo-dot">.</span></span>
          </div>
          <p class="brand-desc">
            Nền tảng xem phim trực tuyến miễn phí với giao diện tối ưu tốc độ, hiệu ứng mượt mà và tương thích tốt trên mọi thiết bị máy tính, điện thoại, Android TV.
          </p>
          <div class="api-credit">
            <Sparkles :size="14" class="sparkle-icon" />
            <span>Dữ liệu & video cung cấp bởi <strong>NguonC API</strong></span>
          </div>
        </div>

        <!-- Quick Links -->
        <div class="footer-col">
          <h4 class="col-title">Danh Mục</h4>
          <ul class="footer-links">
            <li v-for="cat in CATEGORIES" :key="cat.slug">
              <router-link :to="`/danh-sach/${cat.slug}`" class="footer-link" data-tv-focus tabindex="0">
                {{ cat.name }}
              </router-link>
            </li>
          </ul>
        </div>

        <!-- Top Genres -->
        <div class="footer-col">
          <h4 class="col-title">Thể Loại Hot</h4>
          <ul class="footer-links-grid">
            <li v-for="genre in topGenres" :key="genre.slug">
              <router-link :to="`/the-loai/${genre.slug}`" class="footer-link" data-tv-focus tabindex="0">
                {{ genre.name }}
              </router-link>
            </li>
          </ul>
        </div>

        <!-- TV & App Info -->
        <div class="footer-col">
          <h4 class="col-title">Nền Tảng</h4>
          <p class="footer-text-small">
            Hỗ trợ điều khiển bằng Remote TV (D-Pad), tương thích Android Mobile, Android TV và Web PWA.
          </p>
          <router-link to="/cai-dat" class="btn-secondary tv-setup-btn" data-tv-focus tabindex="0">
            Cài đặt & TV Mode
          </router-link>
        </div>
      </div>

      <div class="footer-bottom">
        <p class="copyright">
          © 2026 Flurt Movie App. All rights reserved. Created with <Heart :size="14" class="heart-icon" /> for Movie Lovers.
        </p>
        <p class="disclaimer">
          Tuyên bố miễn trừ: Flurt không lưu trữ bất kỳ tệp video nào trên máy chủ. Tất cả nội dung được tổng hợp tự động từ API công khai của NguonC.
        </p>
      </div>
    </div>
  </footer>
</template>

<style scoped>
.footer-root {
  background: #050608;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
  margin-top: 80px;
  padding: 60px 0 30px;
}

.footer-top {
  display: grid;
  grid-template-columns: 2fr 1fr 1.5fr 1.2fr;
  gap: 40px;
  margin-bottom: 50px;
}

.brand-col {
  padding-right: 20px;
}

.logo-brand {
  margin-bottom: 16px;
}

.logo-text {
  font-family: var(--font-heading);
  font-weight: 900;
  font-size: 26px;
  letter-spacing: 1px;
}

.logo-dot {
  color: var(--primary);
}

.brand-desc {
  color: var(--text-muted);
  font-size: 14px;
  line-height: 1.6;
  margin-bottom: 16px;
}

.api-credit {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: rgba(0, 210, 255, 0.08);
  border: 1px solid rgba(0, 210, 255, 0.2);
  color: var(--accent-cyan);
  padding: 6px 12px;
  border-radius: var(--radius-full);
  font-size: 12px;
}

.sparkle-icon {
  color: var(--accent-cyan);
}

.col-title {
  font-size: 16px;
  font-weight: 700;
  color: #ffffff;
  margin-bottom: 18px;
  letter-spacing: 0.5px;
}

.footer-links {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.footer-links-grid {
  list-style: none;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.footer-link {
  color: var(--text-muted);
  font-size: 14px;
  transition: color var(--transition-fast), transform var(--transition-fast);
  display: inline-block;
}

.footer-link:hover {
  color: #ffffff;
  transform: translateX(4px);
}

.footer-text-small {
  color: var(--text-dim);
  font-size: 13px;
  line-height: 1.6;
  margin-bottom: 16px;
}

.tv-setup-btn {
  font-size: 13px;
  padding: 8px 16px;
}

.footer-bottom {
  border-top: 1px solid rgba(255, 255, 255, 0.05);
  padding-top: 24px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  align-items: center;
  text-align: center;
}

.copyright {
  color: var(--text-muted);
  font-size: 13px;
  display: flex;
  align-items: center;
  gap: 6px;
}

.heart-icon {
  color: var(--primary);
  fill: var(--primary);
}

.disclaimer {
  color: var(--text-dim);
  font-size: 12px;
  max-width: 800px;
  line-height: 1.5;
}

@media (max-width: 900px) {
  .footer-top {
    grid-template-columns: 1fr 1fr;
  }
}

@media (max-width: 600px) {
  .footer-top {
    grid-template-columns: 1fr;
  }
}
</style>
