# Backend API (store.cuzzycrew.com)

## Overview
This folder contains the Node.js/Express backend using a layered architecture:

- `src/routes` (HTTP routes)
- `src/controllers` (request/response)
- `src/services` (business logic)
- `src/repositories` (Firestore data access)
- `src/middleware` (auth, validation, etc.)
- `src/validators` (Zod request schemas)
- `src/config` (env + firebase + stripe)
- `src/utils` (helpers)

All APIs are served under the `/api` prefix.

## Requirements
- Node.js
- Firebase project with Firestore enabled
- Stripe account (test keys are fine for local)

## Install & Run

```bash
npm install
npm run dev
```

Server starts on `PORT` (default `4000`).

## Environment configuration
Copy the example file and fill in secrets:

```bash
# Windows (PowerShell/cmd): just create the file manually
# Create Backend/.env using Backend/.env.example as a template
```

### Required variables
- `JWT_ACCESS_SECRET` (min 20 chars)
- `JWT_REFRESH_SECRET` (min 20 chars)
- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`

### Firebase credentials (recommended)
Use a service account JSON file path:

- `FIREBASE_PROJECT_ID=store-cuzzycrew-com`
- `FIREBASE_SERVICE_ACCOUNT_PATH=./store-cuzzycrew-com-firebase-adminsdk-xxxx.json`

Notes:
- The service account JSON contains a private key. Do not commit it.
- Firestore must be created/enabled in Firebase Console; otherwise queries can fail with gRPC `5 NOT_FOUND`.

## Response format

### Success
```json
{ "success": true, "data": {}, "message": "" }
```

### Error
```json
{
  "success": false,
  "error": { "code": "", "message": "", "details": [] }
}
```

## Authentication

### Access token
Send in requests:

- `Authorization: Bearer <accessToken>`

### Admin routes
Admin routes require the logged-in user to have `role: "ADMIN"` in the Firestore `users/{userId}` document.

## Seeding Firestore (minimum)
To test catalog/cart/orders you should create at least:

### `categories/cat_hoodies_001`
```json
{
  "name": "Hoodies",
  "deletedAt": null,
  "createdAt": "2026-02-27T00:00:00.000Z",
  "updatedAt": "2026-02-27T00:00:00.000Z"
}
```

### `products/prod_hoodie_001`
```json
{
  "name": "Cuzzy Crew Hoodie",
  "slug": "cuzzy-crew-hoodie",
  "description": "Premium hoodie",
  "categoryId": "cat_hoodies_001",
  "priceMin": 4999,
  "colors": ["Black", "Cream"],
  "sizes": ["S", "M", "L"],
  "deletedAt": null,
  "createdAt": "2026-02-27T00:00:00.000Z",
  "updatedAt": "2026-02-27T00:00:00.000Z"
}
```

### `productVariants/var_hoodie_black_m_001`
```json
{
  "productId": "prod_hoodie_001",
  "label": "Black / M",
  "price": 4999,
  "stock": 20,
  "deletedAt": null,
  "createdAt": "2026-02-27T00:00:00.000Z",
  "updatedAt": "2026-02-27T00:00:00.000Z"
}
```

## API Endpoints

### Auth
- `POST /api/auth/register`
- `POST /api/auth/login` (rate-limited)
- `POST /api/auth/refresh`

### Catalog
- `GET /api/categories`
- `GET /api/products` (pagination/filter/sort)
- `GET /api/products/:slug`
- `GET /api/products/:id/recommendations`

### Cart (guest-first)
Guest requests require `x-session-token`.

- `GET /api/cart`
- `POST /api/cart/items`
- `PATCH /api/cart/items/:itemId`
- `DELETE /api/cart/items/:itemId`
- `POST /api/cart/apply-coupon`
- `DELETE /api/cart/coupon`

### Checkout & Orders
- `POST /api/checkout/quote`
- `POST /api/orders` (requires `Idempotency-Key`)
- `GET /api/orders`
- `GET /api/orders/:orderId`
- `POST /api/orders/:orderId/cancel`

### Payments (Stripe)
- `POST /api/payments/intent`
- `POST /api/payments/webhook`
- `GET /api/payments/:orderId/status`

### Admin (ADMIN role)
- `POST /api/admin/products`
- `PATCH /api/admin/products/:id`
- `DELETE /api/admin/products/:id`
- `POST /api/admin/variants`
- `PATCH /api/admin/variants/:id/stock`
- `GET /api/admin/orders`
- `PATCH /api/admin/orders/:id/status`
- `POST /api/admin/coupons`
- `GET /api/admin/dashboard`

## Postman testing (quick)

### Base
- Base URL: `http://localhost:4000/api`
- Headers:
  - JSON: `Content-Type: application/json`
  - Guest cart: `x-session-token: guest_123456789`
  - Auth: `Authorization: Bearer <token>`

### Register
`POST /api/auth/register`
```json
{
  "email": "user1@cuzzycrew.com",
  "password": "Password123!",
  "firstName": "User",
  "lastName": "One"
}
```

### Login
`POST /api/auth/login`
```json
{
  "email": "user1@cuzzycrew.com",
  "password": "Password123!",
  "sessionToken": "guest_123456789"
}
```

### Create product (admin)
`POST /api/admin/products`
```json
{
  "name": "Cuzzy Crew Hoodie",
  "slug": "cuzzy-crew-hoodie",
  "description": "Premium hoodie",
  "categoryId": "cat_hoodies_001",
  "priceMin": 4999,
  "colors": ["Black"],
  "sizes": ["M"]
}
```

### Create variant (admin)
`POST /api/admin/variants`
```json
{
  "productId": "<PRODUCT_ID>",
  "sku": "HOODIE-BLK-M-001",
  "label": "Black / M",
  "price": 4999,
  "stock": 20
}
```



## Flutter integration (Dart)
Below are minimal examples using the `http` package.

### Add dependency
In `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.2.2
```

### API client helper
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;
  String? accessToken;
  String sessionToken = 'guest_123456789';

  Map<String, String> _headers({bool auth = false, bool guest = false}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (auth && accessToken != null) h['Authorization'] = 'Bearer $accessToken';
    if (guest) h['x-session-token'] = sessionToken;
    return h;
  }

  Future<Map<String, dynamic>> getJson(String path, {bool auth = false, bool guest = false}) async {
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: _headers(auth: auth, guest: guest));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postJson(String path, Object body, {bool auth = false, bool guest = false, Map<String, String>? extraHeaders}) async {
    final headers = _headers(auth: auth, guest: guest);
    if (extraHeaders != null) headers.addAll(extraHeaders);

    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );

    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
```

### Register
```dart
final api = ApiClient(baseUrl: 'http://localhost:4000/api');
final res = await api.postJson('/auth/register', {
  'email': 'user1@cuzzycrew.com',
  'password': 'Password123!',
  'firstName': 'User',
  'lastName': 'One',
});
```

### Login (store accessToken)
```dart
final res = await api.postJson('/auth/login', {
  'email': 'user1@cuzzycrew.com',
  'password': 'Password123!',
  'sessionToken': api.sessionToken,
});

api.accessToken = (res['data']['tokens']['accessToken'] as String);
```

### Main page: fetch categories + products
```dart
final cats = await api.getJson('/categories');
final products = await api.getJson('/products?limit=20&sort=newest');
```

### Guest cart: add item
```dart
final cart = await api.postJson('/cart/items', {
  'variantId': 'var_hoodie_black_m_001',
  'quantity': 2,
}, guest: true);
```

### Create order (requires auth + Idempotency-Key)
```dart
final order = await api.postJson(
  '/orders',
  {'shippingAddressId': 'shipaddr_test_1'},
  auth: true,
  extraHeaders: {'Idempotency-Key': 'idem_${DateTime.now().millisecondsSinceEpoch}'},
);
```

## Notes
- For Android emulator calling your PC localhost, use `http://10.0.2.2:4000/api`.
- For iOS simulator use `http://localhost:4000/api`.

