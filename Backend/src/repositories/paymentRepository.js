const { getDb } = require('../config/firebase');

function paymentsCol() {
  return getDb().collection('payments');
}

function webhookEventsCol() {
  return getDb().collection('paymentWebhookEvents');
}

async function upsertForOrder({ orderId, provider, providerTransactionId, status, amount, currency, checkoutUrl, metadata, nowIso }) {
  const snap = await paymentsCol().where('orderId', '==', orderId).limit(1).get();
  if (snap.empty) {
    await paymentsCol().doc().create({
      orderId,
      provider,
      providerTransactionId: providerTransactionId || null,
      status,
      amount,
      currency,
      checkoutUrl: checkoutUrl || null,
      metadata: metadata || null,
      createdAt: nowIso,
      updatedAt: nowIso,
    });
    return;
  }

  await snap.docs[0].ref.set(
    {
      provider,
      providerTransactionId: providerTransactionId || null,
      status,
      amount,
      currency,
      checkoutUrl: checkoutUrl || null,
      metadata: metadata || null,
      updatedAt: nowIso,
    },
    { merge: true }
  );
}

async function getByOrderId(orderId) {
  const snap = await paymentsCol().where('orderId', '==', orderId).limit(1).get();
  if (snap.empty) return null;
  const doc = snap.docs[0];
  return { id: doc.id, ...doc.data() };
}

async function markWebhookEventProcessed({ eventId, nowIso }) {
  const ref = webhookEventsCol().doc(eventId);
  const doc = await ref.get();
  if (doc.exists) return false;
  await ref.create({ eventId, processedAt: nowIso });
  return true;
}

module.exports = { upsertForOrder, getByOrderId, markWebhookEventProcessed };
