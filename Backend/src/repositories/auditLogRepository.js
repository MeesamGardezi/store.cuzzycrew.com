const { getDb } = require('../config/firebase');

function auditLogsCol() {
  return getDb().collection('auditLogs');
}

async function create({
  auditLogId,
  actorUserId,
  action,
  entityType,
  entityId,
  before,
  after,
  correlationId,
  createdAt,
}) {
  await auditLogsCol().doc(auditLogId).create({
    actorUserId,
    action,
    entityType,
    entityId,
    before: before || null,
    after: after || null,
    correlationId: correlationId || null,
    createdAt,
  });
}

module.exports = { create };
