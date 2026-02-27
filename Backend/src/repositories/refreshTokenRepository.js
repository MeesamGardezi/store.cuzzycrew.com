const { getDb } = require('../config/firebase');

function refreshTokensCol() {
  return getDb().collection('refreshTokens');
}

async function create({ tokenId, userId, expiresAtIso, createdAtIso }) {
  await refreshTokensCol().doc(tokenId).set({
    userId,
    expiresAt: expiresAtIso,
    createdAt: createdAtIso,
    revokedAt: null,
  });
}

async function getById(tokenId) {
  const doc = await refreshTokensCol().doc(tokenId).get();
  if (!doc.exists) return null;
  return { id: doc.id, ...doc.data() };
}

async function revoke(tokenId, revokedAtIso) {
  await refreshTokensCol().doc(tokenId).set({ revokedAt: revokedAtIso }, { merge: true });
}

module.exports = { create, getById, revoke };
