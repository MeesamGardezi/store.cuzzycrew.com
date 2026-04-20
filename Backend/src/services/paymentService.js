const crypto = require('crypto');

const { ApiError } = require('../utils/apiError');
const { nowIso, toNumber } = require('../utils/firestore');
const { getConfig } = require('../config/env');
const orderRepository = require('../repositories/orderRepository');
const paymentRepository = require('../repositories/paymentRepository');
const { getDb } = require('../config/firebase');
const { ORDER_STATUSES, PAYMENT_STATUSES, normalizePaymentStatus } = require('../utils/orderState');

const SUCCESS_EVENT_TYPES = new Set(['transaction.completed', 'transaction.billed', 'transaction.paid']);
const FAILURE_EVENT_TYPES = new Set(['transaction.canceled', 'transaction.payment_failed', 'transaction.failed']);

function getPaddleConfig() {
  return getConfig().paddle || {};
}

function getCheckoutBaseUrl() {
  const { checkoutUrl } = getPaddleConfig();
  return checkoutUrl || 'https://checkout.paddle.com/checkout';
}

function buildCheckoutUrl({ order, orderToken }) {
  const url = new URL(getCheckoutBaseUrl());
  url.searchParams.set('orderId', order.id);
  url.searchParams.set('orderToken', orderToken);
  url.searchParams.set('currency', String(order.currency || 'USD').toUpperCase());
  url.searchParams.set('amount', String(toNumber(order.total, 0)));
  url.searchParams.set('metadata', JSON.stringify({ orderId: order.id, orderToken }));

  const returnUrl = getPaddleConfig().returnUrl;
  if (returnUrl) {
    url.searchParams.set('returnUrl', returnUrl);
  }

  return url.toString();
}

async function createCheckout({ orderId, orderToken }) {
  const order = await orderRepository.getById(orderId);
  if (!order || order.deletedAt) {
    throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Order not found', details: [] });
  }

  if (String(order.orderToken || '') !== String(orderToken || '')) {
    throw new ApiError({ status: 403, code: 'FORBIDDEN', message: 'Invalid order token', details: [] });
  }

  if (order.status !== ORDER_STATUSES.PENDING_PAYMENT && order.status !== ORDER_STATUSES.FAILED) {
    throw new ApiError({ status: 422, code: 'INVALID_ORDER_STATE', message: 'Order not payable', details: [] });
  }

  const checkoutUrl = buildCheckoutUrl({ order, orderToken });
  const now = nowIso();

  await paymentRepository.upsertForOrder({
    orderId: order.id,
    provider: 'paddle',
    providerTransactionId: order.id,
    status: PAYMENT_STATUSES.PENDING,
    amount: toNumber(order.total, 0),
    currency: String(order.currency || 'USD').toUpperCase(),
    checkoutUrl,
    metadata: { orderId: order.id, orderToken },
    nowIso: now,
  });

  return {
    checkoutUrl,
    payment: {
      provider: 'paddle',
      status: PAYMENT_STATUSES.PENDING,
      checkoutUrl,
      orderId: order.id,
    },
    order: {
      id: order.id,
      orderNumber: order.orderNumber,
      status: order.status,
      paymentStatus: order.paymentStatus,
      paymentProvider: order.paymentProvider,
      processed: Boolean(order.processed),
      processedAt: order.processedAt || null,
      processedBy: order.processedBy || null,
      total: order.total,
      currency: order.currency,
      orderToken,
    },
  };
}

function parsePaddleSignature(signatureHeader) {
  if (!signatureHeader) return null;

  const values = {};
  for (const part of String(signatureHeader).split(';')) {
    const trimmed = part.trim();
    if (!trimmed) continue;
    const [key, value] = trimmed.split('=');
    if (key && value) values[key] = value;
  }

  if (!values.ts || !values.h1) return null;
  return values;
}

function verifyPaddleWebhookSignature({ rawBody, signature }) {
  const webhookSecret = getPaddleConfig().webhookSecret;
  if (!webhookSecret) {
    throw new ApiError({ status: 500, code: 'PADDLE_NOT_CONFIGURED', message: 'Paddle webhook secret is not configured', details: [] });
  }

  const parsed = parsePaddleSignature(signature);
  if (!parsed) {
    throw new ApiError({ status: 400, code: 'INVALID_WEBHOOK_SIGNATURE', message: 'Invalid webhook signature', details: [] });
  }

  const rawText = Buffer.isBuffer(rawBody) ? rawBody.toString('utf8') : String(rawBody || '');
  const signedPayload = `${parsed.ts}:${rawText}`;
  const expected = crypto.createHmac('sha256', webhookSecret).update(signedPayload).digest('hex');

  const expectedBuffer = Buffer.from(expected, 'hex');
  const providedBuffer = Buffer.from(parsed.h1, 'hex');
  if (expectedBuffer.length !== providedBuffer.length || !crypto.timingSafeEqual(expectedBuffer, providedBuffer)) {
    throw new ApiError({ status: 400, code: 'INVALID_WEBHOOK_SIGNATURE', message: 'Invalid webhook signature', details: [] });
  }

  const eventAgeSeconds = Math.abs(Date.now() / 1000 - Number(parsed.ts || 0));
  if (!Number.isFinite(eventAgeSeconds) || eventAgeSeconds > 5 * 60) {
    throw new ApiError({ status: 400, code: 'STALE_WEBHOOK', message: 'Webhook timestamp is too old', details: [] });
  }

  return true;
}

function extractEventBody(rawBody) {
  const rawText = Buffer.isBuffer(rawBody) ? rawBody.toString('utf8') : String(rawBody || '{}');
  try {
    return JSON.parse(rawText);
  } catch {
    throw new ApiError({ status: 400, code: 'INVALID_WEBHOOK_PAYLOAD', message: 'Invalid webhook payload', details: [] });
  }
}

function extractOrderId(eventData) {
  const customData = eventData?.custom_data || eventData?.customData || {};
  return customData.orderId || customData.order_id || eventData?.orderId || eventData?.order_id || null;
}

async function updateOrderAndPayment({ orderId, paymentStatus, status, providerTransactionId, amount, currency, eventType, now }) {
  const db = getDb();
  const orderRef = db.collection('orders').doc(orderId);

  await orderRef.set(
    {
      status,
      paymentStatus,
      paymentProvider: 'paddle',
      processed: false,
      processedAt: null,
      processedBy: null,
      providerTransactionId,
      paymentUpdatedAt: now,
      updatedAt: now,
      paddleEventType: eventType,
    },
    { merge: true }
  );

  await paymentRepository.upsertForOrder({
    orderId,
    provider: 'paddle',
    providerTransactionId,
    status: paymentStatus,
    amount,
    currency,
    checkoutUrl: null,
    metadata: { eventType },
    nowIso: now,
  });
}

async function handleWebhook({ rawBody, signature }) {
  verifyPaddleWebhookSignature({ rawBody, signature });

  const event = extractEventBody(rawBody);
  const eventId = String(event.event_id || event.id || event.notification_id || '');
  if (!eventId) {
    throw new ApiError({ status: 400, code: 'INVALID_WEBHOOK_PAYLOAD', message: 'Invalid webhook payload', details: [] });
  }

  const processed = await paymentRepository.markWebhookEventProcessed({ eventId, nowIso: nowIso() });
  if (!processed) {
    return { received: true, duplicate: true };
  }

  const eventType = String(event.event_type || event.type || '').toLowerCase();
  const eventData = event.data || {};
  const orderId = extractOrderId(eventData);
  if (!orderId) {
    return { received: true };
  }

  const providerTransactionId = String(eventData.id || eventData.transaction_id || eventData.transactionId || orderId);
  const amount = toNumber(eventData.details?.totals?.grand_total || eventData.amount || eventData.amount_total || eventData.details?.totals?.total || 0, 0);
  const currency = String(eventData.currency_code || eventData.currency || 'USD').toUpperCase();
  const now = nowIso();

  if (SUCCESS_EVENT_TYPES.has(eventType)) {
    await updateOrderAndPayment({
      orderId,
      paymentStatus: PAYMENT_STATUSES.PAID,
      status: ORDER_STATUSES.PAID,
      providerTransactionId,
      amount,
      currency,
      eventType,
      now,
    });
  } else if (FAILURE_EVENT_TYPES.has(eventType)) {
    await updateOrderAndPayment({
      orderId,
      paymentStatus: PAYMENT_STATUSES.FAILED,
      status: ORDER_STATUSES.FAILED,
      providerTransactionId,
      amount,
      currency,
      eventType,
      now,
    });
  }

  return { received: true };
}

async function getPaymentStatus({ orderId, orderToken }) {
  const order = await orderRepository.getById(orderId);
  if (!order || order.deletedAt) {
    throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Order not found', details: [] });
  }

  if (String(order.orderToken || '') !== String(orderToken || '')) {
    throw new ApiError({ status: 403, code: 'FORBIDDEN', message: 'Invalid order token', details: [] });
  }

  const payment = await paymentRepository.getByOrderId(orderId);

  return {
    order: {
      id: order.id,
      orderNumber: order.orderNumber,
      status: order.status,
      paymentStatus: normalizePaymentStatus(order.paymentStatus),
      paymentProvider: order.paymentProvider || 'paddle',
      processed: Boolean(order.processed),
      processedAt: order.processedAt || null,
      processedBy: order.processedBy || null,
      total: order.total,
      currency: order.currency,
    },
    payment: payment
      ? {
          provider: payment.provider || 'paddle',
          status: normalizePaymentStatus(payment.status),
          providerTransactionId: payment.providerTransactionId || null,
          checkoutUrl: payment.checkoutUrl || null,
          amount: payment.amount,
          currency: payment.currency,
          metadata: payment.metadata || null,
        }
      : {
          provider: 'paddle',
          status: PAYMENT_STATUSES.PENDING,
          providerTransactionId: null,
          checkoutUrl: null,
          amount: toNumber(order.total, 0),
          currency: order.currency,
          metadata: null,
        },
  };
}

module.exports = { createCheckout, handleWebhook, getPaymentStatus, verifyPaddleWebhookSignature };