const { getDb } = require('../config/firebase');
const { ApiError } = require('../utils/apiError');
const { newId, nowIso, toNumber } = require('../utils/firestore');

const orderRepository = require('../repositories/orderRepository');
const { orderItemsCol, listByOrderId } = require('../repositories/orderItemRepository');

function generateOrderNumber() {
  const t = Date.now().toString(36).toUpperCase();
  const r = Math.random().toString(36).slice(2, 8).toUpperCase();
  return `CC-${t}-${r}`;
}

function toMinorAmount(amount) {
  const n = Number(amount);
  if (!Number.isFinite(n)) return null;
  return Math.round(n * 100);
}

function getProductUnitPriceMinor(product) {
  const fromPrice = toMinorAmount(product.price);
  if (fromPrice != null) return fromPrice;

  const priceMin = Number(product.priceMin);
  if (Number.isFinite(priceMin)) return Math.round(priceMin);

  return null;
}

async function createOrder({ userId, idempotencyKey, items, currency, shippingAddress }) {
  const db = getDb();
  const createdAt = nowIso();
  const orderId = newId();

  const orderNumber = generateOrderNumber();

  const idemKey = idempotencyKey ? String(idempotencyKey) : null;
  const idempotencyRef = idemKey ? orderRepository.uniqueIdempotencyDoc(userId, idemKey) : null;
  const orderNumberRef = orderRepository.uniqueOrderNumberDoc(orderNumber);

  try {
    await db.runTransaction(async (tx) => {
      if (idempotencyRef) {
        const idemSnap = await tx.get(idempotencyRef);
        if (idemSnap.exists) {
          throw new ApiError({ status: 409, code: 'IDEMPOTENCY_CONFLICT', message: 'Duplicate idempotency key', details: [] });
        }
      }

      const orderNumberSnap = await tx.get(orderNumberRef);
      if (orderNumberSnap.exists) {
        throw new ApiError({ status: 409, code: 'ORDER_NUMBER_CONFLICT', message: 'Order number conflict', details: [] });
      }

    if (!Array.isArray(items) || items.length === 0) {
      throw new ApiError({ status: 422, code: 'EMPTY_ITEMS', message: 'Order items required', details: [] });
    }

    const orderCurrency = String(currency || 'USD').toUpperCase();

    const computedItems = [];

    for (const it of items) {
      const productId = String(it.productId || '');
      const qty = toNumber(it.quantity, 0);
      if (!productId) {
        throw new ApiError({ status: 422, code: 'INVALID_ITEM', message: 'Invalid item productId', details: [] });
      }
      if (qty < 1) {
        throw new ApiError({ status: 422, code: 'INVALID_ITEM', message: 'Invalid item quantity', details: [{ productId }] });
      }

      const productRef = db.collection('products').doc(productId);
      const productSnap = await tx.get(productRef);
      if (!productSnap.exists) {
        throw new ApiError({ status: 404, code: 'PRODUCT_NOT_FOUND', message: 'Product not found', details: [{ productId }] });
      }

      const product = { id: productSnap.id, ...productSnap.data() };
      if (product.deletedAt) {
        throw new ApiError({ status: 404, code: 'PRODUCT_NOT_FOUND', message: 'Product not found', details: [{ productId }] });
      }

      const unitPrice = getProductUnitPriceMinor(product);
      if (unitPrice == null) {
        throw new ApiError({ status: 422, code: 'INVALID_PRODUCT_PRICE', message: 'Invalid product price', details: [{ productId }] });
      }

      const available = toNumber(product.availableUnits, 0);
      if (available < qty) {
        throw new ApiError({ status: 409, code: 'OUT_OF_STOCK', message: 'Insufficient stock', details: [{ productId }] });
      }

      tx.set(productRef, { availableUnits: available - qty, updatedAt: createdAt }, { merge: true });

      computedItems.push({
        productId,
        quantity: qty,
        selectedSize: String(it.selectedSize || ''),
        selectedColor: String(it.selectedColor || ''),
        unitPrice,
        currency: orderCurrency,
        snapshot: {
          productName: product.name || null,
          thumbnail: product.thumbnail || null,
        },
      });
    }

    const subtotal = computedItems.reduce((sum, i) => sum + toNumber(i.unitPrice) * toNumber(i.quantity), 0);
    const discountTotal = 0;
    const total = Math.max(0, subtotal - discountTotal);

    const orderRef = orderRepository.ordersCol().doc(orderId);

    if (idempotencyRef) {
      tx.create(idempotencyRef, { orderId, userId: userId || null, idempotencyKey: idemKey, createdAt });
    }
    tx.create(orderNumberRef, { orderId, orderNumber, createdAt });

    tx.create(orderRef, {
      userId: userId || null,
      orderNumber,
      status: 'PENDING_PAYMENT',
      currency: orderCurrency,
      subtotal,
      discountTotal,
      total,
      couponCode: null,
      shippingAddress: shippingAddress || null,
      stripePaymentIntentId: null,
      createdAt,
      updatedAt: createdAt,
      canceledAt: null,
      deletedAt: null,
    });

      for (const ci of computedItems) {
        tx.create(orderItemsCol().doc(newId()), {
          orderId,
          productId: ci.productId,
          variantId: null,
          quantity: ci.quantity,
          unitPrice: ci.unitPrice,
          currency: ci.currency,
          selectedSize: ci.selectedSize,
          selectedColor: ci.selectedColor,
          snapshot: {
            productName: ci.snapshot?.productName || null,
            thumbnail: ci.snapshot?.thumbnail || null,
            unitPrice: ci.unitPrice,
          },
          createdAt,
          updatedAt: createdAt,
        });
      }
    });
  } catch (e) {
    if (e instanceof ApiError) throw e;
    throw new ApiError({
      status: 500,
      code: 'ORDER_CREATE_FAILED',
      message: e && e.message ? String(e.message) : 'Order create failed',
      details: [],
    });
  }

  const order = await orderRepository.getById(orderId);
  const orderItems = await listByOrderId(orderId);
  return { order, items: orderItems };
}

async function listOrders({ userId, limit, cursor }) {
  return orderRepository.listByUserId(userId, { limit, startAfter: cursor });
}

async function getOrder({ userId, orderId }) {
  const order = await orderRepository.getById(orderId);
  if (!order || order.deletedAt) throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Order not found', details: [] });
  if (order.userId !== userId) throw new ApiError({ status: 403, code: 'FORBIDDEN', message: 'Forbidden', details: [] });
  const items = await listByOrderId(orderId);
  return { order, items };
}

async function cancelOrder({ userId, orderId }) {
  const db = getDb();
  const now = nowIso();

  await db.runTransaction(async (tx) => {
    const ref = orderRepository.ordersCol().doc(orderId);
    const snap = await tx.get(ref);
    if (!snap.exists) {
      throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Order not found', details: [] });
    }

    const order = { id: snap.id, ...snap.data() };
    if (order.userId !== userId) {
      throw new ApiError({ status: 403, code: 'FORBIDDEN', message: 'Forbidden', details: [] });
    }

    if (order.status !== 'PENDING_PAYMENT') {
      throw new ApiError({ status: 422, code: 'CANNOT_CANCEL', message: 'Order cannot be canceled', details: [] });
    }

    tx.set(ref, { status: 'CANCELED', canceledAt: now, updatedAt: now }, { merge: true });
  });

  return getOrder({ userId, orderId });
}

module.exports = { createOrder, listOrders, getOrder, cancelOrder };
