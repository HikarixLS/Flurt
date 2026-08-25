import { fetchWithCache } from './client';
import type { ApiResponseList, ApiResponseDetail } from '../types/movie';

const BASE_URL = 'https://phim.nguonc.com/api';

export const movieApi = {
  /**
   * Phim mới cập nhật
   */
  async getNewUpdated(page = 1): Promise<ApiResponseList> {
    return fetchWithCache<ApiResponseList>(`${BASE_URL}/films/phim-moi-cap-nhat?page=${page}`);
  },

  /**
   * Phim theo danh mục: 'phim-bo', 'phim-le', 'tv-shows', 'dang-chieu'
   */
  async getByCategory(slug: string, page = 1): Promise<ApiResponseList> {
    return fetchWithCache<ApiResponseList>(`${BASE_URL}/films/danh-sach/${slug}?page=${page}`);
  },

  /**
   * Phim theo thể loại: 'hanh-dong', 'hoat-hinh', 'kinh-di', etc.
   */
  async getByGenre(slug: string, page = 1): Promise<ApiResponseList> {
    return fetchWithCache<ApiResponseList>(`${BASE_URL}/films/the-loai/${slug}?page=${page}`);
  },

  /**
   * Phim theo quốc gia: 'au-my', 'han-quoc', 'trung-quoc', etc.
   */
  async getByCountry(slug: string, page = 1): Promise<ApiResponseList> {
    return fetchWithCache<ApiResponseList>(`${BASE_URL}/films/quoc-gia/${slug}?page=${page}`);
  },

  /**
   * Phim theo năm phát hành: 2026, 2025, 2024, etc.
   */
  async getByYear(year: number | string, page = 1): Promise<ApiResponseList> {
    return fetchWithCache<ApiResponseList>(`${BASE_URL}/films/nam-phat-hanh/${year}?page=${page}`);
  },

  /**
   * Tìm kiếm phim theo từ khóa
   */
  async search(keyword: string): Promise<ApiResponseList> {
    const encoded = encodeURIComponent(keyword.trim());
    return fetchWithCache<ApiResponseList>(`${BASE_URL}/films/search?keyword=${encoded}`, 60 * 1000);
  },

  /**
   * Chi tiết phim và danh sách tập
   */
  async getDetail(slug: string): Promise<ApiResponseDetail> {
    return fetchWithCache<ApiResponseDetail>(`${BASE_URL}/film/${slug}`, 5 * 60 * 1000);
  }
};
