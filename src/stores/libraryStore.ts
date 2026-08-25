import { defineStore } from 'pinia';
import { ref } from 'vue';
import type { MovieItem, WatchHistoryItem } from '../types/movie';

export const useLibraryStore = defineStore('library', () => {
  // Load from localStorage
  const savedFavs = localStorage.getItem('flurt_favorites');
  const savedHist = localStorage.getItem('flurt_history');

  const favorites = ref<MovieItem[]>(savedFavs ? JSON.parse(savedFavs) : []);
  const history = ref<WatchHistoryItem[]>(savedHist ? JSON.parse(savedHist) : []);

  const saveFavorites = () => {
    localStorage.setItem('flurt_favorites', JSON.stringify(favorites.value));
  };

  const saveHistory = () => {
    localStorage.setItem('flurt_history', JSON.stringify(history.value));
  };

  const isFavorite = (slug: string) => {
    return favorites.value.some(item => item.slug === slug);
  };

  const toggleFavorite = (movie: MovieItem) => {
    const index = favorites.value.findIndex(item => item.slug === movie.slug);
    if (index > -1) {
      favorites.value.splice(index, 1);
    } else {
      favorites.value.unshift(movie);
    }
    saveFavorites();
  };

  const addToHistory = (movie: MovieItem, episodeSlug: string, episodeName: string) => {
    const index = history.value.findIndex(item => item.movie.slug === movie.slug);
    const newEntry: WatchHistoryItem = {
      movie,
      lastEpisodeSlug: episodeSlug,
      lastEpisodeName: episodeName,
      watchedAt: Date.now()
    };

    if (index > -1) {
      history.value.splice(index, 1);
    }
    history.value.unshift(newEntry);

    // Keep max 50 recent movies
    if (history.value.length > 50) {
      history.value.pop();
    }
    saveHistory();
  };

  const removeFromHistory = (slug: string) => {
    history.value = history.value.filter(item => item.movie.slug !== slug);
    saveHistory();
  };

  const clearHistory = () => {
    history.value = [];
    saveHistory();
  };

  return {
    favorites,
    history,
    isFavorite,
    toggleFavorite,
    addToHistory,
    removeFromHistory,
    clearHistory
  };
});
