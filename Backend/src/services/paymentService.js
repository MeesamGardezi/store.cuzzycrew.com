const { ApiError } = require('../utils/apiError');
const { nowIso, toNumber } = require('../utils/firestore');
const { getConfig } = require('../config/env');
const { getStripe } = require('../config/stripe');
const orderRepository = require('../repositories/orderRepository');
const paymentRepository = require('../repositories/paymentRepository');
const { getDb } = require('../config/firebase');

async function createPaymentIntent({ userId, orderId }) {
  const config = getConfig();
  const stripe = getStripe();

  const order = await orderRepository.getById(orderId);
  if (!order || order.deletedAt) throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Order not found', details: [] });
  if (order.userId !== userId) throw new ApiError({ status: 403, code: 'FORBIDDEN', message: 'Forbidden', details: [] });

  if (order.status !== 'PENDING' && order.status !== 'FAILED') {
    throw new ApiError({ status: 422, code: 'INVALID_ORDER_STATE', message: 'Order not payable', details: [] });
  }

  const amount = toNumber(order.total, 0);
  const currency = order.currency || 'usd';

  const intent = await stripe.paymentIntents.create({
    amount,
    currency,
    metadata: {
      orderId: order.id,
    },
    automatic_payment_methods: { enabled: true },
  });

  const db = getDb();
  const now = nowIso();

  await db.collection('orders').doc(order.id).set(
    {
      stripePaymentIntentId: intent.id,
      updatedAt: now,
    },
    { merge: true }
  );

  await paymentRepository.upsertForOrder({
    orderId: order.id,
    stripePaymentIntentId: intent.id,
    status: 'REQUIRES_PAYMENT_METHOD',
    amount,
    currency,
    nowIso: now,
  });

  return { clientSecret: intent.client_secret, stripePaymentIntentId: intent.id };
}

async function handleWebhook({ rawBody, signature }) {
  const config = getConfig();
  const stripe = getStripe();

  let event;
  try {
    event = stripe.webhooks.constructEvent(rawBody, signature, config.stripe.webhookSecret);
  } catch {
    throw new ApiError({ status: 400, code: 'INVALID_WEBHOOK_SIGNATURE', message: 'Invalid webhook signature', details: [] });
  }

  const processed = await paymentRepository.markWebhookEventProcessed({ eventId: event.id, nowIso: nowIso() });
  if (!processed) {
    return { received: true, duplicate: true };
  }

  const obj = event.data.object;
  const paymentIntentId = obj.id;
  const orderId = obj.metadata?.orderId;

  if (!orderId) {
    return { received: true };
  }

  const db = getDb();
  const now = nowIso();

  if (event.type === 'payment_intent.succeeded') {
    await db.collection('orders').doc(orderId).set({ status: 'PROCESSING', updatedAt: now }, { merge: true });
    await paymentRepository.upsertForOrder({
      orderId,
      stripePaymentIntentId: paymentIntentId,
      status: 'SUCCEEDED',
      amount: toNumber(obj.amount_received, 0),
      currency: obj.currency || 'usd',
      nowIso: now,
    });
  }

  if (event.type === 'payment_intent.payment_failed') {
    await db.collection('orders').doc(orderId).set({ status: 'FAILED', updatedAt: now }, { merge: true });
    await paymentRepository.upsertForOrder({
      orderId,
      stripePaymentIntentId: paymentIntentId,
      status: 'FAILED',
      amount: toNumber(obj.amount, 0),
      currency: obj.currency || 'usd',
      nowIso: now,
    });
  }

  return { received: true };
}

async function getPaymentStatus({ userId, orderId }) {
  const order = await orderRepository.getById(orderId);
  if (!order || order.deletedAt) throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Order not found', details: [] });
  if (order.userId !== userId) throw new ApiError({ status: 403, code: 'FORBIDDEN', message: 'Forbidden', details: [] });

  const payment = await paymentRepository.getByOrderId(orderId);
  return {
    order: { id: order.id, status: order.status, total: order.total, currency: order.currency },
    payment,
  };
}

module.exports = { createPaymentIntent, handleWebhook, getPaymentStatus };
