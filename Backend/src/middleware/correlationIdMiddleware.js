const { randomUUID } = require('crypto');

function correlationIdMiddleware(req, res, next) {
  const headerId = req.header('x-correlation-id');
  const correlationId = headerId && typeof headerId === 'string' ? headerId : randomUUID();

  req.correlationId = correlationId;
  res.setHeader('x-correlation-id', correlationId);

  next();
}

module.exports = { correlationIdMiddleware };
