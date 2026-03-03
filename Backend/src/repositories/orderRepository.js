const { getDb } = require('../config/firebase');

function ordersCol() {
  return getDb().collection('orders');
}

function uniqueOrderNumberDoc(orderNumber) {
  return getDb().collection('uniqueOrderNumbers').doc(orderNumber);
}

function uniqueIdempotencyDoc(userId, idempotencyKey) {
  const uid = userId ? String(userId) : 'guest';
  return getDb().collection('uniqueOrderIdempotencyKeys').doc(`${uid}_${idempotencyKey}`);
}

async function getById(orderId) {
  const doc = await ordersCol().doc(orderId).get();
  if (!doc.exists) return null;
  return { id: doc.id, ...doc.data() };
}

async function listByUserId(userId, { limit = 20, startAfter = null } = {}) {
  let q = ordersCol().where('userId', '==', userId).orderBy('createdAt', 'desc');

  if (startAfter) {
    const cursorDoc = await ordersCol().doc(startAfter).get();
    if (cursorDoc.exists) q = q.startAfter(cursorDoc);
  }

  const snap = await q.limit(limit).get();
  const items = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
  const nextCursor = snap.docs.length ? snap.docs[snap.docs.length - 1].id : null;
  return { items, nextCursor };
}

module.exports = {
  ordersCol,
  uniqueOrderNumberDoc,
  uniqueIdempotencyDoc,
  getById,
  listByUserId,
};
