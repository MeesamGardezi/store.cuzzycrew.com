const { asyncHandler } = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/response');
const productService = require('../services/productService');

const list = asyncHandler(async (req, res) => {
  const q = req.validated.query;

  const { items, nextCursor } = await productService.listProducts({
    limit: q.limit,
    cursor: q.cursor || null,
    filters: {
      categoryId: q.category,
      color: q.color,
      size: q.size,
      priceMin: q.priceMin,
      priceMax: q.priceMax,
    },
    sort: q.sort || 'newest',
  });

  return sendSuccess(res, { data: { items, nextCursor }, message: '' });
});

const getBySlug = asyncHandler(async (req, res) => {
  const { slug } = req.validated.params;
  const product = await productService.getProductBySlug(slug);
  return sendSuccess(res, { data: product, message: '' });
});

const recommendations = asyncHandler(async (req, res) => {
  const { id } = req.validated.params;
  const items = await productService.getRecommendationsByProductId(id);
  return sendSuccess(res, { data: { items }, message: '' });
});

module.exports = { list, getBySlug, recommendations };
