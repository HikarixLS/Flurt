import { onMounted, onUnmounted } from 'vue';
import { useTvStore } from '../stores/tvStore';
import { useAnime } from './useAnime';

export function useTvNavigation() {
  const tvStore = useTvStore();
  const { animateTvCursor } = useAnime();

  // Find all visible focusable elements marked with [data-tv-focus]
  const getFocusableElements = (): HTMLElement[] => {
    const elements = Array.from(
      document.querySelectorAll<HTMLElement>('[data-tv-focus]')
    ).filter(el => {
      const style = window.getComputedStyle(el);
      return style.display !== 'none' && style.visibility !== 'hidden' && style.opacity !== '0';
    });
    return elements;
  };

  // Find nearest element in a direction (up, down, left, right)
  const findNextElement = (
    currentEl: HTMLElement,
    direction: 'up' | 'down' | 'left' | 'right'
  ): HTMLElement | null => {
    const focusable = getFocusableElements();
    const currentRect = currentEl.getBoundingClientRect();
    const currentCenter = {
      x: currentRect.left + currentRect.width / 2,
      y: currentRect.top + currentRect.height / 2
    };

    let bestCandidate: HTMLElement | null = null;
    let minDistance = Infinity;

    for (const targetEl of focusable) {
      if (targetEl === currentEl) continue;

      const targetRect = targetEl.getBoundingClientRect();
      const targetCenter = {
        x: targetRect.left + targetRect.width / 2,
        y: targetRect.top + targetRect.height / 2
      };

      const dx = targetCenter.x - currentCenter.x;
      const dy = targetCenter.y - currentCenter.y;

      let isValidDirection = false;
      let primaryDiff = 0;
      let secondaryDiff = 0;

      if (direction === 'left' && dx < -5) {
        isValidDirection = true;
        primaryDiff = Math.abs(dx);
        secondaryDiff = Math.abs(dy);
      } else if (direction === 'right' && dx > 5) {
        isValidDirection = true;
        primaryDiff = Math.abs(dx);
        secondaryDiff = Math.abs(dy);
      } else if (direction === 'up' && dy < -5) {
        isValidDirection = true;
        primaryDiff = Math.abs(dy);
        secondaryDiff = Math.abs(dx);
      } else if (direction === 'down' && dy > 5) {
        isValidDirection = true;
        primaryDiff = Math.abs(dy);
        secondaryDiff = Math.abs(dx);
      }

      if (isValidDirection) {
        // Distance penalty for perpendicular offset
        const distance = primaryDiff + secondaryDiff * 2.5;
        if (distance < minDistance) {
          minDistance = distance;
          bestCandidate = targetEl;
        }
      }
    }

    return bestCandidate;
  };

  const handleKeyDown = (e: KeyboardEvent) => {
    const dpadKeys = ['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'Enter', 'Escape', 'Backspace'];
    
    // Auto-enable TV mode if user uses arrow keys
    if (dpadKeys.includes(e.key) && !tvStore.isTvMode) {
      tvStore.setTvMode(true);
    }

    // Ignore if typing inside text input
    if (
      document.activeElement &&
      (document.activeElement.tagName === 'INPUT' || document.activeElement.tagName === 'TEXTAREA') &&
      e.key !== 'Escape'
    ) {
      return;
    }

    const focusable = getFocusableElements();
    if (focusable.length === 0) return;

    let current = tvStore.currentFocusedEl;
    if (!current || !document.body.contains(current)) {
      current = focusable[0];
      tvStore.setFocusedElement(current);
      return;
    }

    let nextEl: HTMLElement | null = null;

    switch (e.key) {
      case 'ArrowUp':
        e.preventDefault();
        nextEl = findNextElement(current, 'up');
        break;
      case 'ArrowDown':
        e.preventDefault();
        nextEl = findNextElement(current, 'down');
        break;
      case 'ArrowLeft':
        e.preventDefault();
        nextEl = findNextElement(current, 'left');
        break;
      case 'ArrowRight':
        e.preventDefault();
        nextEl = findNextElement(current, 'right');
        break;
      case 'Enter':
        e.preventDefault();
        current.click();
        break;
      case 'Escape':
      case 'Backspace':
        // Back navigation on TV
        if (window.history.length > 1) {
          e.preventDefault();
          window.history.back();
        }
        break;
    }

    if (nextEl) {
      tvStore.setFocusedElement(nextEl);
      const cursorBox = document.getElementById('tv-cursor-box');
      if (cursorBox) {
        animateTvCursor(cursorBox, nextEl);
      }
    }
  };

  onMounted(() => {
    window.addEventListener('keydown', handleKeyDown);
  });

  onUnmounted(() => {
    window.removeEventListener('keydown', handleKeyDown);
  });

  return {
    getFocusableElements
  };
}
