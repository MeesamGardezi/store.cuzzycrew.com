# Cuzzy Dashboard - Flutter App

A clean, minimal Flutter dashboard for viewing orders, products, and categories with email/password authentication.

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point, theme setup
├── models/
│   ├── order.dart           # Order model with status enum
│   ├── product.dart         # Product model
│   └── category.dart        # Category model
├── services/
│   └── api_service.dart     # HTTP requests with logging
├── controllers/
│   ├── auth_controller.dart      # Authentication state
│   ├── product_controller.dart   # Products & categories fetch
│   └── order_controller.dart     # Orders fetch
└── pages/
    ├── login_page.dart      # Email/password login UI
    ├── home_page.dart       # Main navigation (3 tabs)
    ├── orders_page.dart     # Orders list view
    ├── products_page.dart   # Products grid view
    └── categories_page.dart # Categories list view
```

## 🎨 Architecture

- **Provider Pattern**: Used for state management (ChangeNotifier)
- **Separation of Concerns**: Models, Services, Controllers, Pages clearly separated
- **Clean Code**: No spaghetti code, single responsibility principle

## 🚀 Getting Started

### Prerequisites
- Flutter SDK: ^3.7.2
- Dart: ^3.7.2

### Installation

```bash
cd Dashboard
flutter pub get
```

### Run the App

**Development (Local Backend)**
```bash
flutter run -d chrome
```

For local development, the dashboard now points to `http://localhost:4000`.

**Production (Vercel Backend)**
Update `baseUrl` in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:4000';
```

## 📄 File Details

### `lib/main.dart`
- Initializes MultiProvider with 3 controllers
- Sets up Material Design 3 theme
- Conditional rendering: LoginPage or HomePage based on auth state

### `lib/models/`

**order.dart**
```dart
enum OrderStatus { pending, processing, delivered, cancelled }

class Order {
  final String id;
  final String orderNumber;
  final OrderStatus status;
  final double total;
  final String currency;
  final DateTime createdAt;
}
```

**product.dart**
```dart
class Product {
  final String id;
  final String name;
  final double price;
  final String thumbnail;
  final String category;
  final int availableUnits;
}
```

**category.dart**
```dart
class Category {
  final String id;
  final String name;
  final String thumbnail;
  final bool launched;
}
```

### `lib/services/api_service.dart`

Static methods for API calls with logging:
- `ApiService.get(endpoint)` - GET requests
- `ApiService.post(endpoint, body)` - POST requests

Example:
```dart
final response = await ApiService.get('/api/products');
final products = (response['data']['products'] as List)
    .map((item) => Product.fromJson(item))
    .toList();
```

### `lib/controllers/`

**auth_controller.dart**
- `login(email, password)` - Validates and authenticates user
- `logout()` - Clears auth state
- Properties: `isLoggedIn`, `userEmail`, `isLoading`, `errorMessage`

**product_controller.dart**
- `fetchProducts()` - GET /api/products
- `fetchCategories()` - GET /api/categories
- Returns: List<Product>, List<Category>

**order_controller.dart**
- `fetchOrders()` - GET /api/orders
- Returns: List<Order>

### `lib/pages/`

**login_page.dart**
- Email & password input fields
- Form validation
- Error message display
- Loading state

**home_page.dart**
- 3-tab navigation (Orders, Products, Categories)
- AppBar with user email and logout option
- BottomNavigationBar for page switching

**orders_page.dart**
- List view of all orders
- Status badges (Pending, Processing, Delivered, Cancelled)
- Date and total amount display

**products_page.dart**
- Grid view layout (2 columns)
- Product cards with image, name, price, stock
- Error and empty states

**categories_page.dart**
- List view with thumbnails
- Active/Inactive status indicators
- Live/Draft chips

## 🔧 API Endpoints Used

| Method | Endpoint | Response Structure |
|--------|----------|-------------------|
| GET | `/api/products` | `{ data: { products: [...] } }` |
| GET | `/api/categories` | `{ data: { categories: [...] } }` |
| GET | `/api/orders` | `{ data: { orders: [...] } }` |

## 🔐 Authentication

Currently using **mock authentication**. To connect to backend:

```dart
// In auth_controller.dart, replace mock with:
final response = await ApiService.post('/api/auth/login', {
  'email': email,
  'password': password,
});
```

## 🎯 Features

- ✅ Email/Password login form
- ✅ Three-page navigation with bottom nav
- ✅ Orders list view
- ✅ Products grid view with images
- ✅ Categories list view
- ✅ API logging (🔵 request, ✅ success, ❌ error)
- ✅ Loading states
- ✅ Error handling with retry
- ✅ Empty state UI
- ✅ Provider state management
- ✅ Clean, maintainable code structure

## 📝 Best Practices Followed

1. **Model Layer**: Strongly typed models with factory constructors
2. **Service Layer**: Centralized API calls with error handling
3. **Controller Layer**: Business logic separated from UI
4. **View Layer**: Widget composition, no complex logic in pages
5. **State Management**: Provider pattern for reactive updates
6. **Error Handling**: Try-catch blocks with user-friendly messages
7. **Logging**: Structured debug logs for API calls
8. **Code Organization**: Clear folder structure by responsibility

## 🚀 Next Steps

- [ ] Integrate real backend authentication
- [ ] Add token-based persistence (local storage)
- [ ] Implement order detail page
- [ ] Add product detail page
- [ ] Search and filter functionality
- [ ] Pull-to-refresh capability
- [ ] Add animations and transitions

## 💡 Tips

- Modify colors in `main.dart` theme configuration
- Add fonts in `pubspec.yaml`
- Update backend URL for production in `api_service.dart`
- Add logging interceptor for more detailed API debugging

---

**Built with clean architecture and Flutter best practices** 🎯
