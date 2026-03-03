# Checkout & Payment Flow (Stripe Integration)

This document explains the checkout and payment flow in the Flutter app, including how Stripe is integrated via the backend. It covers the user experience, data flow, and key files involved.

---

## Overview
- **No login/signup required**: All product and category APIs are public.
- **Stripe integration**: Payments are handled via Stripe, but the user never sees Stripe UI directly in the app (future handoff possible).
- **Order and payment logic**: Managed by the backend and coordinated in the app via `OrderController` and `ApiService`.

---

## User Flow
1. **User adds items to cart**
2. **User proceeds to checkout**
3. **User enters shipping details**
4. **User taps 'Place Order'**
5. **App creates order via backend API**
6. **Backend creates Stripe session/payment intent**
7. **App receives order/payment info from backend**
8. **(TODO) Stripe UI handoff for payment**
9. **App polls backend for payment status**
10. **User is shown success/failure page**

---

## Data Flow
- **OrderModel**: Represents all order/payment fields (id, stripeSessionId, paymentIntentId, paymentStatus, currency, subtotal, tax, shippingCost, total, items, shippingAddress, createdAt)
- **OrderController**: Handles order creation, payment intent, Stripe handoff (TODO), and status polling
- **ApiService**: Handles HTTP requests to backend (no auth required)

---

## Key Files
- `lib/model/orderModel.dart`: Order data structure
- `lib/controller/orderController.dart`: Checkout/payment logic
- `lib/views/pages/checkoutpage/checkoutPage.dart`: Checkout UI
- `lib/views/pages/orderpage/orderSuccessPage.dart`: Success UI
- `lib/views/pages/orderpage/orderFailurePage.dart`: Failure UI
- `lib/api/ApiService.dart`: HTTP API calls

---

## Stripe Integration Details
- **Backend**: Handles all Stripe logic (session/payment intent creation, webhook for payment status)
- **Frontend**: Only interacts with backend endpoints, never with Stripe directly
- **Payment Status**: App polls backend for payment result after order is placed
- **Future**: Stripe UI handoff (e.g., webview or native Stripe SDK) can be added in `OrderController` where marked as TODO

---

## Sequence Diagram

```
User -> App: Place Order
App -> Backend: POST /orders (with cart, shipping)
Backend -> Stripe: Create PaymentIntent/Session
Backend -> App: Return order info (incl. Stripe IDs)
App: (TODO) Handoff to Stripe UI for payment
App -> Backend: Poll payment status
Backend -> Stripe: Check payment status
Backend -> App: Return payment status
App: Show success/failure page
```

---

## Notes
- All API endpoints are public (no auth)
- Product/category data is local for now; API fetch code is commented for future use
- Stripe UI handoff is a planned enhancement (see `OrderController`)

---

## How to Extend
- To enable Stripe UI handoff, implement the TODO in `OrderController`
- To switch product/category to API, uncomment API fetch code in controllers

---

For questions, see the code comments in the files above or ask the maintainers.
