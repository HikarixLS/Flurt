class ApiConstants {
  static const String baseUrl = 'https://phim.nguonc.com/api';
  
  // Endpoints
  static const String newlyUpdated = '/films/phim-moi-cap-nhat';
  static const String filmList = '/films/danh-sach';
  static const String genre = '/films/the-loai';
  static const String country = '/films/quoc-gia';
  static const String releaseYear = '/films/nam-phat-hanh';
  static const String filmDetail = '/film';
  static const String search = '/films/search';

  // WebSocket Watch Party Server
  static const String defaultWsUrl = 'ws://localhost:8080/ws/party';
  static const String defaultHttpBackend = 'http://localhost:8080';

  // Static Categories
  static const List<Map<String, String>> categories = [
    {'name': 'Phim Mới', 'slug': 'phim-moi-cap-nhat', 'type': 'updated'},
    {'name': 'Phim Lẻ', 'slug': 'phim-le', 'type': 'list'},
    {'name': 'Phim Bộ', 'slug': 'phim-bo', 'type': 'list'},
    {'name': 'TV Shows', 'slug': 'tv-shows', 'type': 'list'},
    {'name': 'Đang Chiếu', 'slug': 'dang-chieu', 'type': 'list'},
  ];

  // Static Genres
  static const List<Map<String, String>> genres = [
    {'name': 'Hành Động', 'slug': 'hanh-dong'},
    {'name': 'Tình Cảm', 'slug': 'tinh-cam'},
    {'name': 'Hài Hước', 'slug': 'hai-huoc'},
    {'name': 'Cổ Trang', 'slug': 'co-trang'},
    {'name': 'Tâm Lý', 'slug': 'tam-ly'},
    {'name': 'Kinh Dị', 'slug': 'kinh-di'},
    {'name': 'Viễn Tưởng', 'slug': 'vien-tuong'},
    {'name': 'Hoạt Hình', 'slug': 'hoat-hinh'},
    {'name': 'Võ Thuật', 'slug': 'vo-thuat'},
    {'name': 'Phiêu Lưu', 'slug': 'phieu-luu'},
    {'name': 'Hình Sự', 'slug': 'hinh-su'},
    {'name': 'Chiến Tranh', 'slug': 'chien-tranh'},
    {'name': 'Tài Liệu', 'slug': 'tai-lieu'},
    {'name': 'Bí Ẩn', 'slug': 'bi-an'},
  ];

  // Static Countries
  static const List<Map<String, String>> countries = [
    {'name': 'Trung Quốc', 'slug': 'trung-quoc'},
    {'name': 'Hàn Quốc', 'slug': 'han-quoc'},
    {'name': 'Âu Mỹ', 'slug': 'au-my'},
    {'name': 'Nhật Bản', 'slug': 'nhat-ban'},
    {'name': 'Thái Lan', 'slug': 'thai-lan'},
    {'name': 'Việt Nam', 'slug': 'viet-nam'},
    {'name': 'Đài Loan', 'slug': 'dai-loan'},
    {'name': 'Ấn Độ', 'slug': 'an-do'},
    {'name': 'Hồng Kông', 'slug': 'hong-kong'},
  ];

  // Static Years
  static const List<String> years = [
    '2026', '2025', '2024', '2023', '2022', '2021', '2020', '2019', '2018', '2017'
  ];
}
