const Stripe = require('stripe');
const { getConfig } = require('./env');

let stripe;

function getStripe() {
  if (stripe) return stripe;
  const config = getConfig();
  stripe = new Stripe(config.stripe.secretKey, { apiVersion: '2024-06-20' });
  return stripe;
}

module.exports = { getStripe };
