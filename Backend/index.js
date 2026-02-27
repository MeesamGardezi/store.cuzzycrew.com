const { createServer } = require('./src/server');

createServer()
  .then(({ app, config }) => {
    app.listen(config.port, () => {
      console.log(`Backend listening on port ${config.port}`);
    });
  })
  .catch((err) => {
    console.error('Failed to start server', err);
    process.exit(1);
  });
