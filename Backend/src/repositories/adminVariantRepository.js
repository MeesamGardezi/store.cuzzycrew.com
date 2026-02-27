const { getDb } = require('../config/firebase');

function variantsCol() {
  return getDb().collection('productVariants');
}

function uniqueSkuDoc(skuUpper) {
  return getDb().collection('uniqueSkus').doc(skuUpper);
}

async function getById(id) {
  const doc = await variantsCol().doc(id).get();
  if (!doc.exists) return null;
  return { id: doc.id, ...doc.data() };
}

async function updateStock({ variantId, stock, nowIso }) {
  await variantsCol().doc(variantId).set({ stock, updatedAt: nowIso }, { merge: true });
  return getById(variantId);
}

async function createVariant({ variantId, data, nowIso }) {
  const db = getDb();
  const skuUpper = String(data.sku || '').toUpperCase();

  await db.runTransaction(async (tx) => {
    const skuRef = uniqueSkuDoc(skuUpper);
    const skuSnap = await tx.get(skuRef);
    if (skuSnap.exists) {
      const err = new Error('SKU already exists');
      err.code = 'SKU_TAKEN';
      throw err;
    }

    tx.create(skuRef, { variantId, skuUpper, createdAt: nowIso });
    tx.create(variantsCol().doc(variantId), {
      ...data,
      sku: data.sku,
      skuUpper,
      deletedAt: null,
      createdAt: nowIso,
      updatedAt: nowIso,
    });
  });

  return getById(variantId);
}

module.exports = { getById, updateStock, createVariant };
