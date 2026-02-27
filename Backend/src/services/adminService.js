const { ApiError } = require('../utils/apiError');
const { newId, nowIso } = require('../utils/firestore');

const auditLogService = require('./auditLogService');
const adminProductRepository = require('../repositories/adminProductRepository');
const adminVariantRepository = require('../repositories/adminVariantRepository');
const adminOrderRepository = require('../repositories/adminOrderRepository');
const adminCouponRepository = require('../repositories/adminCouponRepository');
const orderRepository = require('../repositories/orderRepository');
const { getDb } = require('../config/firebase');

async function createProduct({ actorUserId, payload, correlationId }) {
  try {
    const created = await adminProductRepository.createProduct({
      productId: newId(),
      data: {
        name: payload.name,
        slug: payload.slug,
        description: payload.description || null,
        categoryId: payload.categoryId || null,
        priceMin: payload.priceMin ?? 0,
        colors: payload.colors || [],
        sizes: payload.sizes || [],
      },
      nowIso: nowIso(),
    });

    await auditLogService.writeAuditLog({
      actorUserId,
      action: 'ADMIN_PRODUCT_CREATE',
      entityType: 'product',
      entityId: created.id,
      before: null,
      after: created,
      correlationId,
    });

    return created;
  } catch (e) {
    if (e && e.code === 'SLUG_TAKEN') {
      throw new ApiError({ status: 409, code: 'SLUG_TAKEN', message: 'Slug already exists', details: [] });
    }
    throw e;
  }
}

async function updateProduct({ actorUserId, productId, patch, correlationId }) {
  const before = await adminProductRepository.getById(productId);
  if (!before) throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Product not found', details: [] });

  try {
    const after = await adminProductRepository.updateProduct({ productId, patch, nowIso: nowIso() });

    await auditLogService.writeAuditLog({
      actorUserId,
      action: 'ADMIN_PRODUCT_UPDATE',
      entityType: 'product',
      entityId: productId,
      before,
      after,
      correlationId,
    });

    return after;
  } catch (e) {
    if (e && e.code === 'SLUG_TAKEN') {
      throw new ApiError({ status: 409, code: 'SLUG_TAKEN', message: 'Slug already exists', details: [] });
    }
    throw e;
  }
}

async function deleteProduct({ actorUserId, productId, correlationId }) {
  const before = await adminProductRepository.getById(productId);
  if (!before) throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Product not found', details: [] });

  const after = await adminProductRepository.softDeleteProduct({ productId, nowIso: nowIso() });

  await auditLogService.writeAuditLog({
    actorUserId,
    action: 'ADMIN_PRODUCT_DELETE',
    entityType: 'product',
    entityId: productId,
    before,
    after,
    correlationId,
  });

  return after;
}

async function updateVariantStock({ actorUserId, variantId, stock, correlationId }) {
  const before = await adminVariantRepository.getById(variantId);
  if (!before) throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Variant not found', details: [] });

  const after = await adminVariantRepository.updateStock({ variantId, stock, nowIso: nowIso() });

  await auditLogService.writeAuditLog({
    actorUserId,
    action: 'ADMIN_VARIANT_STOCK_UPDATE',
    entityType: 'productVariant',
    entityId: variantId,
    before,
    after,
    correlationId,
  });

  return after;
}

async function listOrders({ limit, cursor }) {
  return adminOrderRepository.list({ limit, startAfter: cursor });
}

async function updateOrderStatus({ actorUserId, orderId, status, correlationId }) {
  const before = await orderRepository.getById(orderId);
  if (!before) throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Order not found', details: [] });

  const after = await adminOrderRepository.updateStatus({ orderId, status, nowIso: nowIso() });

  await auditLogService.writeAuditLog({
    actorUserId,
    action: 'ADMIN_ORDER_STATUS_UPDATE',
    entityType: 'order',
    entityId: orderId,
    before,
    after,
    correlationId,
  });

  return after;
}

async function createCoupon({ actorUserId, payload, correlationId }) {
  try {
    const created = await adminCouponRepository.createCoupon({
      couponId: newId(),
      data: {
        code: payload.code,
        type: payload.type,
        percentOff: payload.percentOff ?? null,
        amountOff: payload.amountOff ?? null,
        expiresAt: payload.expiresAt ?? null,
        maxUses: payload.maxUses ?? null,
        minOrderAmount: payload.minOrderAmount ?? null,
      },
      nowIso: nowIso(),
    });

    await auditLogService.writeAuditLog({
      actorUserId,
      action: 'ADMIN_COUPON_CREATE',
      entityType: 'coupon',
      entityId: created.id,
      before: null,
      after: created,
      correlationId,
    });

    return created;
  } catch (e) {
    if (e && e.code === 'COUPON_TAKEN') {
      throw new ApiError({ status: 409, code: 'COUPON_TAKEN', message: 'Coupon code already exists', details: [] });
    }
    throw e;
  }
}

async function dashboard() {
  const db = getDb();

  async function count(colName) {
    try {
      const snap = await db.collection(colName).count().get();
      return snap.data().count || 0;
    } catch {
      const snap = await db.collection(colName).get();
      return snap.size;
    }
  }

  const [users, products, orders, payments] = await Promise.all([
    count('users'),
    count('products'),
    count('orders'),
    count('payments'),
  ]);

  return { counts: { users, products, orders, payments } };
}

async function createVariant({ actorUserId, payload, correlationId }) {
  const product = await adminProductRepository.getById(payload.productId);
  if (!product || product.deletedAt) {
    throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Product not found', details: [] });
  }

  try {
    const created = await adminVariantRepository.createVariant({
      variantId: newId(),
      data: {
        productId: payload.productId,
        sku: payload.sku,
        label: payload.label,
        price: payload.price,
        stock: payload.stock,
      },
      nowIso: nowIso(),
    });

    await auditLogService.writeAuditLog({
      actorUserId,
      action: 'ADMIN_VARIANT_CREATE',
      entityType: 'productVariant',
      entityId: created.id,
      before: null,
      after: created,
      correlationId,
    });

    return created;
  } catch (e) {
    if (e && e.code === 'SKU_TAKEN') {
      throw new ApiError({ status: 409, code: 'SKU_TAKEN', message: 'SKU already exists', details: [] });
    }
    throw e;
  }
}

module.exports = {
  createProduct,
  updateProduct,
  deleteProduct,
  updateVariantStock,
  createVariant,
  listOrders,
  updateOrderStatus,
  createCoupon,
  dashboard,
};
