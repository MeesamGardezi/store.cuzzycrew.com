const { getDb } = require('../config/firebase');

function categoriesCol() {
  return getDb().collection('categories');
}

function uniqueCategorySlugDoc(slug) {
  return getDb().collection('uniqueCategorySlugs').doc(slug);
}

async function getById(id) {
  const doc = await categoriesCol().doc(id).get();
  if (!doc.exists) return null;
  return { ...doc.data(), id: doc.id };
}

async function createCategory({ categoryId, data, nowIso }) {
  const db = getDb();
  const slug = data.slug;

  await db.runTransaction(async (tx) => {
    const slugRef = uniqueCategorySlugDoc(slug);
    const slugSnap = await tx.get(slugRef);
    if (slugSnap.exists) {
      const err = new Error('Category slug already exists');
      err.code = 'CATEGORY_SLUG_TAKEN';
      throw err;
    }

    tx.create(slugRef, { categoryId, slug, createdAt: nowIso });
    tx.create(categoriesCol().doc(categoryId), {
      ...data,
      slug,
      deletedAt: null,
      createdAt: nowIso,
      updatedAt: nowIso,
    });
  });

  return getById(categoryId);
}

async function updateCategory({ categoryId, patch, nowIso }) {
  const existing = await getById(categoryId);
  if (!existing) return null;

  const db = getDb();

  await db.runTransaction(async (tx) => {
    if (patch.slug && patch.slug !== existing.slug) {
      const newSlug = patch.slug;
      const newSlugRef = uniqueCategorySlugDoc(newSlug);
      const newSlugSnap = await tx.get(newSlugRef);
      if (newSlugSnap.exists) {
        const err = new Error('Category slug already exists');
        err.code = 'CATEGORY_SLUG_TAKEN';
        throw err;
      }

      tx.delete(uniqueCategorySlugDoc(existing.slug));
      tx.create(newSlugRef, { categoryId, slug: newSlug, createdAt: nowIso });
    }

    tx.set(categoriesCol().doc(categoryId), { ...patch, updatedAt: nowIso }, { merge: true });
  });

  return getById(categoryId);
}

async function softDeleteCategory({ categoryId, nowIso }) {
  const existing = await getById(categoryId);
  if (!existing) return null;
  await categoriesCol().doc(categoryId).set({ deletedAt: nowIso, updatedAt: nowIso }, { merge: true });
  return getById(categoryId);
}

module.exports = { getById, createCategory, updateCategory, softDeleteCategory };
