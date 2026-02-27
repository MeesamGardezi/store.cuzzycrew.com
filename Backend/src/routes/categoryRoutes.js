const express = require('express');

const categoryController = require('../controllers/categoryController');

const categoryRoutes = express.Router();

categoryRoutes.get('/', categoryController.list);

module.exports = { categoryRoutes };
