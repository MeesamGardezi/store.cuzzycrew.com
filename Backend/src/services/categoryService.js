const categoryRepository = require('../repositories/categoryRepository');

async function listCategories() {
  return categoryRepository.list();
}

module.exports = { listCategories };
