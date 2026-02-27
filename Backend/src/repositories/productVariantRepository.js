const { getDb } = require('../config/firebase');

function variantsCol() {
  return getDb().collection('productVariants');
}

async function getById(variantId) {
  const doc = await variantsCol().doc(variantId).get();
  if (!doc.exists) return null;
  return { id: doc.id, ...doc.data() };
}

module.exports = { getById };
