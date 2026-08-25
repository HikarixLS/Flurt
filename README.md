# 🎬 Flurt - Nền Tảng Xem Phim Trực Tuyến Vue 3 & Android / Android TV

<p align="center">
  <img src="public/favicon.svg" width="100" height="100" alt="Flurt Logo" />
</p>

<p align="center">
  <strong>Flurt</strong> là ứng dụng xem phim trực tuyến hiện đại, mượt mà được xây dựng trên nền tảng <strong>Vue 3</strong> và <strong>Vite</strong>, kết hợp hiệu ứng chuyển động ấn tượng bằng <strong>Anime.js</strong>, tích hợp dữ liệu phim trực tiếp từ <strong>NguonC API</strong> và đóng gói sẵn sàng cho <strong>Android Mobile & Android TV (10-Foot UI)</strong> thông qua <strong>Capacitor</strong>.
</p>

---

## ✨ Tính Năng Nổi Bật

- 🎨 **Giao Diện Cinema Dark Sang Trọng**: Thiết kế Obsidian Dark Theme (`#07080c`), điểm nhấn neon crimson & cyan glow, kết hợp hiệu ứng kính mờ (Glassmorphism).
- ⚡ **Hiệu Ứng Chuyển Động Với Anime.js**:
  - Hero spotlight slider với hiệu ứng stagger mượt mà cho tiêu đề, thông tin và nút bấm.
  - Staggered card entrance khi tải danh sách phim theo hàng hoặc lưới.
  - Modal tìm kiếm co giãn đàn hồi (Spring physics).
  - Dynamic TV Focus Glow Cursor tự động bám theo phím bấm trên TV.
- 🔌 **Tích Hợp Trực Tiếp NguonC API (Không Cần Backend)**:
  - Phim mới cập nhật, Phim bộ, Phim lẻ, TV Shows, Phim đang chiếu rạp.
  - 22+ Thể loại (Hành động, Hoạt hình/Anime, Kinh dị, Tình cảm, Cổ trang, v.v.).
  - 16+ Quốc gia (Âu Mỹ, Hàn Quốc, Trung Quốc, Nhật Bản, Việt Nam, v.v.).
  - Năm phát hành (2016 - 2026).
  - Tự động lưu cache in-memory giúp chuyển trang tức thì, không giật lag.
- 🍿 **Trình Phát Video Chuẩn Rạp (Cinema Video Player)**:
  - Responsive 16:9 Cinema screen, hỗ trợ Chế độ rạp chiếu (Theater mode), tắt đèn rạp (Dim lights) và Toàn màn hình.
  - Chọn server xem phim (Vietsub, Thuyết minh nếu có).
  - Danh sách tập phân trang và lọc nhanh theo số tập cho phim dài bộ.
  - Nút chuyển tập trước / tập tiếp theo, tự động lưu tiến độ xem.
- 📺 **Hỗ Trợ Android TV & Điều Khiển Từ Xa (10-Foot UI D-Pad Navigation)**:
  - Hệ thống Spatial Navigation bắt các phím điều hướng Remote TV (Mũi tên Lên/Xuống/Trái/Phải, OK/Enter, Back/Esc).
  - Tối ưu kích thước chữ và độ tương phản cao cho màn hình tivi lớn.
  - Đã cấu hình `AndroidManifest.xml` với `LEANBACK_LAUNCHER` và Banner TV.
- 💾 **Thư Viện Cá Nhân (LocalStorage)**:
  - **Tiếp tục xem**: Lưu lại tập phim và thời gian đang xem dở trên trang chủ.
  - **Phim yêu thích**: Đánh dấu lưu phim xem sau chỉ với 1 click.
  - **Lịch sử xem**: Xem lại toàn bộ phim đã xem và quản lý xóa lịch sử.
- 🔍 **Tìm Kiếm Real-Time**:
  - Popup tìm kiếm nhanh với debounce 350ms, hiển thị poster và số tập trực quan.
  - Lưu lại từ khóa tìm kiếm gần đây và gợi ý các thể loại hot.

---

## 🛠️ Công Nghệ Sử Dụng

- **Frontend**: Vue 3 (Composition API `<script setup>`), TypeScript, Vite 6
- **Routing**: Vue Router 4 (Page Transitions)
- **State Management**: Pinia 3
- **Animations**: Anime.js v3
- **Icons**: Lucide Icons (`lucide-vue-next`)
- **Mobile & TV Wrapper**: Capacitor 7 (`@capacitor/core`, `@capacitor/android`)
- **Data Source**: [NguonC Movie API](https://phim.nguonc.com/api-document)

---

## 🚀 Hướng Dẫn Cài Đặt & Chạy Dự Án

### 1. Cài Đặt Dependencies

```bash
npm install
```

### 2. Chạy Môi Trường Phát Triển (Dev Server)

```bash
npm run dev
```
Truy cập ứng dụng tại: `http://localhost:5173`

### 3. Build Production Bundle

```bash
npm run build
```

---

## 📱 Đóng Gói App Android & Android TV

Dự án đã được tích hợp sẵn nền tảng Capacitor Android:

### 1. Đồng Bộ Mã Nguồn Web Vào Android

```bash
npm run build
npx cap sync android
```

### 2. Mở Bằng Android Studio Để Build APK

```bash
npx cap open android
```

Trong Android Studio:
- Chọn **Build** > **Build Bundle(s) / APK(s)** > **Build APK(s)** để xuất file `.apk` cài đặt trực tiếp lên điện thoại hoặc Android TV Box / Smart TV.
- Ứng dụng sẽ tự động xuất hiện trên màn hình chính của Android TV (Leanback Launcher) với logo banner riêng biệt.

---

## 🎮 Hướng Dẫn Phím Tắt Điều Khiển

| Phím / Nút Remote | Chức Năng |
|---|---|
| `▲` `▼` `◄` `►` | Di chuyển giữa các phim, nút bấm và menu điều hướng |
| `Enter` / `OK` | Chọn phim / Mở video / Kích hoạt chức năng |
| `Esc` / `Back` | Quay lại trang trước hoặc đóng popup tìm kiếm |
| `/` | Mở nhanh khung tìm kiếm phim |

---

## 🔗 Liên Kết

- **GitHub Repository**: [https://github.com/HikarixLS/Flurt](https://github.com/HikarixLS/Flurt)
- **API Documentation**: [https://phim.nguonc.com/api-document](https://phim.nguonc.com/api-document)
- **Anime.js Documentation**: [https://animejs.com/documentation/](https://animejs.com/documentation/)

---

## 📄 Bản Quyền & Tuyên Bố Miễn Trừ

Tất cả nội dung video và dữ liệu phim được cung cấp bởi API công khai của NguonC. Ứng dụng không lưu trữ bất kỳ tệp video nào trên máy chủ riêng.
