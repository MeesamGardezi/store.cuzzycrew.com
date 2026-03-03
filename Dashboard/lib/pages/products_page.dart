import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controllers/product_controller.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        tooltip: 'Add Product',
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
                    onPressed: () => controller.fetchProducts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('No products found'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final product = controller.products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        product.thumbnail.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.thumbnail,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(Icons.image_not_supported),
                              ),
                            )
                            : const Icon(Icons.image_not_supported),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('${product.category} • \$${product.price}'),
                      Text(
                        'Stock: ${product.availableUnits}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder:
                        (ctx) => [
                          PopupMenuItem(
                            child: const Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder:
                                    (dialogCtx) => AlertDialog(
                                      title: const Text('Delete Product?'),
                                      content: Text(
                                        'Delete "${product.name}"?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(dialogCtx),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            controller.deleteProduct(
                                              product.id,
                                            );
                                            Navigator.pop(dialogCtx);
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                            },
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

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final shortNameController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();
    final currencyController = TextEditingController(text: 'USD');
    final unitController = TextEditingController(text: 'piece');
    final stockController = TextEditingController();
    final storyController = TextEditingController();
    final sizesController = TextEditingController();

    File? thumbnailFile;
    List<File> imageFiles = [];
    List<Map<String, dynamic>> colorVariants = [];
    File? sizeGuideImageFile;
    final ImagePicker _picker = ImagePicker();

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  child: Container(
                    width: 600,
                    constraints: const BoxConstraints(maxHeight: 800),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add Product',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Product Name
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Product Name *',
                                hintText: 'e.g., HEAVYWEIGHT HOODIE / BONE',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Short Name
                            TextField(
                              controller: shortNameController,
                              decoration: const InputDecoration(
                                labelText: 'Short Name',
                                hintText: 'e.g., Cuzzy Heavy Hoodie',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Category
                            TextField(
                              controller: categoryController,
                              decoration: const InputDecoration(
                                labelText: 'Category *',
                                hintText: 'hoodies, tees, caps, shoes, etc.',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Price & Currency
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: priceController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Price *',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: currencyController,
                                    decoration: const InputDecoration(
                                      labelText: 'Currency',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Unit & Stock
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: unitController,
                                    decoration: const InputDecoration(
                                      labelText: 'Unit',
                                      hintText: 'piece, pair',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: stockController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Available Units *',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
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
                                    'Thumbnail Image *',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (thumbnailFile != null)
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
                                            child: Image.file(
                                              thumbnailFile!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          thumbnailFile!.path.split('/').last,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
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
                                        setState(() {
                                          thumbnailFile = File(image.path);
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
                            // Additional Images Picker
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
                                    'Product Images',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (imageFiles.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children:
                                              imageFiles.asMap().entries.map((
                                                entry,
                                              ) {
                                                final index = entry.key;
                                                final file = entry.value;
                                                return Stack(
                                                  children: [
                                                    Container(
                                                      width: 80,
                                                      height: 80,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        child: Image.file(
                                                          file,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: -8,
                                                      right: -8,
                                                      child: IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            imageFiles.removeAt(
                                                              index,
                                                            );
                                                          });
                                                        },
                                                        icon: const Icon(
                                                          Icons.close_rounded,
                                                          color: Colors.red,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final images =
                                          await _picker.pickMultiImage();
                                      if (images.isNotEmpty) {
                                        setState(() {
                                          imageFiles.addAll(
                                            images
                                                .map((img) => File(img.path))
                                                .toList(),
                                          );
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.add_photo_alternate),
                                    label: const Text(
                                      'Add Images (Multi-select)',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Size Guide Image
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
                                    'Size Guide Image',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (sizeGuideImageFile != null)
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
                                            child: Image.file(
                                              sizeGuideImageFile!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final image = await _picker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (image != null) {
                                        setState(() {
                                          sizeGuideImageFile = File(image.path);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.image),
                                    label: const Text('Pick Size Guide'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Color Variants Section
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Color Variants',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder:
                                                (variantCtx) =>
                                                    _buildColorVariantDialog(
                                                      variantCtx,
                                                      setState,
                                                      colorVariants,
                                                      _picker,
                                                    ),
                                          );
                                        },
                                        icon: const Icon(Icons.add),
                                        label: const Text('Add Variant'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (colorVariants.isNotEmpty)
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: colorVariants.length,
                                      itemBuilder: (_, index) {
                                        final variant = colorVariants[index];
                                        return Card(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: ListTile(
                                            leading: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Color(
                                                  int.parse(
                                                    '0xff${(variant['colorHex'] as String).substring(1)}',
                                                  ),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              variant['colorName'] ?? '',
                                            ),
                                            subtitle: Text(
                                              variant['colorHex'] ?? '',
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  colorVariants.removeAt(index);
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  else
                                    const Text(
                                      'No color variants added',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: sizesController,
                              decoration: const InputDecoration(
                                labelText: 'Available Sizes (comma-separated)',
                                hintText: 'XS, S, M, L, XL',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Story
                            TextField(
                              controller: storyController,
                              decoration: const InputDecoration(
                                labelText: 'Product Story/Description',
                                hintText: 'Tell the story of this product...',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
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
                                    final product = {
                                      'name': nameController.text,
                                      'shortName': shortNameController.text,
                                      'category': categoryController.text,
                                      'price':
                                          double.tryParse(
                                            priceController.text,
                                          ) ??
                                          0,
                                      'currency': currencyController.text,
                                      'unit': unitController.text,
                                      'availableUnits':
                                          int.tryParse(stockController.text) ??
                                          0,
                                      'thumbnail': thumbnailFile?.path ?? '',
                                      'thumbnailFile': thumbnailFile,
                                      'images':
                                          imageFiles
                                              .map((f) => f.path)
                                              .toList(),
                                      'imageFiles': imageFiles,
                                      'sizes':
                                          sizesController.text
                                              .split(',')
                                              .map((e) => e.trim())
                                              .where((e) => e.isNotEmpty)
                                              .toList(),
                                      'story': storyController.text,
                                      'sizeGuideImage':
                                          sizeGuideImageFile?.path ?? '',
                                      'sizeGuideImageFile': sizeGuideImageFile,
                                      'colorVariants': colorVariants,
                                    };
                                    debugPrint(
                                      'Adding product: ${product.toString()}',
                                    );
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('Add Product'),
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

  Widget _buildColorVariantDialog(
    BuildContext context,
    StateSetter setState,
    List<Map<String, dynamic>> colorVariants,
    ImagePicker picker,
  ) {
    final colorNameController = TextEditingController();
    final colorHexController = TextEditingController();
    File? variantImageFile;

    return StatefulBuilder(
      builder:
          (ctx, variantSetState) => AlertDialog(
            title: const Text('Add Color Variant'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: colorNameController,
                    decoration: const InputDecoration(
                      labelText: 'Color Name *',
                      hintText: 'e.g., Bone, Onyx',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: colorHexController,
                    decoration: const InputDecoration(
                      labelText: 'Hex Color Code *',
                      hintText: '#D9D2C5',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                          'Color Preview',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _hexToColor(
                              colorHexController.text.isEmpty
                                  ? '#000000'
                                  : colorHexController.text,
                            ),
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
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
                          'Variant Image',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        if (variantImageFile != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.file(
                                    variantImageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              variantSetState(() {
                                variantImageFile = File(image.path);
                              });
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: const Text('Pick Image'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (colorNameController.text.isEmpty ||
                      colorHexController.text.isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Color name and hex code required'),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    colorVariants.add({
                      'colorName': colorNameController.text,
                      'colorHex': colorHexController.text,
                      'image': variantImageFile?.path ?? '',
                      'imageFile': variantImageFile,
                    });
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Add Variant'),
              ),
            ],
          ),
    );
  }

  Color _hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('0xff$hexColor'));
    }
    return Colors.black;
  }
}
