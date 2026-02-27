const { getDb } = require('../config/firebase');

function ordersCol() {
  return getDb().collection('orders');
}

async function list({ limit = 50, startAfter = null } = {}) {
  let q = ordersCol().orderBy('createdAt', 'desc');

  if (startAfter) {
    const cursor = await ordersCol().doc(startAfter).get();
    if (cursor.exists) q = q.startAfter(cursor);
  }

  const snap = await q.limit(limit).get();
  const items = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
  const nextCursor = snap.docs.length ? snap.docs[snap.docs.length - 1].id : null;
  return { items, nextCursor };
}

async function updateStatus({ orderId, status, nowIso }) {
  await ordersCol().doc(orderId).set({ status, updatedAt: nowIso }, { merge: true });
  const doc = await ordersCol().doc(orderId).get();
  if (!doc.exists) return null;
  return { id: doc.id, ...doc.data() };
}

module.exports = { list, updateStatus };
