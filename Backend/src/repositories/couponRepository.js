const { getDb } = require('../config/firebase');

function couponsCol() {
  return getDb().collection('coupons');
}

async function getByCode(codeUpper) {
  const snap = await couponsCol().where('codeUpper', '==', codeUpper).where('deletedAt', '==', null).limit(1).get();
  if (snap.empty) return null;
  const doc = snap.docs[0];
  return { id: doc.id, ...doc.data() };
}

module.exports = { getByCode };
