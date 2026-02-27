const { ApiError } = require('../utils/apiError');

function validateRequest(schema) {
  return (req, res, next) => {
    const parsed = schema.safeParse({
      body: req.body,
      query: req.query,
      params: req.params,
      headers: req.headers,
    });

    if (!parsed.success) {
      return next(
        new ApiError({
          status: 400,
          code: 'VALIDATION_ERROR',
          message: 'Invalid request',
          details: parsed.error.issues.map((i) => ({
            path: i.path.join('.'),
            message: i.message,
          })),
        })
      );
    }

    req.validated = parsed.data;
    return next();
  };
}

module.exports = { validateRequest };
