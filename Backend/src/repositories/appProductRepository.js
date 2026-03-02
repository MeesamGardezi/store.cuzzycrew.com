const { getDb } = require('../config/firebase');

function productsCol() {
  return getDb().collection('products');
}

function safeIso(value) {
  if (!value) return null;
  if (typeof value === 'string') return value;
  if (value.toDate && typeof value.toDate === 'function') {
    try {
      return value.toDate().toISOString();
    } catch {
      return null;
    }
  }
  if (value._seconds) {
    try {
      return new Date(value._seconds * 1000).toISOString();
    } catch {
      return null;
    }
  }
  return null;
}

function normalizeColorVariants(raw) {
  if (!Array.isArray(raw)) return [];
  return raw
    .map((v) => v || {})
    .map((v) => ({
      colorName: String(v.colorName || ''),
      colorHex: String(v.colorHex || '#000000'),
      image: String(v.image || ''),
    }))
    .filter((v) => v.colorName || v.image);
}

function normalizeProduct(doc) {
  return {
    id: String(doc.id || ''),
    category: String(doc.category || 'uncategorized'),
    dateAdded: safeIso(doc.dateAdded) || safeIso(doc.createdAt) || new Date(0).toISOString(),
    name: String(doc.name || ''),
    shortName: String(doc.shortName || doc.name || ''),
    price: doc.price != null ? Number(doc.price) : 0.0,
    currency: String(doc.currency || 'USD'),
    unit: String(doc.unit || 'piece'),
    availableUnits: Number.isFinite(Number(doc.availableUnits)) ? Number(doc.availableUnits) : 0,
    thumbnail: String(doc.thumbnail || ''),
    sizeGuideImage: String(doc.sizeGuideImage || ''),
    sizes: Array.isArray(doc.sizes) ? doc.sizes.map((s) => String(s)) : [],
    colorVariants: normalizeColorVariants(doc.colorVariants),
    ...(Array.isArray(doc.images) ? { images: doc.images.map((i) => String(i)) } : {}),
    ...(doc.story ? { story: String(doc.story) } : {}),
  };
}

async function listForApp({ category } = {}) {
  let q = productsCol().where('deletedAt', '==', null);
  if (category) q = q.where('category', '==', category);

  const snap = await q.get();
  const items = snap.docs.map((d) => normalizeProduct({ id: d.id, ...d.data() }));

  items.sort((a, b) => {
    const da = Date.parse(a.dateAdded || 0) || 0;
    const db = Date.parse(b.dateAdded || 0) || 0;
    return db - da;
  });

  return items;
}

async function getByIdForApp(id) {
  const doc = await productsCol().doc(id).get();
  if (!doc.exists) return null;
  const data = doc.data();
  if (data.deletedAt) return null;
  return normalizeProduct({ id: doc.id, ...data });
}

module.exports = { listForApp, getByIdForApp };
