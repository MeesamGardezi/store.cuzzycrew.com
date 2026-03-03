const { createServer } = require('../src/server');

let cached;

module.exports = async (req, res) => {
  if (!cached) {
    const { app } = await createServer();
    cached = app;
  }

  return cached(req, res);
};
