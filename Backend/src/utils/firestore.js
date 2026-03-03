const { randomUUID } = require('crypto');

function newId() {
  return randomUUID();
}

function nowIso() {
  return new Date().toISOString();
}

function toNumber(value, fallback = 0) {
  const n = Number(value);
  return Number.isFinite(n) ? n : fallback;
}

module.exports = { newId, nowIso, toNumber };
