const { getDb } = require('../config/firebase');
const { normalizeOrderStatus } = require('../utils/orderState');
const { listByOrderId } = require('./orderItemRepository');
const adminProductRepository = require('./adminProductRepository');

function normalizeHex(value) {
  const raw = String(value || '').trim().toLowerCase();
  return raw.startsWith('#') ? raw : raw ? `#${raw}` : '';
}

function normalizeLegacyItems(value) {
  if (!Array.isArray(value)) return [];
  return value
    .filter((item) => item && typeof item === 'object')
    .map((item) => ({ ...item }));
}

async function enrichOrderItems(orderId, orderData = {}) {
  const collectionItems = await listByOrderId(orderId);
  const items =
    collectionItems.length > 0
      ? collectionItems
      : normalizeLegacyItems(orderData.items);
  const productCache = new Map();

  return Promise.all(
    items.map(async (item) => {
      const productId = String(item.productId || '');
      let product = null;

      if (productId) {
        if (productCache.has(productId)) {
          product = productCache.get(productId);
        } else {
          product = await adminProductRepository.getById(productId);
          productCache.set(productId, product);
        }
      }

      const selectedColor = normalizeHex(item.selectedColor);
      let colorName = null;
      let colorHex = null;

      if (product && Array.isArray(product.colorVariants) && selectedColor) {
        const variant = product.colorVariants.find((entry) => {
          const variantHex = normalizeHex(entry?.colorHex);
          const variantName = String(entry?.colorName || '').trim().toLowerCase();
          return variantHex === selectedColor || variantName === String(item.selectedColor || '').trim().toLowerCase();
        });

        if (variant) {
          colorName = String(variant.colorName || '').trim() || null;
          colorHex = normalizeHex(variant.colorHex) || null;
        }
      }

      return {
        ...item,
        productName: product?.name || item?.snapshot?.productName || null,
        colorName,
        colorHex,
      };
    })
  );
}

function ordersCol() {
  return getDb().collection('orders');
}

async function list({
  limit = 50,
  startAfter = null,
  processed = null,
  paidOnly = true,
} = {}) {
  // Primary query path (best performance when Firestore composite indexes exist).
  try {
    let q = ordersCol();

    if (paidOnly) {
      q = q.where('status', '==', 'PAID');
    }

    if (typeof processed === 'boolean') {
      q = q.where('processed', '==', processed);
    }

    q = q.orderBy('createdAt', 'desc');

    if (startAfter) {
      const cursor = await ordersCol().doc(startAfter).get();
      if (cursor.exists) q = q.startAfter(cursor);
    }

    const snap = await q.limit(limit).get();
    const items = await Promise.all(
      snap.docs.map(async (d) => {
        const orderData = d.data() || {};
        return {
          id: d.id,
          ...orderData,
          items: await enrichOrderItems(d.id, orderData),
        };
      })
    );
    const nextCursor = snap.docs.length ? snap.docs[snap.docs.length - 1].id : null;
    return { items, nextCursor };
  } catch (error) {
    // Fallback for environments where composite index is not provisioned yet.
    // Keep endpoint working by filtering `processed` and `paidOnly` in-memory.
    const message = String(error?.message || '');
    const isIndexIssue =
      message.includes('FAILED_PRECONDITION') ||
      message.includes('requires an index') ||
      message.includes('The query requires an index');

    if (!isIndexIssue) {
      throw error;
    }

    let q = ordersCol().orderBy('createdAt', 'desc');

    if (startAfter) {
      const cursor = await ordersCol().doc(startAfter).get();
      if (cursor.exists) q = q.startAfter(cursor);
    }

    const snap = await q.limit(Math.max(limit * 3, limit)).get();
    let items = await Promise.all(
      snap.docs.map(async (d) => {
        const orderData = d.data() || {};
        return {
          id: d.id,
          ...orderData,
          items: await enrichOrderItems(d.id, orderData),
        };
      })
    );

    if (paidOnly) {
      items = items.filter((item) => String(item.status || '').toUpperCase() === 'PAID');
    }

    if (typeof processed === 'boolean') {
      items = items.filter((item) => Boolean(item.processed) === processed);
    }

    items = items.slice(0, limit);
    const nextCursor = snap.docs.length ? snap.docs[snap.docs.length - 1].id : null;
    return { items, nextCursor };
  }
}

async function updateStatus({ orderId, status, nowIso }) {
  const normalizedStatus = normalizeOrderStatus(status);
  await ordersCol().doc(orderId).set({ status: normalizedStatus, updatedAt: nowIso }, { merge: true });
  const doc = await ordersCol().doc(orderId).get();
  if (!doc.exists) return null;
  return { id: doc.id, ...doc.data() };
}

async function toggleProcessed({ orderId, adminUserId, nowIso }) {
  const ref = ordersCol().doc(orderId);

  return getDb().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) return null;

    const current = Boolean(snap.data().processed);
    const next = !current;
    const updates = {
      processed: next,
      processedAt: next ? nowIso : null,
      processedBy: next ? adminUserId : null,
      updatedAt: nowIso,
    };

    tx.set(ref, updates, { merge: true });
    return { id: snap.id, ...snap.data(), ...updates };
  });
}

module.exports = { list, updateStatus, toggleProcessed };
