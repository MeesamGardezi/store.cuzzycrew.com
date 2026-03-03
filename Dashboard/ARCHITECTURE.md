
# Architecture Document

## Overview

Cuzzy Dashboard follows **Clean Architecture** principles with a clear separation of concerns across models, services, controllers, and pages.

## Architecture Layers

```
┌────────────────────────────────────────────┐
│         Presentation Layer (UI)            │
│     - login_page.dart                      │
│     - home_page.dart                       │
│     - orders_page.dart                     │
│     - products_page.dart                   │
│     - categories_page.dart                 │
└─────────────────┬──────────────────────────┘
                  │
                  ↓ Observes/Calls
┌────────────────────────────────────────────┐
│      Business Logic Layer (Controllers)    │
│     - auth_controller.dart                 │
│     - product_controller.dart              │
│     - order_controller.dart                │
│                                            │
│     Pattern: ChangeNotifier + Provider    │
└─────────────────┬──────────────────────────┘
                  │
                  ↓ Uses
┌────────────────────────────────────────────┐
│      Services Layer (External APIs)        │
│     - api_service.dart                     │
│                                            │
│     Responsibility: HTTP, logging          │
└─────────────────┬──────────────────────────┘
                  │
                  ↓ Parses
┌────────────────────────────────────────────┐
│       Data Layer (Models)                  │
│     - order.dart                           │
│     - product.dart                         │
│     - category.dart                        │
│                                            │
│     Responsibility: Type safety, parsing   │
└────────────────────────────────────────────┘
```

## Design Patterns Used

### 1. Provider Pattern (State Management)

**Why?** 
- Reactive updates
- Loose coupling between UI and business logic
- Easy testing

**Example:**
```dart
// Controller
class ProductController extends ChangeNotifier {
  List<Product> _products = [];
  
  Future<void> fetchProducts() async {
    _products = await api.get('/api/products');
    notifyListeners();  // Notify UI to rebuild
  }
}

// In UI
Consumer<ProductController>(
  builder: (context, controller, _) {
    return ListView(
      children: controller.products.map((p) => ProductCard(p)).toList(),
    );
  },
)
```

### 2. Repository Pattern (via Services)

**Why?**
- Centralize API calls
- Easy to mock for testing
- Single source of truth

**Structure:**
```
Pages → Controllers → Services → Backend API
```

### 3. Model Factory Pattern

**Why?**
- Encapsulate JSON parsing logic
- Type-safe data handling
- Clear data contracts

**Example:**
```dart
class Product {
  final String id;
  final String name;
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
```

## Data Flow

### Authentication Flow

```
LoginPage
    ↓
User enters email/password
    ↓
onLoginButtonPressed()
    ↓
AuthController.login(email, password)
    ↓
Mock validation OR ApiService.post('/auth/login')
    ↓
AuthController updates state
    ↓
Provider notifies listeners
    ↓
main.dart rebuilds
    ↓
isLoggedIn ? HomePage : LoginPage
```

### Data Fetch Flow

```
HomePage (mounted)
    ↓
ProductsPage.initState()
    ↓
WidgetsBinding.addPostFrameCallback()
    ↓
ProductController.fetchProducts()
    ↓
ApiService.get('/api/products')
    ↓
HTTP GET + Logging
    ↓
Parse JSON → List<Product>
    ↓
notifyListeners()
    ↓
Consumer rebuilds ProductsPage
    ↓
GridView displays products
```

## File Responsibilities

### Models (`lib/models/`)

**Responsibility:** Data representation and parsing

```dart
// Product.dart
- Constructor with all properties
- factory.fromJson() for API parsing
- toString() for debugging
```

**Single Responsibility:** Model is responsible ONLY for data structure, not fetching or business logic.

### Services (`lib/services/`)

**Responsibility:** External communication and logging

```dart
// api_service.dart
- Static HTTP methods (get, post)
- Request/response logging
- Error handling (throw exceptions)
```

**Benefits:**
- Can be mocked in tests
- Centralized logging
- Consistent error handling

### Controllers (`lib/controllers/`)

**Responsibility:** Business logic and state management

```dart
// product_controller.dart
- Fetch data via services
- Parse responses into models
- Maintain state
- Notify listeners
```

**Key Methods:**
- `fetchProducts()` - Orchestrate data fetching
- `notifyListeners()` - Trigger UI rebuilds

### Pages (`lib/pages/`)

**Responsibility:** UI rendering only

```dart
// products_page.dart
- Display data from controller
- Handle user interactions
- Show loading/error states
```

**Rules:**
- No business logic
- No direct API calls
- Only use Controller data
- Responsive to state changes via Consumer

## State Management Flow

### Why Provider?

1. **Reactive** - UI updates automatically when state changes
2. **Simple** - Less boilerplate than other solutions
3. **Performant** - Only rebuilds affected widgets
4. **Testable** - Controllers are independent of UI

### Multi-Provider Setup

```dart
// main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthController()),
    ChangeNotifierProvider(create: (_) => ProductController()),
    ChangeNotifierProvider(create: (_) => OrderController()),
  ],
  child: MaterialApp(...)
)
```

**Benefits:**
- All controllers available throughout the app
- Single instance per controller
- Lifecycle managed by Flutter

### Consumer Widget

```dart
Consumer<ProductController>(
  builder: (context, controller, _) {
    if (controller.isLoading) {
      return CircularProgressIndicator();
    }
    return GridView(...);
  }
)
```

## Error Handling Strategy

### At Service Level
```dart
catch (e) {
  debugPrint('❌ [API] Error: $e');
  rethrow;  // Let controller handle
}
```

### At Controller Level
```dart
catch (e) {
  _errorMessage = e.toString();
  notifyListeners();
}
```

### At UI Level
```dart
if (controller.errorMessage != null) {
  return ErrorWidget(
    message: controller.errorMessage,
    onRetry: () => controller.fetchData(),
  );
}
```

## API Integration Points

### 1. Products Endpoint
```
GET /api/products
Response: { data: { products: [...] } }

Parsed by: ProductModel.fromJson()
Stored in: ProductController._products
```

### 2. Categories Endpoint
```
GET /api/categories
Response: { data: { categories: [...] } }

Parsed by: CategoryModel.fromJson()
Stored in: ProductController._categories
```

### 3. Orders Endpoint
```
GET /api/orders
Response: { data: { orders: [...] } }

Parsed by: OrderModel.fromJson()
Stored in: OrderController._orders
```

## Scalability Considerations

### Adding New Features

1. **Add a new page type**
   - Create `lib/pages/new_page.dart`
   - Create controller if needed: `lib/controllers/new_controller.dart`

2. **Add new data model**
   - Create `lib/models/new_model.dart` with factory.fromJson()

3. **Add new API endpoint**
   - Add method in `api_service.dart`
   - Call from appropriate controller

### Example: Adding a Cart Feature

```
1. Create lib/models/cart_item.dart
2. Create lib/controllers/cart_controller.dart
3. Create lib/pages/cart_page.dart
4. Add CartController to MultiProvider in main.dart
5. Add CartPage to navigation in home_page.dart
```

## Best Practices Implemented

### ✅ Single Responsibility Principle
- Each file/class has one clear purpose
- Models handle data, Services handle communication, Controllers handle business logic

### ✅ Dependency Injection
- Controllers don't create ApiService instances
- Services are injected through constructor

### ✅ Error Handling
- All network calls wrapped in try-catch
- Errors propagated to UI layer
- Graceful fallbacks for missing data

### ✅ Logging
- Structured log messages with emojis
- Easy debugging with request/response timing

### ✅ Type Safety
- Strongly typed models
- Null-coalescing operators for defaults
- No dynamic types

### ✅ Reactive UI
- Provider pattern for automatic updates
- No manual setState() calls
- Efficient rebuilds

## Testing Strategy

### Unit Testing Controllers
```dart
test('fetches products', () async {
  final controller = ProductController();
  await controller.fetchProducts();
  
  expect(controller.products, isNotEmpty);
  expect(controller.isLoading, isFalse);
});
```

### Mocking API Calls
```dart
// Mock HttpClient
final mockHttp = MockClient((request) async {
  return Response(jsonEncode({'data': {...}}), 200);
});

// Pass to ApiService
```

## Performance Optimizations

1. **Lazy Loading** - Data fetched only when page is shown
2. **Efficient Rebuilds** - Consumer only rebuilds when data changes
3. **Image Caching** - Flutter handles network image caching
4. **Pagination Ready** - API already supports pagination (future enhancement)

## Security Considerations

1. **API Logging** - No sensitive data logged
2. **Token Storage** - Ready for secure storage implementation
3. **HTTPS** - Production URL uses HTTPS
4. **Input Validation** - Email format checked client-side

## Future Enhancements

- [ ] Implement real credential authentication with backend
- [ ] Add JWT token persistence
- [ ] Implement refresh token logic
- [ ] Add database for offline support
- [ ] Implement pagination for large datasets
- [ ] Add search and filter functionality
- [ ] Add animations and transitions
- [ ] Implement dark mode support
- [ ] Add analytics tracking
- [ ] Cache responses locally

---

**This architecture ensures clean, maintainable, and scalable code** 🎯
