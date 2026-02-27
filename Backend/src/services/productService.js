const { ApiError } = require('../utils/apiError');
const productRepository = require('../repositories/productRepository');

async function listProducts({ limit, cursor, filters, sort }) {
  return productRepository.list({ limit, startAfter: cursor, filters, sort });
}

async function getProductBySlug(slug) {
  const product = await productRepository.getBySlug(slug);
  if (!product) throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Product not found', details: [] });
  return product;
}

async function getRecommendationsByProductId(productId) {
  const product = await productRepository.getById(productId);
  if (!product) throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Product not found', details: [] });

  const { items } = await productRepository.list({
    limit: 8,
    startAfter: null,
    filters: { categoryId: product.categoryId },
    sort: 'newest',
  });

  return items.filter((p) => p.id !== productId).slice(0, 8);
}

module.exports = { listProducts, getProductBySlug, getRecommendationsByProductId };
