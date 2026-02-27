const { getDb } = require('../config/firebase');

function cartsCol() {
  return getDb().collection('carts');
}

async function getByUserId(userId) {
  const snap = await cartsCol().where('userId', '==', userId).where('status', '==', 'ACTIVE').limit(1).get();
  if (snap.empty) return null;
  const doc = snap.docs[0];
  return { id: doc.id, ...doc.data() };
}

async function getBySessionToken(sessionToken) {
  const snap = await cartsCol().where('sessionToken', '==', sessionToken).where('status', '==', 'ACTIVE').limit(1).get();
  if (snap.empty) return null;
  const doc = snap.docs[0];
  return { id: doc.id, ...doc.data() };
}

async function create({ cartId, userId, sessionToken, nowIso }) {
  await cartsCol().doc(cartId).create({
    userId: userId || null,
    sessionToken: sessionToken || null,
    status: 'ACTIVE',
    couponCode: null,
    currency: 'usd',
    subtotal: 0,
    discountTotal: 0,
    total: 0,
    createdAt: nowIso,
    updatedAt: nowIso,
  });

  const doc = await cartsCol().doc(cartId).get();
  return { id: doc.id, ...doc.data() };
}

async function updateTotals({ cartId, subtotal, discountTotal, total, couponCode, nowIso }) {
  await cartsCol().doc(cartId).set(
    {
      subtotal,
      discountTotal,
      total,
      couponCode: couponCode || null,
      updatedAt: nowIso,
    },
    { merge: true }
  );
}

async function attachToUser({ cartId, userId, nowIso }) {
  await cartsCol().doc(cartId).set(
    {
      userId,
      sessionToken: null,
      updatedAt: nowIso,
    },
    { merge: true }
  );
}

module.exports = {
  getByUserId,
  getBySessionToken,
  create,
  updateTotals,
  attachToUser,
};
