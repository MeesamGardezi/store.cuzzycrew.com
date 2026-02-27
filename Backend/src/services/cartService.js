const { ApiError } = require('../utils/apiError');
const { newId, nowIso, toNumber } = require('../utils/firestore');

const cartRepository = require('../repositories/cartRepository');
const cartItemRepository = require('../repositories/cartItemRepository');
const productRepository = require('../repositories/productRepository');
const variantRepository = require('../repositories/productVariantRepository');
const couponRepository = require('../repositories/couponRepository');

async function getOrCreateActiveCart({ userId, sessionToken }) {
  let cart = null;

  if (userId) cart = await cartRepository.getByUserId(userId);
  if (!cart && sessionToken) cart = await cartRepository.getBySessionToken(sessionToken);

  if (!cart) {
    cart = await cartRepository.create({
      cartId: newId(),
      userId,
      sessionToken,
      nowIso: nowIso(),
    });
  }

  return cart;
}

async function computeTotals({ cart, items }) {
  const subtotal = items.reduce((sum, i) => sum + toNumber(i.unitPrice) * toNumber(i.quantity), 0);

  let coupon = null;
  if (cart.couponCode) coupon = await couponRepository.getByCode(String(cart.couponCode).toUpperCase());

  let discountTotal = 0;
  if (coupon) {
    validateCoupon({ coupon, subtotal });
    discountTotal = computeDiscount({ coupon, subtotal });
  }

  const total = Math.max(0, subtotal - discountTotal);
  return { subtotal, discountTotal, total, couponCode: coupon ? coupon.codeUpper : null };
}

function validateCoupon({ coupon, subtotal }) {
  const now = new Date();

  if (coupon.expiresAt) {
    const exp = new Date(coupon.expiresAt);
    if (Number.isFinite(exp.getTime()) && exp < now) {
      throw new ApiError({ status: 422, code: 'COUPON_EXPIRED', message: 'Coupon expired', details: [] });
    }
  }

  if (coupon.maxUses != null && coupon.usesCount != null && coupon.usesCount >= coupon.maxUses) {
    throw new ApiError({ status: 422, code: 'COUPON_MAX_USES', message: 'Coupon max uses reached', details: [] });
  }

  if (coupon.minOrderAmount != null && subtotal < coupon.minOrderAmount) {
    throw new ApiError({ status: 422, code: 'COUPON_MIN_ORDER', message: 'Order amount too low for coupon', details: [] });
  }
}

function computeDiscount({ coupon, subtotal }) {
  if (!coupon) return 0;

  if (coupon.type === 'PERCENT') {
    const pct = toNumber(coupon.percentOff, 0);
    return Math.max(0, Math.round((subtotal * pct) / 100));
  }

  if (coupon.type === 'AMOUNT') {
    return Math.max(0, Math.min(subtotal, toNumber(coupon.amountOff, 0)));
  }

  return 0;
}

async function persistRecalc({ cart, items }) {
  const totals = await computeTotals({ cart, items });
  await cartRepository.updateTotals({
    cartId: cart.id,
    subtotal: totals.subtotal,
    discountTotal: totals.discountTotal,
    total: totals.total,
    couponCode: totals.couponCode,
    nowIso: nowIso(),
  });

  const updatedCart = cart.userId
    ? await cartRepository.getByUserId(cart.userId)
    : await cartRepository.getBySessionToken(cart.sessionToken);

  return { cart: updatedCart, items };
}

async function getCart({ userId, sessionToken }) {
  const cart = await getOrCreateActiveCart({ userId, sessionToken });
  const items = await cartItemRepository.listByCartId(cart.id);
  return persistRecalc({ cart, items });
}

async function addItem({ userId, sessionToken, variantId, quantity }) {
  const cart = await getOrCreateActiveCart({ userId, sessionToken });

  const variant = await variantRepository.getById(variantId);
  if (!variant || variant.deletedAt) {
    throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Variant not found', details: [] });
  }

  const existing = await cartItemRepository.findByCartAndVariant(cart.id, variantId);
  const newQty = (existing ? toNumber(existing.quantity) : 0) + toNumber(quantity);

  if (toNumber(variant.stock, 0) < newQty) {
    throw new ApiError({ status: 409, code: 'OUT_OF_STOCK', message: 'Insufficient stock', details: [] });
  }

  const product = await productRepository.getById(variant.productId);
  if (!product) {
    throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Product not found', details: [] });
  }

  const unitPrice = toNumber(variant.price, toNumber(product.price, 0));
  const snapshot = {
    productName: product.name,
    variantLabel: variant.label || null,
    unitPrice,
  };

  if (existing) {
    await cartItemRepository.updateQuantity({ itemId: existing.id, quantity: newQty, nowIso: nowIso() });
  } else {
    await cartItemRepository.create({
      itemId: newId(),
      cartId: cart.id,
      productId: product.id,
      variantId,
      quantity: toNumber(quantity),
      unitPrice,
      currency: cart.currency,
      snapshot,
      nowIso: nowIso(),
    });
  }

  const items = await cartItemRepository.listByCartId(cart.id);
  const refreshedCart = cart.userId
    ? await cartRepository.getByUserId(cart.userId)
    : await cartRepository.getBySessionToken(cart.sessionToken);

  return persistRecalc({ cart: refreshedCart, items });
}

async function updateItem({ userId, sessionToken, itemId, quantity }) {
  const cart = await getOrCreateActiveCart({ userId, sessionToken });

  const item = await cartItemRepository.getById(itemId);
  if (!item || item.cartId !== cart.id) {
    throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Cart item not found', details: [] });
  }

  const variant = await variantRepository.getById(item.variantId);
  if (!variant) {
    throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Variant not found', details: [] });
  }

  if (toNumber(variant.stock, 0) < toNumber(quantity)) {
    throw new ApiError({ status: 409, code: 'OUT_OF_STOCK', message: 'Insufficient stock', details: [] });
  }

  await cartItemRepository.updateQuantity({ itemId, quantity: toNumber(quantity), nowIso: nowIso() });

  const items = await cartItemRepository.listByCartId(cart.id);
  const refreshedCart = cart.userId
    ? await cartRepository.getByUserId(cart.userId)
    : await cartRepository.getBySessionToken(cart.sessionToken);

  return persistRecalc({ cart: refreshedCart, items });
}

async function deleteItem({ userId, sessionToken, itemId }) {
  const cart = await getOrCreateActiveCart({ userId, sessionToken });

  const item = await cartItemRepository.getById(itemId);
  if (!item || item.cartId !== cart.id) {
    throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Cart item not found', details: [] });
  }

  await cartItemRepository.deleteById(itemId);

  const items = await cartItemRepository.listByCartId(cart.id);
  const refreshedCart = cart.userId
    ? await cartRepository.getByUserId(cart.userId)
    : await cartRepository.getBySessionToken(cart.sessionToken);

  return persistRecalc({ cart: refreshedCart, items });
}

async function applyCoupon({ userId, sessionToken, code }) {
  const cart = await getOrCreateActiveCart({ userId, sessionToken });
  const items = await cartItemRepository.listByCartId(cart.id);
  const subtotal = items.reduce((sum, i) => sum + toNumber(i.unitPrice) * toNumber(i.quantity), 0);

  const coupon = await couponRepository.getByCode(code.toUpperCase());
  if (!coupon) {
    throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Coupon not found', details: [] });
  }

  validateCoupon({ coupon, subtotal });
  const discountTotal = computeDiscount({ coupon, subtotal });
  const total = Math.max(0, subtotal - discountTotal);

  await cartRepository.updateTotals({
    cartId: cart.id,
    subtotal,
    discountTotal,
    total,
    couponCode: coupon.codeUpper,
    nowIso: nowIso(),
  });

  const updatedCart = cart.userId
    ? await cartRepository.getByUserId(cart.userId)
    : await cartRepository.getBySessionToken(cart.sessionToken);

  return { cart: updatedCart, items };
}

async function removeCoupon({ userId, sessionToken }) {
  const cart = await getOrCreateActiveCart({ userId, sessionToken });
  const items = await cartItemRepository.listByCartId(cart.id);
  const subtotal = items.reduce((sum, i) => sum + toNumber(i.unitPrice) * toNumber(i.quantity), 0);

  await cartRepository.updateTotals({
    cartId: cart.id,
    subtotal,
    discountTotal: 0,
    total: subtotal,
    couponCode: null,
    nowIso: nowIso(),
  });

  const updatedCart = cart.userId
    ? await cartRepository.getByUserId(cart.userId)
    : await cartRepository.getBySessionToken(cart.sessionToken);

  return { cart: updatedCart, items };
}

async function mergeGuestCartIntoUserCart({ userId, sessionToken }) {
  if (!sessionToken) return;

  const guestCart = await cartRepository.getBySessionToken(sessionToken);
  if (!guestCart) return;

  const userCart = await cartRepository.getByUserId(userId);
  const now = nowIso();

  if (!userCart) {
    await cartRepository.attachToUser({ cartId: guestCart.id, userId, nowIso: now });
    return;
  }

  await cartItemRepository.moveItemsToCart({ fromCartId: guestCart.id, toCartId: userCart.id, nowIso: now });
}

module.exports = {
  getCart,
  addItem,
  updateItem,
  deleteItem,
  applyCoupon,
  removeCoupon,
  mergeGuestCartIntoUserCart,
};
