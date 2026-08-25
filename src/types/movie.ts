export interface MovieItem {
  id?: string;
  name: string;
  slug: string;
  original_name: string;
  thumb_url: string;
  poster_url: string;
  created?: string;
  modified?: string;
  description?: string;
  total_episodes?: number | string;
  current_episode?: string;
  time?: string | null;
  quality?: string;
  language?: string;
  director?: string | null;
  casts?: string | null;
  year?: string | number;
}

export interface Paginate {
  current_page: number;
  total_page: number;
  total_items: number;
  items_per_page: number;
}

export interface MovieCategoryItem {
  id: string;
  name: string;
}

export interface MovieCategoryGroup {
  group: {
    id: string;
    name: string;
  };
  list: MovieCategoryItem[];
}

export interface EpisodeItem {
  name: string;
  slug: string;
  embed: string;
}

export interface EpisodeServer {
  server_name: string;
  items: EpisodeItem[];
}

export interface MovieDetail extends MovieItem {
  category?: Record<string, MovieCategoryGroup>;
  episodes: EpisodeServer[];
}

export interface ApiResponseList {
  status: string;
  paginate: Paginate;
  cat?: any;
  items: MovieItem[];
}

export interface ApiResponseDetail {
  status: string;
  movie: MovieDetail;
}

export interface WatchHistoryItem {
  movie: MovieItem;
  lastEpisodeSlug: string;
  lastEpisodeName: string;
  watchedAt: number;
}

// Fixed Categories List
export const CATEGORIES = [
  { slug: 'phim-bo', name: 'Phim Bộ', icon: 'Tv' },
  { slug: 'phim-le', name: 'Phim Lẻ', icon: 'Film' },
  { slug: 'tv-shows', name: 'TV Shows', icon: 'Radio' },
  { slug: 'dang-chieu', name: 'Đang Chiếu', icon: 'Flame' }
];

// 22 Genres Supported by NguonC
export const GENRES = [
  { slug: 'hanh-dong', name: 'Hành Động' },
  { slug: 'phieu-luu', name: 'Phiêu Lưu' },
  { slug: 'hoat-hinh', name: 'Hoạt Hình' },
  { slug: 'phim-hai', name: 'Hài Hước' },
  { slug: 'hinh-su', name: 'Hình Sự' },
  { slug: 'tai-lieu', name: 'Tài Liệu' },
  { slug: 'chinh-kich', name: 'Chính Kịch' },
  { slug: 'gia-dinh', name: 'Gia Đình' },
  { slug: 'gia-tuong', name: 'Giả Tưởng' },
  { slug: 'lich-su', name: 'Lịch Sử' },
  { slug: 'kinh-di', name: 'Kinh Dị' },
  { slug: 'phim-nhac', name: 'Âm Nhạc' },
  { slug: 'bi-an', name: 'Bí Ẩn' },
  { slug: 'lang-man', name: 'Lãng Mạn' },
  { slug: 'khoa-hoc-vien-tuong', name: 'Khoa Học Viễn Tưởng' },
  { slug: 'gay-can', name: 'Gây Cấn' },
  { slug: 'chien-tranh', name: 'Chiến Tranh' },
  { slug: 'tam-ly', name: 'Tâm Lý' },
  { slug: 'tinh-cam', name: 'Tình Cảm' },
  { slug: 'co-trang', name: 'Cổ Trang' },
  { slug: 'mien-tay', name: 'Miền Tây' },
  { slug: 'phim-18', name: 'Phim 18+' }
];

// 16 Countries Supported by NguonC
export const COUNTRIES = [
  { slug: 'au-my', name: 'Âu Mỹ' },
  { slug: 'han-quoc', name: 'Hàn Quốc' },
  { slug: 'trung-quoc', name: 'Trung Quốc' },
  { slug: 'nhat-ban', name: 'Nhật Bản' },
  { slug: 'viet-nam', name: 'Việt Nam' },
  { slug: 'thai-lan', name: 'Thái Lan' },
  { slug: 'hong-kong', name: 'Hồng Kông' },
  { slug: 'dai-loan', name: 'Đài Loan' },
  { slug: 'anh', name: 'Anh' },
  { slug: 'phap', name: 'Pháp' },
  { slug: 'indonesia', name: 'Indonesia' },
  { slug: 'philippines', name: 'Philippines' },
  { slug: 'an-do', name: 'Ấn Độ' },
  { slug: 'nga', name: 'Nga' },
  { slug: 'ha-lan', name: 'Hà Lan' },
  { slug: 'quoc-gia-khac', name: 'Quốc Gia Khác' }
];

// Release Years
export const YEARS = [
  2026, 2025, 2024, 2023, 2022, 2021, 2020, 2019, 2018, 2017, 2016
];
