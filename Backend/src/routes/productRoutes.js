const express = require('express');

const { validateRequest } = require('../middleware/validateRequest');
const { listProductsSchema, productSlugSchema, productIdSchema } = require('../validators/catalogValidators');
const productController = require('../controllers/productController');

const productRoutes = express.Router();

productRoutes.get('/', validateRequest(listProductsSchema), productController.list);
productRoutes.get('/:slug', validateRequest(productSlugSchema), productController.getBySlug);
productRoutes.get('/:id/recommendations', validateRequest(productIdSchema), productController.recommendations);

module.exports = { productRoutes };
