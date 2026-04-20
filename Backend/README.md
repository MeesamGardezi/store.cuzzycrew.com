# Backend API (store.cuzzycrew.com)

## Endpoint quick reference

| Method | Path | Auth | Returns (success `data` shape) |
| :--- | :--- | :--- | :--- |
| GET | `/api/categories` | No | `{ categories: Category[] }` (frontend-shaped) |
| GET | `/api/products` | No | `{ products: Product[] }` (frontend-shaped) |
| GET | `/api/products/:id` | No | `Product` (frontend-shaped) |
| GET | `/api/website-banner` | No | `{ images: BannerImage[] }` |
| POST | `/api/orders` | Optional | `{ order: Order, items: OrderItem[] }` |
| GET | `/api/orders` | Yes | `{ items: Order[], nextCursor: string \| null }` |
| GET | `/api/orders/:orderId` | Yes | `{ order: Order, items: OrderItem[] }` |
| POST | `/api/orders/:orderId/cancel` | Yes | `{ order: Order, items: OrderItem[] }` |
| POST | `/api/auth/register` | No | `{ user: { id, email, role }, tokens: { accessToken, refreshToken } }` |
| POST | `/api/auth/login` | No | `{ user: { id, email, role }, tokens: { accessToken, refreshToken } }` |
| POST | `/api/auth/refresh` | No | `{ accessToken: string }` |
| POST | `/api/admin/categories` | ADMIN | `Category` |
| PATCH | `/api/admin/categories/:id` | ADMIN | `Category` |
| DELETE | `/api/admin/categories/:id` | ADMIN | `Category` |
| POST | `/api/admin/products` | ADMIN | `Product` (stored to Firestore; app endpoints normalize to frontend shape) |
| PATCH | `/api/admin/products/:id` | ADMIN | `Product` |
| DELETE | `/api/admin/products/:id` | ADMIN | `Product` |
| POST | `/api/admin/variants` | ADMIN | `Variant` |
| PATCH | `/api/admin/variants/:id/stock` | ADMIN | `Variant` |
| PUT | `/api/admin/website-banner` | ADMIN | `{ images: BannerImage[] }` |
| POST | `/api/create-checkout-session` | No | `{ sessionId: string, checkoutDraftId: string }` (if enabled) |
| POST | `/api/webhook` | No | `{ ok: true }` (if enabled) |

## Overview
This folder contains the Node.js/Express backend using a layered architecture:

- `src/routes` (HTTP routes)
- `src/controllers` (request/response)
- `src/services` (business logic)
- `src/repositories` (Firestore data access)
- `src/middleware` (auth, validation, etc.)
- `src/validators` (Zod request schemas)
- `src/config` (env + firebase)
- `src/utils` (helpers)

## Dependencies

### Runtime (`dependencies`)
- `bcrypt`
- `cors`
- `dotenv`
- `express`
- `express-rate-limit`
- `firebase-admin`
- `helmet`
- `jsonwebtoken`
- `morgan`
- `multer`
- `pino`
- `pino-http`
- `paddle`
- `uuid`
- `zod`

### Development (`devDependencies`)
- `nodemon`

All APIs are served under the `/api` prefix.


## Requirements
- Node.js
- Firebase project with Firestore enabled
- Paddle account and notification destination for webhooks

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
- `PADDLE_API_KEY`
- `PADDLE_WEBHOOK_SECRET`
- `PADDLE_CHECKOUT_URL`
- `PADDLE_RETURN_URL`

### Common variables
- `NODE_ENV` (`development` | `test` | `production`)
- `CORS_ORIGIN` (default `*`)
- `RATE_LIMIT_GLOBAL_MAX` (default `600`)

### Firebase credentials (recommended)
Local development can use a service account JSON file path:

- `FIREBASE_PROJECT_ID=store-cuzzycrew-com`
- `FIREBASE_SERVICE_ACCOUNT_PATH=./store-cuzzycrew-com-firebase-adminsdk-xxxx.json`

Notes:
- The service account JSON contains a private key. Do not commit it.
- Firestore must be created/enabled in Firebase Console; otherwise queries can fail with gRPC `5 NOT_FOUND`.

### Firebase credentials on Vercel/serverless
Use:

- `FIREBASE_SERVICE_ACCOUNT_JSON` = the full JSON content (as a string)
- `FIREBASE_PROJECT_ID` = your Firebase project id

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

## Data model (high level)
- **`categories`**: app categories (must match `categories.json` item shape)
- **`products`**: app products (must match `products.json` item shape)
- **`orders`**: orders created by `POST /api/orders`
- **`orderItems`**: items for each order

Products are expected to contain the frontend fields (e.g. `images`, `story`, `sizeGuideImage`, etc.) so that `GET /api/products` matches the frontend JSON.

The backend will also tolerate backend-specific fields (e.g. `priceMin` in cents) and will normalize them for the app endpoints.


## Admin product image upload (Firebase Storage)

`POST /api/admin/products` and `PATCH /api/admin/products/:id` support both:

- JSON (`Content-Type: application/json`)
- Multipart file upload (`Content-Type: multipart/form-data`)

### Multipart format
Send one text field:

- `data` = JSON string for the product payload

And any of these file fields:

- `thumbnail` (single file)
- `sizeGuideImage` (single file)
- `images` (multiple files)

Uploaded files are stored in Firebase Storage and the product document is written with the frontend-shaped fields:

- `thumbnail: <publicUrl>`
- `sizeGuideImage: <publicUrl>`
- `images: [<publicUrl>, ...]`

### Example (curl)

```bash
curl -X POST "http://localhost:4000/api/admin/products" \
  -H "Authorization: Bearer <ADMIN_ACCESS_TOKEN>" \
  -F 'data={
    "name":"HEAVYWEIGHT HOODIE / BONE",
    "slug":"heavyweight-hoodie-bone",
    "category":"hoodies",
    "dateAdded":"2026-02-20T10:00:00Z",
    "shortName":"Cuzzy Heavy Hoodie",
    "price":120.0,
    "currency":"USD",
    "unit":"piece",
    "availableUnits":48,
    "sizes":["XS","S","M","L","XL"],
    "story":"Crafted with premium heavyweight cotton...",
    "colorVariants":[
      {"colorName":"Bone","colorHex":"#D9D2C5","image":""},
      {"colorName":"Onyx","colorHex":"#2B2B2B","image":""}
    ]
  }' \
  -F "thumbnail=@./thumbnail.jpg" \
  -F "sizeGuideImage=@./size-guide.jpg" \
  -F "images=@./img1.jpg" \
  -F "images=@./img2.jpg"
```

Notes:
- `colorVariants[].image` is not automatically linked to uploaded files.
- If you provide `thumbnail`/`sizeGuideImage`/`images` URLs in the JSON payload, they will be used when no file is uploaded for that field.

### Firebase Storage configuration
Firebase Admin must be initialized with a Storage bucket. By default this code uses:

- `<FIREBASE_PROJECT_ID>.appspot.com`

Optionally you can set:

- `FIREBASE_STORAGE_BUCKET=<your-bucket-name>`

## API Endpoints

### Conventions
- **Base URL (local)**
  - `http://localhost:4000/api`
- **Base URL (Vercel)**
  - `https://<your-backend>.vercel.app/api`
- **Content-Type**
  - `Content-Type: application/json`
- **Auth header (when required)**
  - `Authorization: Bearer <accessToken>`

### Auth
- `POST /api/auth/register`
- `POST /api/auth/login` (rate-limited)
- `POST /api/auth/refresh`

#### `POST /api/auth/register`
Creates a user and returns access+refresh tokens.

Request body:
```json
{
  "email": "user1@cuzzycrew.com",
  "password": "Password123!",
  "firstName": "User",
  "lastName": "One"
}
```

#### `POST /api/auth/login`
Logs in a user and returns access+refresh tokens.

Request body:
```json
{
  "email": "user1@cuzzycrew.com",
  "password": "Password123!"
}
```

#### `POST /api/auth/refresh`
Exchanges a refresh token for a new access token.

Request body:
```json
{
  "refreshToken": "<refreshToken>"
}
```

### Public app endpoints (frontend-shaped)
These endpoints are the canonical endpoints used by the frontend.

- `GET /api/categories`
- `GET /api/products`
- `GET /api/products/:id`
- `GET /api/website-banner`

#### `GET /api/categories`
Returns data shaped like `Frontend/.../assets/json/categories.json`.

Response:
```json
{
  "success": true,
  "data": {
    "categories": []
  },
  "message": ""
}
```

#### `GET /api/products`
Returns data shaped like `Frontend/.../assets/json/products.json`.

Response:
```json
{
  "success": true,
  "data": {
    "products": []
  },
  "message": ""
}
```

Each product object includes:
- `id`
- `category`
- `dateAdded`
- `name`
- `shortName`
- `price`
- `currency`
- `unit`
- `availableUnits`
- `thumbnail`
- `images`
- `sizeGuideImage`
- `sizes`
- `story`
- `colorVariants`

#### `GET /api/products/:id`
Returns a single product by document id.

Response:
```json
{
  "success": true,
  "data": {
    "id": "prod_cap_slate_03",
    "category": "caps",
    "dateAdded": "2026-02-10T10:00:00Z",
    "name": "CREW ESSENTIAL CAP / SLATE",
    "shortName": "Essential Cap",
    "price": 35,
    "currency": "USD",
    "unit": "piece",
    "availableUnits": 0,
    "thumbnail": "https://...",
    "images": [],
    "sizeGuideImage": "https://...",
    "sizes": ["ONE SIZE"],
    "story": "...",
    "colorVariants": []
  },
  "message": ""
}
```

#### `GET /api/website-banner`
Returns website banner image data shaped like the frontend asset.

Response:
```json
{
  "success": true,
  "data": {
    "images": []
  },
  "message": ""
}
```

### Orders

#### `POST /api/orders`
Creates an order using a minimal payload (cart is stored client-side).

Auth:
- Optional (if authenticated, `userId` is attached to the order)

Headers:
- Optional `idempotency-key: <string>`

Request body:
```json
{
  "items": [
    {
      "productId": "prod_cap_slate_03",
      "quantity": 1,
      "selectedSize": "ONE SIZE",
      "selectedColor": "#000000"
    }
  ],
  "currency": "USD",
  "shippingAddress": {
    "fullName": "Hiba Rafique",
    "phone": "+92-300-1234567",
    "addressLine1": "Street 12, House 34",
    "city": "Rawalpindi",
    "postalCode": "46220",
    "country": "PK"
  }
}
```

Behavior:
- Validates product exists and is not deleted
- Validates `availableUnits` is sufficient
- Computes totals using product `price` or `priceMin` fallback
- Decrements `availableUnits`
- Writes `orders` + `orderItems`

Response:
```json
{
  "success": true,
  "data": {
    "order": {},
    "items": []
  },
  "message": ""
}
```

#### `GET /api/orders`
Lists orders for the authenticated user.

Auth:
- Required

Query params:
- `limit` (1-50)
- `cursor` (order id)

#### `GET /api/orders/:orderId`
Gets a single order for the authenticated user.

Auth:
- Required

#### `POST /api/orders/:orderId/cancel`
Cancels an order if its status is `PENDING_PAYMENT`.

Auth:
- Required

### Payments (Paddle)

- `POST /api/payments/checkout`
- `POST /api/payments/webhook`
- `GET /api/payments/:orderId/status`

Note: The checkout endpoint returns a hosted Paddle URL plus order metadata. Webhooks are verified with `Paddle-Signature`.

### Admin (ADMIN role)

#### Categories
- `POST /api/admin/categories`
- `PATCH /api/admin/categories/:id`
- `DELETE /api/admin/categories/:id`

#### Products
- `POST /api/admin/products`
- `PATCH /api/admin/products/:id`
- `DELETE /api/admin/products/:id`

#### Variants / stock
- `POST /api/admin/variants`
- `PATCH /api/admin/variants/:id/stock`

#### Site content
- `PUT /api/admin/website-banner`

## Postman testing (quick)

### Base
- Base URL: `http://localhost:4000/api`
- Headers:
  - JSON: `Content-Type: application/json`
  - Auth (when required): `Authorization: Bearer <token>`



## Deployment (Vercel)

### Required env vars on Vercel
Set these for the Vercel project (Production recommended):

- `NODE_ENV=production`
- `CORS_ORIGIN=<your frontend URL>`
- `JWT_ACCESS_SECRET` (min 20)
- `JWT_REFRESH_SECRET` (min 20)
- `PADDLE_API_KEY`
- `PADDLE_WEBHOOK_SECRET`
- `PADDLE_CHECKOUT_URL`
- `PADDLE_RETURN_URL`
- `FIREBASE_PROJECT_ID=<project id>`
- `FIREBASE_SERVICE_ACCOUNT_JSON=<full JSON string>`

Do not set `FIREBASE_SERVICE_ACCOUNT_PATH` on Vercel.

### Debugging
To view production logs:

```bash
vercel logs --prod
```

