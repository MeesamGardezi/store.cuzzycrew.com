const express = require('express');

const { getDb } = require('../config/firebase');
const { getConfig } = require('../config/env');
const orderRepository = require('../repositories/orderRepository');
const paymentRepository = require('../repositories/paymentRepository');
const { nowIso } = require('../utils/firestore');
const { asyncHandler } = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/response');
const { ORDER_STATUSES, PAYMENT_STATUSES } = require('../utils/orderState');

const devRoutes = express.Router();

// DUMMY: Simulate Paddle payment success for an order.
// Only active in non-production environments.
devRoutes.post('/simulate-payment-success', asyncHandler(async (req, res) => {
  if (getConfig().env === 'production') {
    return res.status(404).json({ error: { message: 'Not found' } });
  }

  const { orderId, orderToken } = req.body || {};
  if (!orderId || !orderToken) {
    return res.status(400).json({ error: { message: 'orderId and orderToken required' } });
  }

  const order = await orderRepository.getById(orderId);
  if (!order) {
    return res.status(404).json({ error: { message: 'Order not found' } });
  }

  if (String(order.orderToken || '') !== String(orderToken)) {
    return res.status(403).json({ error: { message: 'Invalid token' } });
  }

  const db = getDb();
  const now = nowIso();

  await db.collection('orders').doc(orderId).set(
    {
      status: ORDER_STATUSES.PAID,
      paymentStatus: PAYMENT_STATUSES.PAID,
      paymentProvider: 'paddle',
      processed: false,
      updatedAt: now,
    },
    { merge: true }
  );

  await paymentRepository.upsertForOrder({
    orderId,
    provider: 'paddle',
    providerTransactionId: `dummy_${orderId}`,
    status: PAYMENT_STATUSES.PAID,
    amount: order.total,
    currency: order.currency,
    checkoutUrl: null,
    metadata: { dummy: true },
    nowIso: now,
  });

  return sendSuccess(res, { data: { success: true, orderId, status: 'paid' }, message: '' });
}));

module.exports = { devRoutes };
