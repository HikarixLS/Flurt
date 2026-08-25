import anime from 'animejs';

export function useAnime() {
  /**
   * Hero banner slide transition with staggered elements
   */
  const animateHeroSlide = (container: HTMLElement | null) => {
    if (!container) return;

    // Reset and animate hero elements
    anime.remove([
      container.querySelectorAll('.hero-badge'),
      container.querySelectorAll('.hero-title'),
      container.querySelectorAll('.hero-meta'),
      container.querySelectorAll('.hero-desc'),
      container.querySelectorAll('.hero-actions')
    ]);

    anime({
      targets: container.querySelector('.hero-backdrop-img'),
      scale: [1.08, 1],
      opacity: [0.3, 1],
      duration: 1000,
      easing: 'easeOutCubic'
    });

    anime({
      targets: [
        container.querySelector('.hero-badge'),
        container.querySelector('.hero-title'),
        container.querySelector('.hero-meta'),
        container.querySelector('.hero-desc'),
        container.querySelector('.hero-actions')
      ],
      translateY: [35, 0],
      opacity: [0, 1],
      delay: anime.stagger(100, { start: 150 }),
      duration: 800,
      easing: 'easeOutQuart'
    });
  };

  /**
   * Staggered entrance for movie grid / row cards
   */
  const animateCardGrid = (targets: string | HTMLElement[] | NodeListOf<Element>) => {
    anime.remove(targets);
    return anime({
      targets,
      translateY: [30, 0],
      opacity: [0, 1],
      scale: [0.94, 1],
      delay: anime.stagger(45, { start: 50 }),
      duration: 650,
      easing: 'easeOutCubic'
    });
  };

  /**
   * Search / Detail Modal entrance with spring physics
   */
  const animateModalIn = (backdrop: HTMLElement | null, content: HTMLElement | null) => {
    if (backdrop) {
      anime({
        targets: backdrop,
        opacity: [0, 1],
        duration: 300,
        easing: 'easeOutQuad'
      });
    }
    if (content) {
      anime({
        targets: content,
        scale: [0.85, 1],
        opacity: [0, 1],
        translateY: [20, 0],
        duration: 450,
        easing: 'easeOutBack'
      });
    }
  };

  /**
   * Modal exit animation
   */
  const animateModalOut = (
    backdrop: HTMLElement | null,
    content: HTMLElement | null,
    onComplete?: () => void
  ) => {
    if (backdrop) {
      anime({
        targets: backdrop,
        opacity: [1, 0],
        duration: 250,
        easing: 'easeInQuad'
      });
    }
    if (content) {
      anime({
        targets: content,
        scale: [1, 0.9],
        opacity: [1, 0],
        translateY: [0, 20],
        duration: 250,
        easing: 'easeInQuad',
        complete: () => {
          if (onComplete) onComplete();
        }
      });
    } else if (onComplete) {
      setTimeout(onComplete, 250);
    }
  };

  /**
   * Smoothly move TV focus glow box to new target element
   */
  const animateTvCursor = (cursorEl: HTMLElement | null, targetEl: HTMLElement | null) => {
    if (!cursorEl || !targetEl) return;

    const rect = targetEl.getBoundingClientRect();
    const padding = 4;

    anime.remove(cursorEl);
    anime({
      targets: cursorEl,
      top: rect.top - padding,
      left: rect.left - padding,
      width: rect.width + padding * 2,
      height: rect.height + padding * 2,
      borderRadius: window.getComputedStyle(targetEl).borderRadius || '12px',
      opacity: [0.7, 1],
      duration: 260,
      easing: 'easeOutCubic'
    });
  };

  /**
   * Pulse button / pill click animation
   */
  const animatePulse = (el: HTMLElement | null) => {
    if (!el) return;
    anime({
      targets: el,
      scale: [1, 0.92, 1.05, 1],
      duration: 350,
      easing: 'easeInOutQuad'
    });
  };

  return {
    animateHeroSlide,
    animateCardGrid,
    animateModalIn,
    animateModalOut,
    animateTvCursor,
    animatePulse
  };
}
