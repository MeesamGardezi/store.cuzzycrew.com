class StorageService {
  async uploadImage() {
    throw new Error('Not implemented');
  }

  async deleteImage() {
    throw new Error('Not implemented');
  }

  generatePublicUrl() {
    throw new Error('Not implemented');
  }
}

class MockStorageService extends StorageService {
  async uploadImage({ fileName }) {
    const key = `mock/${Date.now()}_${fileName}`;
    return { key };
  }

  async deleteImage() {
    return { deleted: true };
  }

  generatePublicUrl({ key }) {
    return `https://mock-storage.local/${encodeURIComponent(key)}`;
  }
}

let instance;

function getStorageService() {
  if (instance) return instance;
  instance = new MockStorageService();
  return instance;
}

module.exports = { StorageService, MockStorageService, getStorageService };
