import 'package:dio/dio.dart';
import 'package:e_commerce/model/cart_model.dart';
import 'package:e_commerce/model/product_response_model.dart';
import 'package:e_commerce/screens/cart_page.dart';
import 'package:e_commerce/screens/product_detail_page.dart';
import 'package:e_commerce/widget/build_icon_button_widget.dart';
import 'package:e_commerce/widget/build_icon_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ProductResponseModel? productResponseModel;
  bool isLoading = false;
  List<Product> cartList = [];
  Box<CartModel>? cartBox;
  TextEditingController searchController = TextEditingController();
  List<Product> filteredProducts = [];
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    cartBox = Hive.box<CartModel>('hiveBox');
    setState(() {
      isLoading = true;
    });
    getData();
  }

  void getData() async {
    final response = await Dio().get('https://dummyjson.com/products');
    productResponseModel = ProductResponseModel.fromJson(response.data);
    print(response.data);
    filteredProducts = productResponseModel!.products!;
    setState(() {
      isLoading = false;
    });
  }

  void filterProducts(String query) {
    List<Product> allProducts = productResponseModel!.products!;
    if (query.isNotEmpty) {
      filteredProducts = allProducts.where((product) =>
          product.title!.toLowerCase().contains(query.toLowerCase())).toList();
    } else {
      filteredProducts = allProducts;
    }
    if (selectedCategories.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) =>
          selectedCategories.contains(product.category)).toList();
    }
    setState(() {});
  }

  void showCategoriesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Categories'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(categories[index]),
                  value: selectedCategories.contains(categories[index]),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedCategories.add(categories[index]);
                      } else {
                        selectedCategories.remove(categories[index]);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Apply'),
              onPressed: () {
                // Filter products based on selected categories
                filterProducts(searchController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final List<String> categories = [
    'BEAUTY',
    'FRAGRANCES',
    'FURNITURE',
    'GROCERIES'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const BuildIconWidget(
          icon: Icons.menu,
          color: Colors.white,
          size: 35,
        ),
        title: const Text(
          '      La Redoute',
          style: TextStyle(color: Colors.white, fontSize: 40),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: BuildIconButtonWidget(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: filterProducts,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.search, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BuildIconButtonWidget(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    // onPressed:showCategoriesDialog,
                  ),
                ],
              ),
            ),
            isLoading
                ? const Padding(
              padding: EdgeInsets.only(top: 300),
              child: CircularProgressIndicator(color: Colors.white),
            )
                : filteredProducts.isEmpty
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 300),
              child: Text(
                'No results found',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
                : GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 0.69,
              ),
              padding: const EdgeInsets.all(12.0),
              itemCount: filteredProducts.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(
                          id: product.id ?? 0,
                          title: product.title ?? '',
                          description: product.description ?? '',
                          category: product.category,
                          price: product.price ?? 0.0,
                          discountPercentage: product.discountPercentage ?? 0.0,
                          rating: product.rating ?? 0.0,
                          stock: product.stock ?? 0,
                          tags: product.tags ?? [],
                          brand: product.brand ?? '',
                          sku: product.sku ?? '',
                          weight: product.weight,
                          dimensions: product.dimensions,
                          warrantyInformation: product.warrantyInformation ?? '',
                          shippingInformation: product.shippingInformation ?? '',
                          availabilityStatus: product.availabilityStatus,
                          reviews: product.reviews ?? [],
                          returnPolicy: product.returnPolicy,
                          minimumOrderQuantity: product.minimumOrderQuantity?.toInt(),
                          meta: product.meta,
                          images: product.images ?? [],
                          thumbnail: product.thumbnail ?? '',
                          index: index,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white54,
                    child: Card(
                      color: Colors.black,
                      child: Wrap(
                        direction: Axis.vertical,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: product.rating! > 4
                                      ? Colors.green.shade400
                                      : (product.rating! >= 2.5
                                      ? Colors.yellow.shade300
                                      : Colors.red),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: Text(
                                  '${product.rating ?? 0.0}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 130,
                            width: 162,
                            child: Image.network(
                              product.thumbnail ?? '',
                            ),
                          ),
                          SizedBox(
                            height: 75,
                            width: 162,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.brand ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    product.title ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    ' ₹${product.price ?? ''}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
