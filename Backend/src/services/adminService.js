const { ApiError } = require('../utils/apiError');
const { newId, nowIso } = require('../utils/firestore');
const { logger } = require('../utils/logger');

const auditLogService = require('./auditLogService');
const adminProductRepository = require('../repositories/adminProductRepository');
const adminVariantRepository = require('../repositories/adminVariantRepository');
const adminCategoryRepository = require('../repositories/adminCategoryRepository');
const adminSiteContentRepository = require('../repositories/adminSiteContentRepository');
const adminOrderRepository = require('../repositories/adminOrderRepository');
const adminCouponRepository = require('../repositories/adminCouponRepository');
const orderRepository = require('../repositories/orderRepository');
const { getDb } = require('../config/firebase');
const { getStorageService } = require('./storageService');

function safeFileName(name) {
  return String(name || 'file')
    .replace(/\\/g, '_')
    .replace(/\//g, '_')
    .replace(/\s+/g, '_')
    .replace(/[^a-zA-Z0-9._-]/g, '');
}

function storageKeyForProduct({ productId, kind, originalName }) {
  const fileName = safeFileName(originalName);
  return `products/${productId}/${kind}_${Date.now()}_${fileName}`;
}

function storageKeyForCategory({ categoryId, ext }) {
  return `categories/${categoryId}/thumbnail_${Date.now()}.${ext}`;
}

function imageRefMeta(ref) {
  const value = String(ref || '').trim();
  if (!value) return { present: false, kind: 'empty', length: 0 };
  if (value.startsWith('data:image/')) {
    return { present: true, kind: 'data-uri', length: value.length };
  }
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return { present: true, kind: 'http', length: value.length };
  }
  if (value.startsWith('gs://')) {
    return { present: true, kind: 'gs', length: value.length };
  }
  if (value.startsWith('/')) {
    return { present: true, kind: 'relative', length: value.length };
  }
  return { present: true, kind: 'other', length: value.length };
}

function parseDataImageUri(value) {
  const raw = String(value || '').trim();
  const match = raw.match(/^data:(image\/[a-zA-Z0-9.+-]+);base64,(.+)$/);
  if (!match) return null;

  const contentType = match[1];
  const base64Data = match[2];
  const buffer = Buffer.from(base64Data, 'base64');
  const extByMime = {
    'image/jpeg': 'jpg',
    'image/jpg': 'jpg',
    'image/png': 'png',
    'image/webp': 'webp',
    'image/gif': 'gif',
  };
  const ext = extByMime[contentType] || 'png';
  return { buffer, contentType, ext };
}

function isMissingBucketError(error) {
  const message = String(error?.message || '');
  return message.includes('The specified bucket does not exist');
}

function isMockStorageProvider(storage) {
  return Boolean(storage && storage.constructor && storage.constructor.name === 'MockStorageService');
}

function isMockStorageUrl(value) {
  const normalized = String(value || '').trim();
  return normalized.startsWith('https://mock-storage.local/');
}

function filesSummary(files = {}) {
  return {
    thumbnailCount: Array.isArray(files.thumbnail) ? files.thumbnail.length : 0,
    imagesCount: Array.isArray(files.images) ? files.images.length : 0,
    sizeGuideCount: Array.isArray(files.sizeGuideImage) ? files.sizeGuideImage.length : 0,
  };
}

function normalizeCurrencyCode(value, fallback = 'USD') {
  const normalized = String(value || '').trim().toUpperCase();
  return normalized || fallback;
}

async function uploadIfPresent({ storage, productId, kind, file }) {
  if (!file) return null;
  const key = storageKeyForProduct({ productId, kind, originalName: file.originalname });
  const uploaded = await storage.uploadImage({
    buffer: file.buffer,
    contentType: file.mimetype,
    fileName: file.originalname,
    key,
  });
  return storage.generatePublicUrl({ key: uploaded.key });
}

function dataUriFromFile(file) {
  if (!file || !file.buffer) return null;
  const mime = String(file.mimetype || 'image/png').trim() || 'image/png';
  return `data:${mime};base64,${file.buffer.toString('base64')}`;
}

async function uploadProductImageWithFallback({ storage, productId, kind, file, correlationId }) {
  if (!file) return null;

  if (isMockStorageProvider(storage)) {
    logger.warn(
      {
        correlationId,
        productId,
        action: 'ADMIN_PRODUCT_UPLOAD_FALLBACK',
        kind,
        uploadFallback: 'mock_storage_using_data_uri',
      },
      'admin_product_upload_fallback'
    );

    return dataUriFromFile(file);
  }

  try {
    const uploadedUrl = await uploadIfPresent({ storage, productId, kind, file });

    if (isMockStorageUrl(uploadedUrl)) {
      logger.warn(
        {
          correlationId,
          productId,
          action: 'ADMIN_PRODUCT_UPLOAD_FALLBACK',
          kind,
          uploadFallback: 'mock_storage_url_using_data_uri',
        },
        'admin_product_upload_fallback'
      );

      return dataUriFromFile(file);
    }

    return uploadedUrl;
  } catch (uploadError) {
    if (!isMissingBucketError(uploadError)) {
      throw uploadError;
    }

    logger.warn(
      {
        correlationId,
        productId,
        action: 'ADMIN_PRODUCT_UPLOAD_FALLBACK',
        kind,
        uploadFallback: 'bucket_missing_using_data_uri',
      },
      'admin_product_upload_fallback'
    );

    return dataUriFromFile(file);
  }
}

async function recomputeAvailableUnits({ productId, nowIsoValue }) {
  const db = getDb();
  const snap = await db.collection('productVariants').where('productId', '==', productId).where('deletedAt', '==', null).get();
  const total = snap.docs.reduce((sum, d) => sum + Number(d.data().stock || 0), 0);
  await db.collection('products').doc(productId).set({ availableUnits: total, updatedAt: nowIsoValue }, { merge: true });
  return total;
}

async function createProduct({ actorUserId, payload, files = {}, correlationId }) {
  try {
    const now = nowIso();
    const productId = newId();
    const storage = getStorageService();

    logger.info(
      {
        correlationId,
        actorUserId,
        productId,
        action: 'ADMIN_PRODUCT_CREATE',
        storageProvider: storage && storage.constructor ? storage.constructor.name : 'UnknownStorage',
        files: filesSummary(files),
        payload: {
          name: payload.name,
          slug: payload.slug,
          category: payload.category || null,
          categoryId: payload.categoryId || null,
          thumbnail: imageRefMeta(payload.thumbnail),
          imagesCount: Array.isArray(payload.images) ? payload.images.length : 0,
          sizeGuideImage: imageRefMeta(payload.sizeGuideImage),
        },
      },
      'admin_product_create_started'
    );

    const thumbnailUrl = await uploadProductImageWithFallback({
      storage,
      productId,
      kind: 'thumbnail',
      file: files?.thumbnail?.[0],
      correlationId,
    });

    const sizeGuideUrl = await uploadProductImageWithFallback({
      storage,
      productId,
      kind: 'sizeGuideImage',
      file: files?.sizeGuideImage?.[0],
      correlationId,
    });

    const imagesFiles = Array.isArray(files?.images) ? files.images : [];
    const imageUrls = [];
    for (const f of imagesFiles) {
      const url = await uploadProductImageWithFallback({
        storage,
        productId,
        kind: 'image',
        file: f,
        correlationId,
      });
      if (url) imageUrls.push(url);
    }

    logger.info(
      {
        correlationId,
        productId,
        uploads: {
          thumbnailUploaded: Boolean(thumbnailUrl),
          imagesUploaded: imageUrls.length,
          sizeGuideUploaded: Boolean(sizeGuideUrl),
        },
      },
      'admin_product_create_uploads_done'
    );

    const created = await adminProductRepository.createProduct({
      productId,
      data: {
        name: payload.name,
        slug: payload.slug,
        category: payload.category || null,
        dateAdded: payload.dateAdded || now,
        shortName: payload.shortName || payload.name,
        price: payload.price != null ? payload.price : null,
        currency: normalizeCurrencyCode(payload.currency),
        unit: payload.unit || 'piece',
        availableUnits: payload.availableUnits != null ? payload.availableUnits : 0,
        thumbnail: thumbnailUrl || payload.thumbnail || null,
        images: imageUrls.length ? imageUrls : payload.images || [],
        sizeGuideImage: sizeGuideUrl || payload.sizeGuideImage || null,
        sizes: payload.sizes || [],
        story: payload.story || null,
        colorVariants: payload.colorVariants || [],

        description: payload.description || null,
        categoryId: payload.categoryId || null,
        priceMin: payload.priceMin ?? 0,
        colors: payload.colors || [],
      },
      nowIso: now,
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

    logger.info(
      {
        correlationId,
        actorUserId,
        productId: created.id,
        action: 'ADMIN_PRODUCT_CREATE',
        stored: {
          thumbnail: imageRefMeta(created.thumbnail),
          imagesCount: Array.isArray(created.images) ? created.images.length : 0,
          sizeGuideImage: imageRefMeta(created.sizeGuideImage),
        },
      },
      'admin_product_create_completed'
    );

    return created;
  } catch (e) {
    logger.error(
      {
        correlationId,
        actorUserId,
        action: 'ADMIN_PRODUCT_CREATE',
        err: e,
      },
      'admin_product_create_failed'
    );
    if (e && e.code === 'SLUG_TAKEN') {
      throw new ApiError({ status: 409, code: 'SLUG_TAKEN', message: 'Slug already exists', details: [] });
    }
    throw e;
  }
}

async function updateProduct({ actorUserId, productId, patch, files = {}, correlationId }) {
  const before = await adminProductRepository.getById(productId);
  if (!before) throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Product not found', details: [] });

  try {
    const storage = getStorageService();

    const thumbnailUrl = await uploadProductImageWithFallback({
      storage,
      productId,
      kind: 'thumbnail',
      file: files?.thumbnail?.[0],
      correlationId,
    });

    const sizeGuideUrl = await uploadProductImageWithFallback({
      storage,
      productId,
      kind: 'sizeGuideImage',
      file: files?.sizeGuideImage?.[0],
      correlationId,
    });

    const imagesFiles = Array.isArray(files?.images) ? files.images : [];
    const imageUrls = [];
    for (const f of imagesFiles) {
      const url = await uploadProductImageWithFallback({
        storage,
        productId,
        kind: 'image',
        file: f,
        correlationId,
      });
      if (url) imageUrls.push(url);
    }

    const computedPatch = {
      ...patch,
      ...(thumbnailUrl ? { thumbnail: thumbnailUrl } : {}),
      ...(sizeGuideUrl ? { sizeGuideImage: sizeGuideUrl } : {}),
      ...(imageUrls.length ? { images: imageUrls } : {}),
      ...(Object.prototype.hasOwnProperty.call(patch || {}, 'currency')
        ? { currency: normalizeCurrencyCode(patch.currency) }
        : {}),
    };

    const after = await adminProductRepository.updateProduct({ productId, patch: computedPatch, nowIso: nowIso() });

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

  const now = nowIso();
  const after = await adminVariantRepository.updateStock({ variantId, stock, nowIso: now });

  if (after && after.productId) {
    await recomputeAvailableUnits({ productId: after.productId, nowIsoValue: now });
  }

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

async function listOrders({ limit, cursor, processed }) {
  return adminOrderRepository.list({ limit, startAfter: cursor, processed });
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

async function toggleProcessedOrder({ actorUserId, orderId, correlationId }) {
  const before = await orderRepository.getById(orderId);
  if (!before) throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Order not found', details: [] });

  const after = await adminOrderRepository.toggleProcessed({
    orderId,
    adminUserId: actorUserId,
    nowIso: nowIso(),
  });

  await auditLogService.writeAuditLog({
    actorUserId,
    action: 'ADMIN_ORDER_PROCESSED_TOGGLE',
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

  async function count(colName, filters = []) {
    try {
      let ref = db.collection(colName);
      for (const [field, op, val] of filters) {
        ref = ref.where(field, op, val);
      }
      const snap = await ref.count().get();
      return snap.data().count || 0;
    } catch {
      let ref = db.collection(colName);
      for (const [field, op, val] of filters) {
        ref = ref.where(field, op, val);
      }
      const snap = await ref.get();
      return snap.size;
    }
  }

  const [users, products, orders, payments] = await Promise.all([
    count('users'),
    count('products', [['deletedAt', '==', null]]),
    count('orders', [['deletedAt', '==', null]]),
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
    const now = nowIso();
    const created = await adminVariantRepository.createVariant({
      variantId: newId(),
      data: {
        productId: payload.productId,
        sku: payload.sku,
        label: payload.label,
        price: payload.price,
        stock: payload.stock,
      },
      nowIso: now,
    });

    await recomputeAvailableUnits({ productId: payload.productId, nowIsoValue: now });

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

async function createCategory({ actorUserId, payload, correlationId }) {
  try {
    const now = nowIso();
    const categoryId = payload.id || newId();
    const storage = getStorageService();
    const inputThumbnail = String(payload.thumbnail || '');
    let resolvedThumbnail = inputThumbnail;

    logger.info(
      {
        correlationId,
        actorUserId,
        categoryId,
        action: 'ADMIN_CATEGORY_CREATE',
        payload: {
          name: payload.name,
          slug: payload.slug,
          launched: payload.launched ?? true,
          thumbnail: imageRefMeta(inputThumbnail),
        },
      },
      'admin_category_create_started'
    );

    const parsedDataImage = parseDataImageUri(inputThumbnail);
    if (parsedDataImage) {
      try {
        const key = storageKeyForCategory({ categoryId, ext: parsedDataImage.ext });
        const uploaded = await storage.uploadImage({
          buffer: parsedDataImage.buffer,
          contentType: parsedDataImage.contentType,
          key,
        });
        resolvedThumbnail = storage.generatePublicUrl({ key: uploaded.key });

        logger.info(
          {
            correlationId,
            categoryId,
            action: 'ADMIN_CATEGORY_CREATE',
            upload: {
              uploadedToStorage: true,
              storageProvider:
                storage && storage.constructor ? storage.constructor.name : 'UnknownStorage',
              uploadedKey: uploaded.key,
            },
          },
          'admin_category_thumbnail_uploaded'
        );
      } catch (uploadError) {
        if (!isMissingBucketError(uploadError)) {
          throw uploadError;
        }

        resolvedThumbnail = inputThumbnail;
        logger.warn(
          {
            correlationId,
            categoryId,
            action: 'ADMIN_CATEGORY_CREATE',
            uploadFallback: 'bucket_missing_using_data_uri',
          },
          'admin_category_thumbnail_upload_fallback'
        );
      }
    }

    const created = await adminCategoryRepository.createCategory({
      categoryId,
      data: {
        name: payload.name,
        slug: payload.slug,
        thumbnail: resolvedThumbnail,
        launched: payload.launched ?? true,
        description: payload.description || '',
        itemCount: payload.itemCount ?? 0,
        featured: payload.featured ?? false,
        sortOrder: payload.sortOrder ?? 0,
        tags: payload.tags || [],
        banner: payload.banner || null,
      },
      nowIso: now,
    });

    await auditLogService.writeAuditLog({
      actorUserId,
      action: 'ADMIN_CATEGORY_CREATE',
      entityType: 'category',
      entityId: created.id,
      before: null,
      after: created,
      correlationId,
    });

    logger.info(
      {
        correlationId,
        actorUserId,
        categoryId: created.id,
        action: 'ADMIN_CATEGORY_CREATE',
        stored: {
          thumbnail: imageRefMeta(created.thumbnail),
          launched: created.launched,
        },
      },
      'admin_category_create_completed'
    );

    return created;
  } catch (e) {
    logger.error(
      {
        correlationId,
        actorUserId,
        action: 'ADMIN_CATEGORY_CREATE',
        err: e,
      },
      'admin_category_create_failed'
    );
    if (e && e.code === 'CATEGORY_SLUG_TAKEN') {
      throw new ApiError({ status: 409, code: 'CATEGORY_SLUG_TAKEN', message: 'Category slug already exists', details: [] });
    }
    throw e;
  }
}

async function updateCategory({ actorUserId, categoryId, patch, correlationId }) {
  const before = await adminCategoryRepository.getById(categoryId);
  if (!before) throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Category not found', details: [] });

  try {
    const storage = getStorageService();
    const computedPatch = { ...patch };
    const patchThumbnail = String(computedPatch.thumbnail || '').trim();
    const parsedDataImage = parseDataImageUri(patchThumbnail);
    if (parsedDataImage) {
      try {
        const key = storageKeyForCategory({ categoryId, ext: parsedDataImage.ext });
        const uploaded = await storage.uploadImage({
          buffer: parsedDataImage.buffer,
          contentType: parsedDataImage.contentType,
          key,
        });
        computedPatch.thumbnail = storage.generatePublicUrl({ key: uploaded.key });

        logger.info(
          {
            correlationId,
            categoryId,
            action: 'ADMIN_CATEGORY_UPDATE',
            upload: {
              uploadedToStorage: true,
              storageProvider:
                storage && storage.constructor ? storage.constructor.name : 'UnknownStorage',
              uploadedKey: uploaded.key,
            },
          },
          'admin_category_thumbnail_uploaded'
        );
      } catch (uploadError) {
        if (!isMissingBucketError(uploadError)) {
          throw uploadError;
        }

        computedPatch.thumbnail = patchThumbnail;
        logger.warn(
          {
            correlationId,
            categoryId,
            action: 'ADMIN_CATEGORY_UPDATE',
            uploadFallback: 'bucket_missing_using_data_uri',
          },
          'admin_category_thumbnail_upload_fallback'
        );
      }
    }

    logger.info(
      {
        correlationId,
        actorUserId,
        categoryId,
        action: 'ADMIN_CATEGORY_UPDATE',
        patch: {
          keys: Object.keys(computedPatch),
          thumbnail: imageRefMeta(computedPatch.thumbnail),
        },
      },
      'admin_category_update_started'
    );

    const after = await adminCategoryRepository.updateCategory({ categoryId, patch: computedPatch, nowIso: nowIso() });

    await auditLogService.writeAuditLog({
      actorUserId,
      action: 'ADMIN_CATEGORY_UPDATE',
      entityType: 'category',
      entityId: categoryId,
      before,
      after,
      correlationId,
    });

    logger.info(
      {
        correlationId,
        actorUserId,
        categoryId,
        action: 'ADMIN_CATEGORY_UPDATE',
        stored: {
          thumbnail: imageRefMeta(after.thumbnail),
          launched: after.launched,
        },
      },
      'admin_category_update_completed'
    );

    return after;
  } catch (e) {
    logger.error(
      {
        correlationId,
        actorUserId,
        categoryId,
        action: 'ADMIN_CATEGORY_UPDATE',
        err: e,
      },
      'admin_category_update_failed'
    );
    if (e && e.code === 'CATEGORY_SLUG_TAKEN') {
      throw new ApiError({ status: 409, code: 'CATEGORY_SLUG_TAKEN', message: 'Category slug already exists', details: [] });
    }
    throw e;
  }
}

async function deleteCategory({ actorUserId, categoryId, correlationId }) {
  const before = await adminCategoryRepository.getById(categoryId);
  if (!before) throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Category not found', details: [] });

  const after = await adminCategoryRepository.softDeleteCategory({ categoryId, nowIso: nowIso() });

  await auditLogService.writeAuditLog({
    actorUserId,
    action: 'ADMIN_CATEGORY_DELETE',
    entityType: 'category',
    entityId: categoryId,
    before,
    after,
    correlationId,
  });

  return after;
}

async function setWebsiteBanner({ actorUserId, images, correlationId }) {
  const before = await adminSiteContentRepository.getWebsiteBanner();
  const after = await adminSiteContentRepository.setWebsiteBanner({ images, nowIso: nowIso() });

  await auditLogService.writeAuditLog({
    actorUserId,
    action: 'ADMIN_WEBSITE_BANNER_SET',
    entityType: 'siteContent',
    entityId: 'websiteBanner',
    before,
    after,
    correlationId,
  });

  return after;
}

module.exports = {
  createProduct,
  updateProduct,
  deleteProduct,
  updateVariantStock,
  createVariant,
  createCategory,
  updateCategory,
  deleteCategory,
  setWebsiteBanner,
  listOrders,
  updateOrderStatus,
  toggleProcessedOrder,
  createCoupon,
  dashboard,
};
