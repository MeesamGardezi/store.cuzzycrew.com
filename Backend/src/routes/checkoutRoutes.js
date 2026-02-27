const express = require('express');

const { optionalAuth } = require('../middleware/optionalAuth');
const { cartContext } = require('../middleware/cartContext');
const checkoutController = require('../controllers/checkoutController');

const checkoutRoutes = express.Router();

checkoutRoutes.post('/quote', optionalAuth, cartContext, checkoutController.quote);

module.exports = { checkoutRoutes };
