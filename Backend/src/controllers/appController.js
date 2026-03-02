const { asyncHandler } = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/response');
const { ApiError } = require('../utils/apiError');

const appCategoryRepository = require('../repositories/appCategoryRepository');
const appProductRepository = require('../repositories/appProductRepository');
const bannerRepository = require('../repositories/bannerRepository');

const categories = asyncHandler(async (req, res) => {
  const items = await appCategoryRepository.listForApp();
  return sendSuccess(res, { data: { categories: items }, message: '' });
});

const products = asyncHandler(async (req, res) => {
  const category = req.query.category ? String(req.query.category) : null;
  const items = await appProductRepository.listForApp({ category });
  return sendSuccess(res, { data: { products: items }, message: '' });
});

const productById = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const product = await appProductRepository.getByIdForApp(id);
  if (!product) throw new ApiError({ status: 404, code: 'NOT_FOUND', message: 'Product not found', details: [] });
  return sendSuccess(res, { data: product, message: '' });
});

const websiteBanner = asyncHandler(async (req, res) => {
  const banner = await bannerRepository.getWebsiteBanner();
  return sendSuccess(res, { data: banner, message: '' });
});

module.exports = { categories, products, productById, websiteBanner };
