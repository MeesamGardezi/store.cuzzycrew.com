const { newId, nowIso } = require('../utils/firestore');
const auditLogRepository = require('../repositories/auditLogRepository');

async function writeAuditLog({ actorUserId, action, entityType, entityId, before, after, correlationId }) {
  await auditLogRepository.create({
    auditLogId: newId(),
    actorUserId,
    action,
    entityType,
    entityId,
    before,
    after,
    correlationId,
    createdAt: nowIso(),
  });
}

module.exports = { writeAuditLog };
