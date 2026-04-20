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

class FirebaseStorageService extends StorageService {
  constructor({ admin }) {
    super();
    this.admin = admin;
  }

  _bucket() {
    return this.admin.storage().bucket();
  }

  async uploadImage({ buffer, contentType, key }) {
    const bucket = this._bucket();
    const file = bucket.file(key);

    await file.save(buffer, {
      contentType: contentType || 'application/octet-stream',
      resumable: false,
      validation: false,
    });

    await file.makePublic();
    return { key };
  }

  async deleteImage({ key }) {
    const bucket = this._bucket();
    await bucket.file(key).delete({ ignoreNotFound: true });
    return { deleted: true };
  }

  generatePublicUrl({ key }) {
    const bucket = this._bucket();
    const normalizedKey = String(key || '')
      .split('/')
      .map((segment) => encodeURIComponent(segment))
      .join('/');
    return `https://storage.googleapis.com/${bucket.name}/${normalizedKey}`;
  }
}

class MockStorageService extends StorageService {
  async uploadImage({ fileName, key }) {
    const resolvedKey = key || `mock/${Date.now()}_${fileName}`;
    return { key: resolvedKey };
  }

  async deleteImage() {
    return { deleted: true };
  }

  generatePublicUrl({ key }) {
    const normalizedKey = String(key || '')
      .split('/')
      .map((segment) => encodeURIComponent(segment))
      .join('/');
    return `https://mock-storage.local/${normalizedKey}`;
  }
}

let instance;

function getStorageService() {
  if (instance) return instance;

  try {
    // Lazy-require so local usage doesn't break if storage isn't configured.
    const { admin } = require('../config/firebase');
    if (admin && typeof admin.storage === 'function') {
      instance = new FirebaseStorageService({ admin });
      return instance;
    }
  } catch {
    // ignore
  }

  instance = new MockStorageService();
  return instance;
}

module.exports = { StorageService, FirebaseStorageService, MockStorageService, getStorageService };
