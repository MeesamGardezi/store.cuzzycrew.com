const test = require('node:test');
const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const path = require('node:path');

const { FakeDb } = require('./helpers/fakeFirestore');

let currentDb;

function mockFirebase(db) {
  const firebasePath = path.resolve(__dirname, '../src/config/firebase.js');
  currentDb = db;
  require.cache[firebasePath] = { exports: { getDb: () => currentDb } };
}

function signPayload(secret, rawBody, timestamp) {
  const signature = crypto.createHmac('sha256', secret).update(`${timestamp}:${rawBody}`).digest('hex');
  return `ts=${timestamp};h1=${signature}`;
}

test('createCheckout returns a Paddle checkout url and upserts a payment record', async () => {
  process.env.JWT_ACCESS_SECRET = 'test-access-secret-1234567890';
  process.env.JWT_REFRESH_SECRET = 'test-refresh-secret-1234567890';
  process.env.PADDLE_WEBHOOK_SECRET = 'test-webhook-secret-12345';
  process.env.PADDLE_CHECKOUT_URL = 'https://checkout.example.com/paddle';

  const db = new FakeDb({
    orders: {
      order_1: {
        id: 'order_1',
        orderNumber: 'CC-1',
        orderToken: 'order-token-1',
        status: 'PENDING_PAYMENT',
        paymentStatus: 'pending',
        paymentProvider: 'paddle',
        processed: false,
        total: 2599,
        currency: 'USD',
      },
    },
  });

  mockFirebase(db);

  const paymentService = require('../src/services/paymentService');
  const result = await paymentService.createCheckout({ orderId: 'order_1', orderToken: 'order-token-1' });

  assert.match(result.checkoutUrl, /orderId=order_1/);
  assert.match(result.checkoutUrl, /orderToken=order-token-1/);
  const payments = db.getCollectionDocs('payments');
  assert.equal(payments.length, 1);
  assert.equal(payments[0].provider, 'paddle');
  assert.equal(payments[0].status, 'pending');
});

test('handleWebhook marks paid orders as paid and leaves processed false', async () => {
  process.env.JWT_ACCESS_SECRET = 'test-access-secret-1234567890';
  process.env.JWT_REFRESH_SECRET = 'test-refresh-secret-1234567890';
  process.env.PADDLE_WEBHOOK_SECRET = 'test-webhook-secret-12345';
  process.env.PADDLE_CHECKOUT_URL = 'https://checkout.example.com/paddle';

  const db = new FakeDb({
    orders: {
      order_2: {
        id: 'order_2',
        orderNumber: 'CC-2',
        orderToken: 'order-token-2',
        status: 'PENDING_PAYMENT',
        paymentStatus: 'pending',
        paymentProvider: 'paddle',
        processed: false,
        total: 2599,
        currency: 'USD',
      },
    },
  });

  mockFirebase(db);

  const paymentService = require('../src/services/paymentService');
  const rawBody = JSON.stringify({
    event_id: 'evt_1',
    event_type: 'transaction.completed',
    data: {
      id: 'txn_1',
      currency_code: 'USD',
      amount: 2599,
      custom_data: { orderId: 'order_2' },
    },
  });
  const signature = signPayload(process.env.PADDLE_WEBHOOK_SECRET, rawBody, Math.floor(Date.now() / 1000));

  const result = await paymentService.handleWebhook({ rawBody: Buffer.from(rawBody), signature });
  assert.deepEqual(result, { received: true });

  const order = db.getCollectionDocs('orders')[0];
  assert.equal(order.status, 'PAID');
  assert.equal(order.paymentStatus, 'paid');
  assert.equal(order.processed, false);

  const duplicate = await paymentService.handleWebhook({ rawBody: Buffer.from(rawBody), signature });
  assert.equal(duplicate.duplicate, true);
});

test('handleWebhook marks failed orders as failed', async () => {
  process.env.JWT_ACCESS_SECRET = 'test-access-secret-1234567890';
  process.env.JWT_REFRESH_SECRET = 'test-refresh-secret-1234567890';
  process.env.PADDLE_WEBHOOK_SECRET = 'test-webhook-secret-12345';
  process.env.PADDLE_CHECKOUT_URL = 'https://checkout.example.com/paddle';

  const db = new FakeDb({
    orders: {
      order_3: {
        id: 'order_3',
        orderNumber: 'CC-3',
        orderToken: 'order-token-3',
        status: 'PENDING_PAYMENT',
        paymentStatus: 'pending',
        paymentProvider: 'paddle',
        processed: false,
        total: 2599,
        currency: 'USD',
      },
    },
  });

  mockFirebase(db);

  const paymentService = require('../src/services/paymentService');
  const rawBody = JSON.stringify({
    event_id: 'evt_2',
    event_type: 'transaction.canceled',
    data: {
      id: 'txn_2',
      currency_code: 'USD',
      amount: 2599,
      custom_data: { orderId: 'order_3' },
    },
  });
  const signature = signPayload(process.env.PADDLE_WEBHOOK_SECRET, rawBody, Math.floor(Date.now() / 1000));

  await paymentService.handleWebhook({ rawBody: Buffer.from(rawBody), signature });

  const order = db.getCollectionDocs('orders')[0];
  assert.equal(order.status, 'FAILED');
  assert.equal(order.paymentStatus, 'failed');
  assert.equal(order.processed, false);
});