/// Set to `true` to use dummy Paddle mode (no real checkout, instant success simulation).
/// Set to `false` for real Paddle integration.
/// NEVER deploy to production with this set to true.
const bool kUseDummyPaddle = bool.fromEnvironment(
  'USE_DUMMY_PADDLE',
  defaultValue: false,
);
