const { getDb } = require('../config/firebase');

function bannersDoc() {
  return getDb().collection('siteContent').doc('websiteBanner');
}

async function getWebsiteBanner() {
  const doc = await bannersDoc().get();
  if (!doc.exists) return { images: [] };
  const data = doc.data() || {};
  const images = Array.isArray(data.images) ? data.images : [];
  return { images };
}

async function setWebsiteBanner({ images, nowIso }) {
  await bannersDoc().set({ images: Array.isArray(images) ? images : [], updatedAt: nowIso }, { merge: true });
}

module.exports = { getWebsiteBanner, setWebsiteBanner };
