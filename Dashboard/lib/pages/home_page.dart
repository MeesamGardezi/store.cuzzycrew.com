import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import 'orders_page.dart';
import 'products_page.dart';
import 'categories_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const OrdersPage(),
    const ProductsPage(),
    const CategoriesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuzzy Dashboard'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Consumer<AuthController>(
                builder:
                    (context, auth, _) => Text(
                      auth.userEmail ?? 'Guest',
                      style: const TextStyle(fontSize: 12),
                    ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            itemBuilder:
                (_) => [
                  const PopupMenuItem<String>(child: Text('Profile')),
                  
                  PopupMenuItem<String>(
                    onTap: () {
                      context.read<AuthController>().logout();
                    },
                    child: const Text('Logout'),
                  ),
                ],
            icon: const Icon(Icons.account_circle),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.receipt), label: 'Orders'),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
      ),
    );
  }
}
