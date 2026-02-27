const { getDb } = require('../config/firebase');
const { ApiError } = require('../utils/apiError');
const { newId, nowIso, toNumber } = require('../utils/firestore');

const cartRepository = require('../repositories/cartRepository');
const orderRepository = require('../repositories/orderRepository');
const { orderItemsCol, listByOrderId } = require('../repositories/orderItemRepository');

function generateOrderNumber() {
  const t = Date.now().toString(36).toUpperCase();
  const r = Math.random().toString(36).slice(2, 8).toUpperCase();
  return `CC-${t}-${r}`;
}

async function quoteFromUserCart(userId) {
  const cart = await cartRepository.getByUserId(userId);
  if (!cart) throw new ApiError({ status: 422, code: 'CART_EMPTY', message: 'Cart is empty', details: [] });
  return { cart };
}

async function createOrder({ userId, idempotencyKey, shippingAddressId }) {
  const db = getDb();
  const { cart } = await quoteFromUserCart(userId);

  const orderId = newId();
  const createdAt = nowIso();

  const orderNumber = generateOrderNumber();

  const idempotencyRef = orderRepository.uniqueIdempotencyDoc(userId, idempotencyKey);
  const orderNumberRef = orderRepository.uniqueOrderNumberDoc(orderNumber);

  await db.runTransaction(async (tx) => {
    const idemSnap = await tx.get(idempotencyRef);
    if (idemSnap.exists) {
      throw new ApiError({ status: 409, code: 'IDEMPOTENCY_CONFLICT', message: 'Duplicate idempotency key', details: [] });
    }

    const orderNumberSnap = await tx.get(orderNumberRef);
    if (orderNumberSnap.exists) {
      throw new ApiError({ status: 409, code: 'ORDER_NUMBER_CONFLICT', message: 'Order number conflict', details: [] });
    }

    const cartRef = db.collection('carts').doc(cart.id);
    const cartSnap = await tx.get(cartRef);
    if (!cartSnap.exists) {
      throw new ApiError({ status: 422, code: 'CART_EMPTY', message: 'Cart is empty', details: [] });
    }

    const cartData = cartSnap.data();
    if (cartData.status !== 'ACTIVE') {
      throw new ApiError({ status: 422, code: 'CART_EMPTY', message: 'Cart is empty', details: [] });
    }

    const cartItemsQuery = db.collection('cartItems').where('cartId', '==', cart.id);
    const cartItemsSnap = await tx.get(cartItemsQuery);
    if (cartItemsSnap.empty) {
      throw new ApiError({ status: 422, code: 'CART_EMPTY', message: 'Cart is empty', details: [] });
    }

    const cartItems = cartItemsSnap.docs.map((d) => ({ id: d.id, ...d.data(), ref: d.ref }));

    const variantDocs = [];
    const productDocsById = new Map();

    for (const ci of cartItems) {
      const variantRef = db.collection('productVariants').doc(ci.variantId);
      const variantSnap = await tx.get(variantRef);
      if (!variantSnap.exists) {
        throw new ApiError({ status: 409, code: 'STOCK_CONFLICT', message: 'Variant not found', details: [] });
      }
      const variant = { id: variantSnap.id, ...variantSnap.data() };

      const stock = toNumber(variant.stock, 0);
      if (stock < toNumber(ci.quantity)) {
        throw new ApiError({ status: 409, code: 'STOCK_CONFLICT', message: 'Insufficient stock', details: [] });
      }

      variantDocs.push({ ci, variant, variantRef });

      if (variant.productId && !productDocsById.has(variant.productId)) {
        const productRef = db.collection('products').doc(variant.productId);
        const productSnap = await tx.get(productRef);
        if (productSnap.exists) productDocsById.set(variant.productId, { id: productSnap.id, ...productSnap.data() });
      }
    }

    for (const v of variantDocs) {
      const stock = toNumber(v.variant.stock, 0);
      const newStock = stock - toNumber(v.ci.quantity);
      tx.set(v.variantRef, { stock: newStock, updatedAt: createdAt }, { merge: true });
    }

    const orderRef = orderRepository.ordersCol().doc(orderId);

    tx.create(idempotencyRef, { orderId, userId, idempotencyKey, createdAt });
    tx.create(orderNumberRef, { orderId, orderNumber, createdAt });

    tx.create(orderRef, {
      userId,
      orderNumber,
      status: 'PENDING',
      currency: cartData.currency,
      subtotal: cartData.subtotal,
      discountTotal: cartData.discountTotal,
      total: cartData.total,
      couponCode: cartData.couponCode || null,
      shippingAddressId: shippingAddressId || null,
      stripePaymentIntentId: null,
      createdAt,
      updatedAt: createdAt,
      canceledAt: null,
      deletedAt: null,
    });

    for (const v of variantDocs) {
      const product = v.variant.productId ? productDocsById.get(v.variant.productId) : null;

      tx.create(orderItemsCol().doc(newId()), {
        orderId,
        productId: v.ci.productId,
        variantId: v.ci.variantId,
        quantity: v.ci.quantity,
        unitPrice: v.ci.unitPrice,
        currency: v.ci.currency,
        snapshot: {
          productName: v.ci.snapshot?.productName || product?.name || null,
          variantLabel: v.ci.snapshot?.variantLabel || v.variant.label || null,
          unitPrice: v.ci.unitPrice,
        },
        createdAt,
        updatedAt: createdAt,
      });
    }

    for (const doc of cartItems) {
      tx.delete(doc.ref);
    }

    tx.set(
      cartRef,
      { couponCode: null, subtotal: 0, discountTotal: 0, total: 0, updatedAt: createdAt },
      { merge: true }
    );
  });

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

    if (order.status !== 'PENDING') {
      throw new ApiError({ status: 422, code: 'CANNOT_CANCEL', message: 'Order cannot be canceled', details: [] });
    }

    tx.set(ref, { status: 'CANCELED', canceledAt: now, updatedAt: now }, { merge: true });
  });

  return getOrder({ userId, orderId });
}

module.exports = { createOrder, listOrders, getOrder, cancelOrder };
