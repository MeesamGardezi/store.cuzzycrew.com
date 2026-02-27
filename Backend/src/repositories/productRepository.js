const { getDb } = require('../config/firebase');

function productsCol() {
  return getDb().collection('products');
}

async function getBySlug(slug) {
  const snap = await productsCol().where('slug', '==', slug).where('deletedAt', '==', null).limit(1).get();
  if (snap.empty) return null;
  const doc = snap.docs[0];
  return { id: doc.id, ...doc.data() };
}

async function getById(id) {
  const doc = await productsCol().doc(id).get();
  if (!doc.exists) return null;
  const data = doc.data();
  if (data.deletedAt) return null;
  return { id: doc.id, ...data };
}

async function list({
  limit,
  startAfter,
  filters,
  sort,
}) {
  let q = productsCol().where('deletedAt', '==', null);

  if (filters?.categoryId) q = q.where('categoryId', '==', filters.categoryId);
  if (filters?.color) q = q.where('colors', 'array-contains', filters.color);
  if (filters?.size) q = q.where('sizes', 'array-contains', filters.size);

  if (sort === 'price_asc') q = q.orderBy('priceMin', 'asc');
  else if (sort === 'price_desc') q = q.orderBy('priceMin', 'desc');
  else q = q.orderBy('createdAt', 'desc');

  if (filters?.priceMin != null) q = q.where('priceMin', '>=', filters.priceMin);
  if (filters?.priceMax != null) q = q.where('priceMin', '<=', filters.priceMax);

  if (startAfter) {
    const cursorDoc = await productsCol().doc(startAfter).get();
    if (cursorDoc.exists) q = q.startAfter(cursorDoc);
  }

  const snap = await q.limit(limit).get();

  const items = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
  const nextCursor = snap.docs.length ? snap.docs[snap.docs.length - 1].id : null;

  return { items, nextCursor };
}

module.exports = { getBySlug, getById, list };
