# Checkout & Payment Flow (Paddle)

This document covers the storefront checkout flow after migrating away from Stripe. The app creates an order, opens a hosted Paddle checkout URL, then polls the backend until the payment is final.

## Overview
- Checkout is guest-friendly and uses an order access token instead of login.
- The backend owns order creation, checkout URL generation, and Paddle webhook verification.
- The app only opens the hosted checkout and polls payment status with retry/backoff.

## User Flow
1. User adds items to cart.
2. User enters shipping details.
3. The app calls `POST /api/orders` with cart items and the mapped shipping address.
4. The backend returns an order plus an `orderToken`.
5. The app calls `POST /api/payments/checkout`.
6. The backend returns a hosted Paddle checkout URL.
7. The app opens the URL externally.
8. After return, the app polls `GET /api/payments/:orderId/status` with `x-order-token`.
9. The order finishes as paid or failed.

## Data Flow
- `OrderModel`: Stores the canonical order status, payment status, payment provider, processed flags, totals, and token.
- `OrderController`: Builds the order payload, launches hosted checkout, and polls payment status.
- `ApiService`: Sends backend requests and includes the order token when polling payment status.

## Key Files
- `lib/model/orderModel.dart`
- `lib/controller/orderController.dart`
- `lib/views/pages/checkoutpage/checkoutPage.dart`
- `lib/api/ApiService.dart`

## Notes
- Totals from the backend are treated as minor units and converted to major units for display.
- The app never talks to Paddle directly; only the backend handles webhook verification and payment state.