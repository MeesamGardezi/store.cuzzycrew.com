const { getDb } = require('../config/firebase');
const { ApiError } = require('../utils/apiError');
const { newId, nowIso } = require('../utils/firestore');

function toMinor(amount) {
  const n = Number(amount);
  if (!Number.isFinite(n)) return 0;
  return Math.round(n * 100);
}

async function createCheckoutSession({ payload, correlationId }) {
  const db = getDb();

  const currency = String(payload.currency || 'USD').toLowerCase();
  const createdAt = nowIso();

  const productIds = [...new Set(payload.items.map((i) => String(i.productId)))];
  const productDocs = await Promise.all(productIds.map((id) => db.collection('products').doc(id).get()));

  const productsById = new Map();
  for (const doc of productDocs) {
    if (doc.exists) productsById.set(doc.id, { id: doc.id, ...doc.data() });
  }

  const computedItems = payload.items.map((i) => {
    const product = productsById.get(String(i.productId));
    if (!product || product.deletedAt) {
      throw new ApiError({ status: 404, code: 'PRODUCT_NOT_FOUND', message: 'Product not found', details: [{ productId: i.productId }] });
    }

    const available = Number(product.availableUnits ?? 0);
    if (Number.isFinite(available) && available < Number(i.quantity)) {
      throw new ApiError({ status: 409, code: 'OUT_OF_STOCK', message: 'Insufficient stock', details: [{ productId: i.productId }] });
    }

    const unitAmount = toMinor(product.price);
    if (!unitAmount || unitAmount < 0) {
      throw new ApiError({ status: 422, code: 'INVALID_PRODUCT_PRICE', message: 'Invalid product price', details: [{ productId: i.productId }] });
    }

    return {
      productId: product.id,
      quantity: Number(i.quantity),
      selectedSize: String(i.selectedSize),
      selectedColor: String(i.selectedColor),
      unitAmount,
      currency,
      snapshot: {
        name: String(product.name || ''),
        thumbnail: String(product.thumbnail || ''),
      },
    };
  });

  const subtotal = computedItems.reduce((sum, it) => sum + it.unitAmount * it.quantity, 0);

  const draftId = newId();
  await db.collection('checkoutDrafts').doc(draftId).create({
    id: draftId,
    currency,
    items: computedItems,
    shippingAddress: payload.shippingAddress,
    subtotal,
    correlationId: correlationId || null,
    status: 'CREATED',
    createdAt,
    updatedAt: createdAt,
  });

  // Stripe template:
  // 1) Build `line_items` from computedItems (never trust client totals)
  // 2) Create Stripe Checkout Session:
  //    const session = await stripe.checkout.sessions.create({
  //      mode: 'payment',
  //      success_url: STRIPE_SUCCESS_URL,
  //      cancel_url: STRIPE_CANCEL_URL,
  //      line_items,
  //      metadata: { draftId },
  //    })
  // 3) Persist session.id to `checkoutDrafts/{draftId}`
  // 4) Return { sessionId: session.id }

  const sessionId = `cs_test_${draftId}`;

  await db.collection('checkoutDrafts').doc(draftId).set(
    {
      stripeSessionId: sessionId,
      status: 'SESSION_TEMPLATE',
      updatedAt: nowIso(),
    },
    { merge: true }
  );

  return { sessionId, draftId };
}

module.exports = { createCheckoutSession };
