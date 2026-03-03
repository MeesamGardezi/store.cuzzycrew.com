const multer = require('multer');
const { ApiError } = require('../utils/apiError');

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024,
    files: 12,
  },
});

const productImagesUpload = upload.fields([
  { name: 'thumbnail', maxCount: 1 },
  { name: 'sizeGuideImage', maxCount: 1 },
  { name: 'images', maxCount: 10 },
]);

function parseMultipartJsonBody(req, _res, next) {
  if (!req.is('multipart/form-data')) return next();

  if (!req.body || typeof req.body !== 'object') return next();

  if (!req.body.data) return next();

  try {
    const parsed = JSON.parse(String(req.body.data));
    req.body = parsed;
    return next();
  } catch (e) {
    return next(
      new ApiError({
        status: 400,
        code: 'INVALID_JSON',
        message: 'Invalid JSON in multipart field `data`',
        details: [],
      })
    );
  }
}

module.exports = { productImagesUpload, parseMultipartJsonBody };
