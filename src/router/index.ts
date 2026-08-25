import { createRouter, createWebHistory } from 'vue-router';
import HomeView from '../views/HomeView.vue';

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/danh-sach/:slug',
      name: 'catalog',
      component: () => import('../views/CatalogView.vue'),
      props: true
    },
    {
      path: '/the-loai/:slug?',
      name: 'genre',
      component: () => import('../views/ExploreView.vue'),
      props: route => ({ type: 'genre', slug: route.params.slug })
    },
    {
      path: '/quoc-gia/:slug?',
      name: 'country',
      component: () => import('../views/ExploreView.vue'),
      props: route => ({ type: 'country', slug: route.params.slug })
    },
    {
      path: '/nam/:year?',
      name: 'year',
      component: () => import('../views/ExploreView.vue'),
      props: route => ({ type: 'year', slug: route.params.year })
    },
    {
      path: '/kham-pha',
      name: 'explore',
      component: () => import('../views/ExploreView.vue')
    },
    {
      path: '/phim/:slug',
      name: 'movie-detail',
      component: () => import('../views/MovieDetailView.vue'),
      props: true
    },
    {
      path: '/thu-vien',
      name: 'library',
      component: () => import('../views/LibraryView.vue')
    },
    {
      path: '/cai-dat',
      name: 'settings',
      component: () => import('../views/SettingsView.vue')
    },
    {
      path: '/:pathMatch(.*)*',
      redirect: '/'
    }
  ],
  scrollBehavior(_to, _from, savedPosition) {
    if (savedPosition) {
      return savedPosition;
    }
    return { top: 0, behavior: 'smooth' };
  }
});

export default router;
