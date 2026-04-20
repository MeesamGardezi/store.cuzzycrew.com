const ORDER_STATUSES = Object.freeze({
  PENDING_PAYMENT: 'PENDING_PAYMENT',
  PAID: 'PAID',
  FAILED: 'FAILED',
  CANCELED: 'CANCELED',
  SHIPPED: 'SHIPPED',
  DELIVERED: 'DELIVERED',
});

const PAYMENT_STATUSES = Object.freeze({
  PENDING: 'pending',
  PAID: 'paid',
  FAILED: 'failed',
});

function normalizeOrderStatus(status) {
  const raw = String(status || '').trim().toUpperCase();

  if (raw === 'CANCELLED') return ORDER_STATUSES.CANCELED;
  if (raw === 'PENDING') return ORDER_STATUSES.PENDING_PAYMENT;
  if (raw === 'PROCESSING') return ORDER_STATUSES.PAID;

  return ORDER_STATUSES[raw] || ORDER_STATUSES.PENDING_PAYMENT;
}

function normalizePaymentStatus(status) {
  const raw = String(status || '').trim().toLowerCase();
  if (raw === PAYMENT_STATUSES.PAID || raw === 'succeeded') return PAYMENT_STATUSES.PAID;
  if (raw === PAYMENT_STATUSES.FAILED) return PAYMENT_STATUSES.FAILED;
  return PAYMENT_STATUSES.PENDING;
}

function getInitialOrderState() {
  return {
    status: ORDER_STATUSES.PENDING_PAYMENT,
    paymentStatus: PAYMENT_STATUSES.PENDING,
    processed: false,
    processedAt: null,
    processedBy: null,
    paymentProvider: 'paddle',
  };
}

module.exports = {
  ORDER_STATUSES,
  PAYMENT_STATUSES,
  normalizeOrderStatus,
  normalizePaymentStatus,
  getInitialOrderState,
};