const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');

const { FakeDb } = require('./helpers/fakeFirestore');

function mockFirebase(db) {
  const firebasePath = path.resolve(__dirname, '../src/config/firebase.js');
  require.cache[firebasePath] = { exports: { getDb: () => db } };
}

test('admin order listing filters by processed state', async () => {
  const db = new FakeDb({
    orders: {
      order_1: { id: 'order_1', orderNumber: 'CC-1', createdAt: '2026-04-17T00:00:00.000Z', processed: false },
      order_2: { id: 'order_2', orderNumber: 'CC-2', createdAt: '2026-04-17T01:00:00.000Z', processed: true },
    },
  });

  mockFirebase(db);

  const adminOrderRepository = require('../src/repositories/adminOrderRepository');
  const unprocessed = await adminOrderRepository.list({ processed: false });
  const processed = await adminOrderRepository.list({ processed: true });

  assert.equal(unprocessed.items.length, 1);
  assert.equal(unprocessed.items[0].id, 'order_1');
  assert.equal(processed.items.length, 1);
  assert.equal(processed.items[0].id, 'order_2');
});

test('toggleProcessed flips state and metadata', async () => {
  const db = new FakeDb({
    orders: {
      order_1: { id: 'order_1', orderNumber: 'CC-1', createdAt: '2026-04-17T00:00:00.000Z', processed: false, processedAt: null, processedBy: null },
    },
  });

  mockFirebase(db);

  const adminOrderRepository = require('../src/repositories/adminOrderRepository');
  const updated = await adminOrderRepository.toggleProcessed({ orderId: 'order_1', adminUserId: 'admin_1', nowIso: '2026-04-17T02:00:00.000Z' });

  assert.equal(updated.processed, true);
  assert.equal(updated.processedBy, 'admin_1');
  assert.equal(updated.processedAt, '2026-04-17T02:00:00.000Z');

  const reverted = await adminOrderRepository.toggleProcessed({ orderId: 'order_1', adminUserId: 'admin_1', nowIso: '2026-04-17T03:00:00.000Z' });
  assert.equal(reverted.processed, false);
  assert.equal(reverted.processedBy, null);
  assert.equal(reverted.processedAt, null);
});