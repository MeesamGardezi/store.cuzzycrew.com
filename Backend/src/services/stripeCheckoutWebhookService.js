const { getDb } = require('../config/firebase');
const { ApiError } = require('../utils/apiError');
const { newId, nowIso } = require('../utils/firestore');

function generateOrderNumber() {
  const t = Date.now().toString(36).toUpperCase();
  const r = Math.random().toString(36).slice(2, 8).toUpperCase();
  return `CC-${t}-${r}`;
}

async function handleStripeWebhook({ rawBody, signature }) {
  // Stripe template:
  // 1) Verify Stripe signature using STRIPE_WEBHOOK_SECRET
  //    const event = stripe.webhooks.constructEvent(rawBody, signature, STRIPE_WEBHOOK_SECRET)
  // 2) Handle checkout.session.completed
  // 3) Optionally fetch the session from Stripe for extra verification
  //
  // This stub expects a JSON payload like:
  // { "type": "checkout.session.completed", "data": { "draftId": "...", "amount_total": 1234, "currency": "usd", "payment_intent": "pi_...", "session_id": "cs_..." } }
  let event;
  try {
    event = JSON.parse(Buffer.isBuffer(rawBody) ? rawBody.toString('utf8') : String(rawBody || '{}'));
  } catch {
    throw new ApiError({ status: 400, code: 'INVALID_WEBHOOK_PAYLOAD', message: 'Invalid webhook payload', details: [] });
  }

  const db = getDb();
  const now = nowIso();

  const eventId = String(event.id || newId());
  const processedRef = db.collection('stripeWebhookEvents').doc(eventId);
  const processedSnap = await processedRef.get();
  if (processedSnap.exists) return { received: true, duplicate: true };
  await processedRef.create({ id: eventId, type: event.type || 'unknown', createdAt: now });

  if (event.type !== 'checkout.session.completed') {
    return { received: true };
  }

  const payload = event.data || {};
  const draftId = payload.draftId;
  if (!draftId) return { received: true };

  const draftRef = db.collection('checkoutDrafts').doc(draftId);

  await db.runTransaction(async (tx) => {
    const draftSnap = await tx.get(draftRef);
    if (!draftSnap.exists) return;

    const draft = { id: draftSnap.id, ...draftSnap.data() };
    if (draft.status === 'PAID' || draft.status === 'ORDER_CREATED') return;

    const amountTotal = Number(payload.amount_total || 0);
    if (amountTotal !== Number(draft.subtotal || 0)) {
      tx.set(draftRef, { status: 'AMOUNT_MISMATCH', updatedAt: now }, { merge: true });
      return;
    }

    const items = Array.isArray(draft.items) ? draft.items : [];

    for (const it of items) {
      const productRef = db.collection('products').doc(it.productId);
      const productSnap = await tx.get(productRef);
      if (!productSnap.exists) {
        tx.set(draftRef, { status: 'PRODUCT_MISSING', updatedAt: now }, { merge: true });
        return;
      }
      const product = productSnap.data();
      const available = Number(product.availableUnits ?? 0);
      if (available < Number(it.quantity)) {
        tx.set(draftRef, { status: 'OUT_OF_STOCK', updatedAt: now }, { merge: true });
        return;
      }
      const newStock = available - Number(it.quantity);
      tx.set(productRef, { availableUnits: newStock, updatedAt: now }, { merge: true });
    }

    const orderId = newId();
    const orderNumber = generateOrderNumber();

    tx.create(db.collection('orders').doc(orderId), {
      orderNumber,
      status: 'PAID',
      currency: draft.currency,
      subtotal: draft.subtotal,
      total: draft.subtotal,
      discountTotal: 0,
      couponCode: null,
      shippingAddress: draft.shippingAddress,
      stripeCheckoutSessionId: payload.session_id || null,
      stripePaymentIntentId: payload.payment_intent || null,
      createdAt: now,
      updatedAt: now,
      canceledAt: null,
      deletedAt: null,
    });

    for (const it of items) {
      tx.create(db.collection('orderItems').doc(newId()), {
        orderId,
        productId: it.productId,
        variantId: null,
        quantity: it.quantity,
        unitPrice: it.unitAmount,
        currency: draft.currency,
        selectedSize: it.selectedSize,
        selectedColor: it.selectedColor,
        snapshot: it.snapshot || null,
        createdAt: now,
        updatedAt: now,
      });
    }

    tx.set(draftRef, { status: 'ORDER_CREATED', orderId, updatedAt: now }, { merge: true });
  });

  return { received: true };
}

module.exports = { handleStripeWebhook };
