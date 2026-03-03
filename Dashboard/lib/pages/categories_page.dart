import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../controllers/product_controller.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
      body: Consumer<ProductController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(controller.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchCategories(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.category_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('No categories found'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading:
                      category.thumbnail.isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              category.thumbnail,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                            ),
                          )
                          : Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.category),
                          ),
                  title: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    category.launched ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: category.launched ? Colors.green : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text('Delete Category?'),
                                content: Text(
                                  'Are you sure you want to delete "${category.name}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      controller.deleteCategory(category.id);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      }
                    },
                    itemBuilder:
                        (BuildContext context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final tagsController = TextEditingController();
    final sortOrderController = TextEditingController(text: '1');
    Uint8List? thumbnailBytes;
    bool isLaunched = true;
    bool isFeatured = false;
    final ImagePicker _picker = ImagePicker();

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setState) => Dialog(
                  child: Container(
                    width: 600,
                    constraints: const BoxConstraints(maxHeight: 700),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add Category',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Category Name
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Category Name *',
                                hintText: 'e.g., Hoodies',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Description
                            TextField(
                              controller: descriptionController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Description *',
                                hintText:
                                    'Describe this category for customers...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Thumbnail Image Picker
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Category Thumbnail Image *',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (thumbnailBytes != null)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            child: Image.memory(
                                              thumbnailBytes!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final image = await _picker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (image != null) {
                                        final bytes = await image.readAsBytes();
                                        setState(() {
                                          thumbnailBytes = bytes;
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.image),
                                    label: const Text('Pick Thumbnail'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Tags
                            TextField(
                              controller: tagsController,
                              decoration: const InputDecoration(
                                labelText: 'Tags (comma-separated)',
                                hintText:
                                    'e.g., winter, oversized, best-seller',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Sort Order
                            TextField(
                              controller: sortOrderController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Sort Order',
                                hintText: '1',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Toggles
                            Theme(
                              data: Theme.of(context).copyWith(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Column(
                                children: [
                                  CheckboxListTile(
                                    title: const Text('Active (Launched)'),
                                    value: isLaunched,
                                    onChanged: (value) {
                                      setState(() {
                                        isLaunched = value ?? true;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  CheckboxListTile(
                                    title: const Text('Featured'),
                                    value: isFeatured,
                                    onChanged: (value) {
                                      setState(() {
                                        isFeatured = value ?? false;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    final category = {
                                      'thumbnailBytes': thumbnailBytes ?? '',
                                      'name': nameController.text,
                                      'slug': nameController.text
                                          .toLowerCase()
                                          .replaceAll(' ', '-'),
                                      'description': descriptionController.text,
                                      'launched': isLaunched,
                                      'featured': isFeatured,
                                      'sortOrder':
                                          int.tryParse(
                                            sortOrderController.text,
                                          ) ??
                                          1,
                                      'tags':
                                          tagsController.text
                                              .split(',')
                                              .map((e) => e.trim())
                                              .where((e) => e.isNotEmpty)
                                              .toList(),
                                    };
                                    debugPrint(
                                      'Adding category: ${category.toString()}',
                                    );
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('Add Category'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ),
    );
  }
}
