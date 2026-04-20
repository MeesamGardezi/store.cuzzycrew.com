const { getDb } = require('../config/firebase');

function productsCol() {
  return getDb().collection('products');
}

function uniqueSlugDoc(slug) {
  return getDb().collection('uniqueProductSlugs').doc(slug);
}

async function getById(id) {
  const doc = await productsCol().doc(id).get();
  if (!doc.exists) return null;
  return { ...doc.data(), id: doc.id };
}

async function createProduct({ productId, data, nowIso }) {
  const db = getDb();
  const slug = data.slug;

  await db.runTransaction(async (tx) => {
    const slugRef = uniqueSlugDoc(slug);
    const slugSnap = await tx.get(slugRef);
    if (slugSnap.exists) {
      const err = new Error('Slug already exists');
      err.code = 'SLUG_TAKEN';
      throw err;
    }

    tx.create(slugRef, { productId, slug, createdAt: nowIso });
    tx.create(productsCol().doc(productId), {
      ...data,
      slug,
      deletedAt: null,
      createdAt: nowIso,
      updatedAt: nowIso,
    });
  });

  return getById(productId);
}

async function updateProduct({ productId, patch, nowIso }) {
  const existing = await getById(productId);
  if (!existing) return null;

  const db = getDb();

  await db.runTransaction(async (tx) => {
    if (patch.slug && patch.slug !== existing.slug) {
      const newSlug = patch.slug;
      const newSlugRef = uniqueSlugDoc(newSlug);
      const newSlugSnap = await tx.get(newSlugRef);
      if (newSlugSnap.exists) {
        const err = new Error('Slug already exists');
        err.code = 'SLUG_TAKEN';
        throw err;
      }

      tx.delete(uniqueSlugDoc(existing.slug));
      tx.create(newSlugRef, { productId, slug: newSlug, createdAt: nowIso });
    }

    tx.set(productsCol().doc(productId), { ...patch, updatedAt: nowIso }, { merge: true });
  });

  return getById(productId);
}

async function softDeleteProduct({ productId, nowIso }) {
  const existing = await getById(productId);
  if (!existing) return null;

  await productsCol().doc(productId).set({ deletedAt: nowIso, updatedAt: nowIso }, { merge: true });
  return getById(productId);
}

module.exports = { getById, createProduct, updateProduct, softDeleteProduct };
