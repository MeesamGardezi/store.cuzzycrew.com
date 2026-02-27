const { getDb } = require('../config/firebase');

function paymentsCol() {
  return getDb().collection('payments');
}

function webhookEventsCol() {
  return getDb().collection('stripeWebhookEvents');
}

async function upsertForOrder({ orderId, stripePaymentIntentId, status, amount, currency, nowIso }) {
  const snap = await paymentsCol().where('orderId', '==', orderId).limit(1).get();
  if (snap.empty) {
    await paymentsCol().doc().create({
      orderId,
      stripePaymentIntentId,
      status,
      amount,
      currency,
      createdAt: nowIso,
      updatedAt: nowIso,
    });
    return;
  }

  await snap.docs[0].ref.set(
    {
      stripePaymentIntentId,
      status,
      amount,
      currency,
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
  await ref.create({ processedAt: nowIso });
  return true;
}

module.exports = { upsertForOrder, getByOrderId, markWebhookEventProcessed };
