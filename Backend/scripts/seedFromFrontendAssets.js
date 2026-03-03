const fs = require('fs');
const path = require('path');

const { getConfig } = require('../src/config/env');
const { initFirebase, getDb } = require('../src/config/firebase');

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function chunkArray(arr, chunkSize) {
  const out = [];
  for (let i = 0; i < arr.length; i += chunkSize) out.push(arr.slice(i, i + chunkSize));
  return out;
}

function toCents(price) {
  const n = Number(price);
  if (!Number.isFinite(n)) return 0;
  return Math.round(n * 100);
}

async function run() {
  const config = getConfig();
  initFirebase(config);

  const db = getDb();

  const categoriesPath = path.resolve(__dirname, '../../Frontend/cuzzycrewstore/assets/json/categories.json');
  const productsPath = path.resolve(__dirname, '../../Frontend/cuzzycrewstore/assets/json/products.json');

  const categoriesJson = readJson(categoriesPath);
  const productsJson = readJson(productsPath);

  const categories = Array.isArray(categoriesJson.categories) ? categoriesJson.categories : [];
  const products = Array.isArray(productsJson.products) ? productsJson.products : [];

  const nowIso = new Date().toISOString();

  const categorySlugToId = new Map();
  categories.forEach((c) => {
    if (c && c.slug && c.id) categorySlugToId.set(String(c.slug), String(c.id));
  });

  const catOps = categories.map((c) => {
    const id = String(c.id);
    const data = {
      name: String(c.name || ''),
      slug: String(c.slug || ''),
      thumbnail: String(c.thumbnail || ''),
      launched: Boolean(c.launched ?? false),
      description: String(c.description || ''),
      itemCount: Number.isFinite(Number(c.itemCount)) ? Number(c.itemCount) : 0,
      featured: Boolean(c.featured ?? false),
      sortOrder: Number.isFinite(Number(c.sortOrder)) ? Number(c.sortOrder) : 0,
      tags: Array.isArray(c.tags) ? c.tags.map((t) => String(t)) : [],
      deletedAt: null,
      updatedAt: nowIso,
    };

    if (c.banner) data.banner = String(c.banner);

    return { ref: db.collection('categories').doc(id), data: { ...data, createdAt: String(c.createdAt || nowIso) } };
  });

  const productOps = products.map((p) => {
    const id = String(p.id);
    const categorySlug = String(p.category || '');
    const categoryId = categorySlugToId.get(categorySlug) || null;
    const price = Number.isFinite(Number(p.price)) ? Number(p.price) : 0;
    const priceMin = toCents(price);

    const data = {
      category: categorySlug,
      ...(categoryId ? { categoryId } : {}),

      dateAdded: String(p.dateAdded || nowIso),
      name: String(p.name || ''),
      shortName: String(p.shortName || p.name || ''),
      price,
      priceMin,
      priceMax: priceMin,
      currency: String(p.currency || 'USD'),
      unit: String(p.unit || 'piece'),
      availableUnits: Number.isFinite(Number(p.availableUnits)) ? Number(p.availableUnits) : 0,
      thumbnail: String(p.thumbnail || ''),
      images: Array.isArray(p.images) ? p.images.map((i) => String(i)) : [],
      sizeGuideImage: String(p.sizeGuideImage || ''),
      sizes: Array.isArray(p.sizes) ? p.sizes.map((s) => String(s)) : [],
      story: String(p.story || ''),
      colorVariants: Array.isArray(p.colorVariants)
        ? p.colorVariants.map((v) => ({
            colorName: String(v?.colorName || ''),
            colorHex: String(v?.colorHex || ''),
            image: String(v?.image || ''),
          }))
        : [],

      deletedAt: null,
      createdAt: String(p.dateAdded || nowIso),
      updatedAt: nowIso,
    };

    return { ref: db.collection('products').doc(id), data };
  });

  const ops = [...catOps, ...productOps];
  const chunks = chunkArray(ops, 450);

  for (const chunk of chunks) {
    const batch = db.batch();
    chunk.forEach((op) => batch.set(op.ref, op.data, { merge: true }));
    await batch.commit();
  }

  process.stdout.write(
    JSON.stringify(
      {
        ok: true,
        categories: categories.length,
        products: products.length,
      },
      null,
      2
    ) + '\n'
  );
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
