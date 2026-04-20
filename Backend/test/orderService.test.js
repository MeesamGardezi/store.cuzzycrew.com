const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');

const { FakeDb } = require('./helpers/fakeFirestore');

function mockFirebase(db) {
  const firebasePath = path.resolve(__dirname, '../src/config/firebase.js');
  require.cache[firebasePath] = { exports: { getDb: () => db } };
}

test('createOrder creates a pending-payment order with tokens and items', async () => {
  const db = new FakeDb({
    products: {
      product_1: {
        name: 'Hoodie',
        price: 24.5,
        thumbnail: 'https://example.com/hoodie.jpg',
        availableUnits: 10,
      },
    },
  });

  mockFirebase(db);

  const orderService = require('../src/services/orderService');

  const result = await orderService.createOrder({
    userId: 'user_1',
    idempotencyKey: 'idem-order-1',
    items: [
      {
        productId: 'product_1',
        quantity: 2,
        selectedSize: 'M',
        selectedColor: '#ffffff',
      },
    ],
    currency: 'USD',
    shippingAddress: {
      fullName: 'Test User',
      phone: '555-0100',
      addressLine1: '123 Main St',
      city: 'Austin',
      postalCode: '78701',
      country: 'US',
    },
  });

  assert.equal(result.order.status, 'PENDING_PAYMENT');
  assert.equal(result.order.paymentStatus, 'pending');
  assert.equal(result.order.processed, false);
  assert.ok(result.order.orderToken);
  assert.equal(result.items.length, 1);
  assert.equal(result.items[0].quantity, 2);

  const storedOrder = db.getCollectionDocs('orders')[0];
  assert.equal(storedOrder.status, 'PENDING_PAYMENT');
  assert.equal(storedOrder.paymentProvider, 'paddle');
  assert.equal(storedOrder.processed, false);
});