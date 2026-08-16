# 🎬 FLURT - Movie Streaming & Real-Time Watch Party Web App

**Flurt** là ứng dụng xem phim trực tuyến hiện đại và hệ thống phòng xem chung (**Watch Party**) thời gian thực, được xây dựng hoàn toàn bằng **Full-Stack Dart** (Flutter Web Frontend + Shelf WebSocket Backend Server) và tích hợp kho dữ liệu phim từ **NguonC API** (`https://phim.nguonc.com/api`).

---

## 🌟 TÍNH NĂNG NỔI BẬT

### 🍿 1. Cổng Phim Trực Tuyến Hiện Đại (Frontend Cinema Portal)
- **Giao diện Dark Cinema Luxury**: Thiết kế theo phong cách Cyber Dark & Electric Violet/Neon Cyan thời thượng, hiệu ứng kính mờ (Glassmorphism), bóng đổ phát sáng (Neon Glow) và responsive 100% trên cả Desktop, Tablet & Mobile.
- **Hero Spotlight Carousel**: Banner phim nổi bật với backdrop nghệ thuật, nhãn phân giải HD/Vietsub, tóm tắt nội dung và nút tạo phòng nhanh.
- **Danh mục phân loại đa dạng**:
  - 🔥 *Phim mới cập nhật*
  - 🎬 *Phim lẻ chiếu rạp*
  - 📺 *Phim bộ dài tập*
  - 🏆 *TV Shows truyền hình*
  - 🎨 *Anime & Hoạt hình*
- **Bộ lọc động thông minh (Catalog & Dynamic Filter)**: Lọc theo Định dạng, Thể loại (Hành động, Tình cảm, Kinh dị, Viễn tưởng...), Quốc gia (Âu Mỹ, Hàn Quốc, Trung Quốc, Nhật Bản...) và Năm phát hành kèm phân trang mượt mà.
- **Tìm kiếm tức thì (Instant Debounced Search)**: Tự động gợi ý từ khóa, lưu lịch sử tìm kiếm và hiển thị kết quả theo thời gian thực.
- **Trình phát phim Cinema Video Player**:
  - Hỗ trợ luồng phát video trực tiếp (`.m3u8` HLS) và trình phát Embed Iframe mượt mà.
  - Chuyển đổi server và danh sách tập phim nhanh chóng.
  - Hỗ trợ phím tắt điều khiển: `Space` (Phát / Tạm dừng), `Phím mũi tên Trái/Phải` (Tua 10s), `F` (Chế độ Rạp phim / Toàn màn hình).

---

### ⚡ 2. Hệ Thống Phòng Xem Chung Real-Time (Watch Party)
- **Mã phòng 6 ký tự độc nhất**: Tạo phòng tức thì (VD: `FL7K92`) hoặc tham gia qua liên kết chia sẻ tự động: `/watch-party?room=XYZ123`.
- **Đồng bộ hóa phát lại chuẩn xác (State Synchronization)**:
  - Đồng bộ các sự kiện: `PLAY`, `PAUSE`, `SEEK`, `CHANGE_EPISODE`, `CHANGE_SERVER`.
  - **Cơ chế chống lệch thời gian (Drift Correction)**: Kiểm tra heartbeat định kỳ (mỗi 3 giây), nếu khán giả lệch > 1.5s so với Trưởng phòng (Host), hệ thống tự động hiệu chỉnh tua mượt mà về đúng mốc thời gian.
  - **Quyền hạn linh hoạt**: Hỗ trợ chuyển đổi giữa chế độ *Chỉ Trưởng phòng điều khiển* (Host-Only) hoặc *Tất cả tự do điều khiển* (Free-For-All).
  - Tự động chuyển quyền Host nếu Trưởng phòng rời khỏi phòng.
- **Trò chuyện & Tương tác cảm xúc trực tiếp**:
  - Live Text Chat thời gian thực kèm tên, avatar và mốc thời gian.
  - **Floating Emoji Reaction Bursts**: Hiệu ứng các biểu tượng cảm xúc (❤️, 😂, 😱, 🔥, 👏, 🎉) bay lơ lửng trên khung video ngay khi người xem tương tác.
  - Thông báo hệ thống khi có thành viên mới vào/rời phòng hoặc khi đổi tập phim.

---

## 🏛️ KIẾN TRÚC HỆ THỐNG (CLEAN ARCHITECTURE)

```
Flurt/
├── backend/                             # Dart Shelf WebSocket Server
│   ├── bin/
│   │   └── server.dart                 # Server Entrypoint (Port 8080)
│   ├── lib/
│   │   ├── models/
│   │   │   ├── party_room.dart         # Room data model
│   │   │   ├── participant.dart        # Participant data model
│   │   │   ├── chat_message.dart       # Live chat & reaction message
│   │   │   └── sync_action.dart        # WebSocket Protocol Actions
│   │   ├── services/
│   │   │   ├── room_manager.dart       # Room lifecycle & client sockets
│   │   │   └── sync_engine.dart        # Playback sync & drift tolerance
│   │   └── handlers/
│   │       └── ws_party_handler.dart   # WebSocket upgrade & packet router
│   ├── test/
│   │   └── sync_engine_test.dart       # Backend unit tests
│   └── pubspec.yaml
│
└── frontend/                            # Flutter Web Application
    ├── lib/
    │   ├── core/
    │   │   ├── constants/              # AppColors, ApiConstants
    │   │   ├── theme/                  # Dark Luxury Cinema Theme & Glassmorphism
    │   │   ├── network/                # Dio Client with caching
    │   │   └── router/                 # GoRouter with Deep Linking
    │   ├── data/
    │   │   ├── models/                 # Film, Episode, Category DTOs
    │   │   ├── datasources/            # NguonC Remote Data Source
    │   │   └── repositories/           # MovieRepository implementation
    │   ├── domain/
    │   │   └── repositories/           # MovieRepository contract
    │   └── presentation/
    │       ├── blocs/                  # Home, Catalog, Search, Detail, WatchParty Cubits
    │       ├── widgets/
    │       │   ├── navbar/             # Sticky glassmorphic navbar
    │       │   ├── hero/               # Featured hero banner
    │       │   ├── movie/              # MovieCard with hover glow & MovieSlider
    │       │   ├── player/             # Cinema player (HLS + Iframe Embed)
    │       │   └── party/              # Live Chat, Participants, Floating Reactions
    │       └── views/
    │           ├── home/               # Trang chủ
    │           ├── catalog/            # Trang danh mục & bộ lọc
    │           ├── search/             # Trang tìm kiếm
    │           ├── detail/             # Trang chi tiết phim & xem phim
    │           └── watch_party/        # Trang phòng xem chung Watch Party
    └── pubspec.yaml
```

---

## 🚀 HƯỚNG DẪN CÀI ĐẶT & CHẠY ỨNG DỤNG

### Cách 1: Chạy tự động bằng 1 cú click (Windows)
Chỉ cần nhấp đúp chuột vào tệp:
```
run_flurt.bat
```
Tệp batch này sẽ tự động khởi chạy cả Backend (Port 8080) và mở Frontend Web (Port 3000) trên trình duyệt Chrome.

---

### Cách 2: Chạy thủ công từng dịch vụ

#### 1. Khởi động Backend WebSocket Server
```bash
cd backend
dart pub get
dart run bin/server.dart
```
> Server sẽ lắng nghe tại:
> - REST API: `http://localhost:8080`
> - WebSocket Gateway: `ws://localhost:8080/ws/party`

#### 2. Khởi động Frontend Flutter Web
```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port 3000
```
> Truy cập ứng dụng tại: `http://localhost:3000`

---

## 🐳 TRIỂN KHAI VỚI DOCKER & DOCKER-COMPOSE

Bạn có thể build và chạy toàn bộ cụm ứng dụng trên server/vps chỉ bằng một lệnh:

```bash
docker-compose up --build -d
```
- **Frontend Web**: `http://localhost:3000`
- **Backend API & WebSocket**: `http://localhost:8080`

---

## 📡 TÍCH HỢP NGUONC API

| Mục đích | Endpoint |
| :--- | :--- |
| **Phim mới cập nhật** | `GET https://phim.nguonc.com/api/films/phim-moi-cap-nhat?page={page}` |
| **Danh mục phim** | `GET https://phim.nguonc.com/api/films/danh-sach/{type}?page={page}` |
| **Lọc theo thể loại** | `GET https://phim.nguonc.com/api/films/the-loai/{genre_slug}?page={page}` |
| **Lọc theo quốc gia** | `GET https://phim.nguonc.com/api/films/quoc-gia/{country_slug}?page={page}` |
| **Lọc theo năm** | `GET https://phim.nguonc.com/api/films/nam-phat-hanh/{year}?page={page}` |
| **Chi tiết & Tập phim** | `GET https://phim.nguonc.com/api/film/{slug}` |
| **Tìm kiếm phim** | `GET https://phim.nguonc.com/api/films/search?keyword={keyword}&page={page}` |

---

## 🧪 KIỂM THỬ (TESTING)

Chạy kiểm thử tự động cho Backend:
```bash
cd backend
dart test
```
*Kết quả:* Tất cả các bài test khởi tạo phòng, tham gia phòng, chuyển quyền Host và đồng bộ trạng thái phát phim đều vượt qua 100%.

---

Chúc bạn có những trải nghiệm xem phim và Watch Party tuyệt vời cùng **Flurt**! 🍿✨
