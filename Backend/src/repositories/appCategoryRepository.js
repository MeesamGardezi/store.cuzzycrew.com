const { getDb } = require('../config/firebase');

function categoriesCol() {
  return getDb().collection('categories');
}

function normalizeCategory(doc) {
  return {
    id: String(doc.id || ''),
    name: String(doc.name || ''),
    slug: String(doc.slug || ''),
    thumbnail: String(doc.thumbnail || ''),
    launched: Boolean(doc.launched ?? true),
    description: String(doc.description || ''),
    itemCount: Number.isFinite(Number(doc.itemCount)) ? Number(doc.itemCount) : 0,
    featured: Boolean(doc.featured ?? false),
    sortOrder: Number.isFinite(Number(doc.sortOrder)) ? Number(doc.sortOrder) : 0,
    tags: Array.isArray(doc.tags) ? doc.tags.map((t) => String(t)) : [],
    ...(doc.banner ? { banner: String(doc.banner) } : {}),
  };
}

async function listForApp() {
  const snap = await categoriesCol().where('deletedAt', '==', null).get();
  const items = snap.docs.map((d) => normalizeCategory({ ...d.data(), id: d.id }));

  items.sort((a, b) => {
    const sa = Number.isFinite(Number(a.sortOrder)) ? Number(a.sortOrder) : 9999;
    const sb = Number.isFinite(Number(b.sortOrder)) ? Number(b.sortOrder) : 9999;
    if (sa !== sb) return sa - sb;
    return String(a.name || '').localeCompare(String(b.name || ''));
  });

  return items;
}

module.exports = { listForApp };
