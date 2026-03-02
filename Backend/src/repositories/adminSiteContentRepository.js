const { getDb } = require('../config/firebase');

function websiteBannerDoc() {
  return getDb().collection('siteContent').doc('websiteBanner');
}

async function getWebsiteBanner() {
  const doc = await websiteBannerDoc().get();
  if (!doc.exists) return { images: [] };
  const data = doc.data() || {};
  return { images: Array.isArray(data.images) ? data.images : [] };
}

async function setWebsiteBanner({ images, nowIso }) {
  await websiteBannerDoc().set({ images: Array.isArray(images) ? images : [], updatedAt: nowIso }, { merge: true });
  return getWebsiteBanner();
}

module.exports = { getWebsiteBanner, setWebsiteBanner };
