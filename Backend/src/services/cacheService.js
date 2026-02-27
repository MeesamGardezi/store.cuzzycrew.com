class CacheService {
  async get() {
    return null;
  }

  async set() {
    return;
  }

  async del() {
    return;
  }
}

class NoopCacheService extends CacheService {}

let instance;

function getCacheService() {
  if (instance) return instance;
  instance = new NoopCacheService();
  return instance;
}

module.exports = { CacheService, NoopCacheService, getCacheService };
