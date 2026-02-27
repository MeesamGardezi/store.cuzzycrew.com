const { getDb } = require('../config/firebase');

function categoriesCol() {
  return getDb().collection('categories');
}

async function list() {
  const snap = await categoriesCol().where('deletedAt', '==', null).orderBy('name', 'asc').get();
  return snap.docs.map((d) => ({ id: d.id, ...d.data() }));
}

module.exports = { list };
