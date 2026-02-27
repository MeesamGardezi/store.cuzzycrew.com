const { asyncHandler } = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/response');
const categoryService = require('../services/categoryService');

const list = asyncHandler(async (req, res) => {
  const items = await categoryService.listCategories();
  return sendSuccess(res, { data: { items }, message: '' });
});

module.exports = { list };
