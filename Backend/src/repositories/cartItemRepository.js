const { getDb } = require('../config/firebase');

function cartItemsCol() {
  return getDb().collection('cartItems');
}

async function listByCartId(cartId) {
  const snap = await cartItemsCol().where('cartId', '==', cartId).orderBy('createdAt', 'asc').get();
  return snap.docs.map((d) => ({ id: d.id, ...d.data() }));
}

async function getById(itemId) {
  const doc = await cartItemsCol().doc(itemId).get();
  if (!doc.exists) return null;
  return { id: doc.id, ...doc.data() };
}

async function findByCartAndVariant(cartId, variantId) {
  const snap = await cartItemsCol().where('cartId', '==', cartId).where('variantId', '==', variantId).limit(1).get();
  if (snap.empty) return null;
  const doc = snap.docs[0];
  return { id: doc.id, ...doc.data() };
}

async function create({ itemId, cartId, productId, variantId, quantity, unitPrice, currency, snapshot, nowIso }) {
  await cartItemsCol().doc(itemId).create({
    cartId,
    productId,
    variantId,
    quantity,
    unitPrice,
    currency,
    snapshot,
    createdAt: nowIso,
    updatedAt: nowIso,
  });
}

async function updateQuantity({ itemId, quantity, nowIso }) {
  await cartItemsCol().doc(itemId).set({ quantity, updatedAt: nowIso }, { merge: true });
}

async function deleteById(itemId) {
  await cartItemsCol().doc(itemId).delete();
}

async function moveItemsToCart({ fromCartId, toCartId, nowIso }) {
  const items = await listByCartId(fromCartId);
  const db = getDb();

  await db.runTransaction(async (tx) => {
    for (const item of items) {
      const ref = cartItemsCol().doc(item.id);
      tx.set(ref, { cartId: toCartId, updatedAt: nowIso }, { merge: true });
    }
  });
}

module.exports = {
  listByCartId,
  getById,
  findByCartAndVariant,
  create,
  updateQuantity,
  deleteById,
  moveItemsToCart,
};
