// Simple in-memory cache to make page switches instantaneous
const cache = new Map<string, { timestamp: number; data: any }>();
const CACHE_TTL_MS = 3 * 60 * 1000; // 3 minutes

export async function fetchWithCache<T>(url: string, ttl = CACHE_TTL_MS): Promise<T> {
  const now = Date.now();
  const cached = cache.get(url);

  if (cached && now - cached.timestamp < ttl) {
    return cached.data as T;
  }

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 12000); // 12s timeout

  try {
    const response = await fetch(url, {
      signal: controller.signal,
      headers: {
        'Accept': 'application/json'
      }
    });

    clearTimeout(timeoutId);

    if (!response.ok) {
      throw new Error(`HTTP Error ${response.status}: ${response.statusText}`);
    }

    const data = await response.json();
    cache.set(url, { timestamp: now, data });
    return data as T;
  } catch (error) {
    clearTimeout(timeoutId);
    // If cached data exists even if expired, return as fallback
    if (cached) {
      console.warn(`[API] Fetch failed for ${url}, returning stale cache`, error);
      return cached.data as T;
    }
    throw error;
  }
}
