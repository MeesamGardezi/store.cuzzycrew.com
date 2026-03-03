const { getDb } = require('../config/firebase');

function productsCol() {
  return getDb().collection('products');
}

function categoriesCol() {
  return getDb().collection('categories');
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

function normalizePrice(doc) {
  if (doc.price != null && Number.isFinite(Number(doc.price))) return Number(doc.price);

  if (doc.priceMin != null && Number.isFinite(Number(doc.priceMin))) {
    return Number(doc.priceMin) / 100;
  }

  return 0.0;
}

function normalizeProduct(doc, { categorySlug } = {}) {
  return {
    id: String(doc.id || ''),
    category: String(categorySlug || doc.category || 'uncategorized'),
    dateAdded: safeIso(doc.dateAdded) || safeIso(doc.createdAt) || new Date(0).toISOString(),
    name: String(doc.name || ''),
    shortName: String(doc.shortName || doc.name || ''),
    price: normalizePrice(doc),
    currency: String(doc.currency || 'USD'),
    unit: String(doc.unit || 'piece'),
    availableUnits: Number.isFinite(Number(doc.availableUnits)) ? Number(doc.availableUnits) : 0,
    thumbnail: String(doc.thumbnail || ''),
    images: Array.isArray(doc.images) ? doc.images.map((i) => String(i)) : [],
    sizeGuideImage: String(doc.sizeGuideImage || ''),
    sizes: Array.isArray(doc.sizes) ? doc.sizes.map((s) => String(s)) : [],
    story: String(doc.story || ''),
    colorVariants: normalizeColorVariants(doc.colorVariants),
  };
}

async function buildCategoryIdToSlugMap() {
  const snap = await categoriesCol().where('deletedAt', '==', null).get();
  const map = new Map();
  snap.docs.forEach((d) => {
    const data = d.data() || {};
    const slug = data.slug ? String(data.slug) : '';
    if (slug) map.set(d.id, slug);
  });
  return map;
}

async function listForApp({ category } = {}) {
  const categoryIdToSlug = await buildCategoryIdToSlugMap();
  let q = productsCol().where('deletedAt', '==', null);
  if (category) q = q.where('category', '==', category);

  const snap = await q.get();
  const items = snap.docs.map((d) => {
    const data = d.data() || {};
    const categorySlug = data.categoryId ? categoryIdToSlug.get(String(data.categoryId)) : null;
    return normalizeProduct({ id: d.id, ...data }, { categorySlug });
  });

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

  let categorySlug = null;
  if (data.categoryId) {
    const catDoc = await categoriesCol().doc(String(data.categoryId)).get();
    if (catDoc.exists) {
      const catData = catDoc.data() || {};
      if (catData.slug) categorySlug = String(catData.slug);
    }
  }

  return normalizeProduct({ id: doc.id, ...data }, { categorySlug });
}

module.exports = { listForApp, getByIdForApp };
