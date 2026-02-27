const { getDb } = require('../config/firebase');

function couponsCol() {
  return getDb().collection('coupons');
}

function uniqueCouponCodeDoc(codeUpper) {
  return getDb().collection('uniqueCouponCodes').doc(codeUpper);
}

async function getById(id) {
  const doc = await couponsCol().doc(id).get();
  if (!doc.exists) return null;
  return { id: doc.id, ...doc.data() };
}

async function createCoupon({ couponId, data, nowIso }) {
  const db = getDb();
  const codeUpper = String(data.code || '').toUpperCase();

  await db.runTransaction(async (tx) => {
    const uniqueRef = uniqueCouponCodeDoc(codeUpper);
    const uniqueSnap = await tx.get(uniqueRef);
    if (uniqueSnap.exists) {
      const err = new Error('Coupon code already exists');
      err.code = 'COUPON_TAKEN';
      throw err;
    }

    tx.create(uniqueRef, { couponId, codeUpper, createdAt: nowIso });
    tx.create(couponsCol().doc(couponId), {
      ...data,
      codeUpper,
      usesCount: 0,
      deletedAt: null,
      createdAt: nowIso,
      updatedAt: nowIso,
    });
  });

  return getById(couponId);
}

module.exports = { createCoupon, getById };
