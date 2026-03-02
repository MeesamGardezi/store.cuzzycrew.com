const express = require('express');

const appController = require('../controllers/appController');

const appRoutes = express.Router();

appRoutes.get('/categories', appController.categories);
appRoutes.get('/products', appController.products);
appRoutes.get('/products/:id', appController.productById);
appRoutes.get('/website-banner', appController.websiteBanner);

module.exports = { appRoutes };
