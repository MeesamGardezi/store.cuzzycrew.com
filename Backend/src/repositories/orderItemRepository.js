const { getDb } = require('../config/firebase');

function orderItemsCol() {
  return getDb().collection('orderItems');
}

async function listByOrderId(orderId) {
  const snap = await orderItemsCol().where('orderId', '==', orderId).get();
  return snap.docs.map((d) => ({ id: d.id, ...d.data() }));
}

module.exports = { orderItemsCol, listByOrderId };
