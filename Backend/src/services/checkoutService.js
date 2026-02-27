const cartService = require('./cartService');

async function quote({ userId, sessionToken }) {
  const { cart, items } = await cartService.getCart({ userId, sessionToken });

  return {
    cart,
    items,
    totals: {
      subtotal: cart.subtotal,
      discountTotal: cart.discountTotal,
      total: cart.total,
      currency: cart.currency,
    },
  };
}

module.exports = { quote };
