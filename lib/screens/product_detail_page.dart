import 'package:e_commerce/screens/cart_page.dart';
import 'package:e_commerce/widget/build_icon_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../model/cart_model.dart';
import '../model/product_response_model.dart';
import 'home_page.dart';

class ProductDetailPage extends StatefulWidget {
  final int? id;
  final String? title;
  final String? description;
  final Category? category;
  final double? price;
  final double? discountPercentage;
  final double? rating;
  final int? stock;
  final List<String>? tags;
  final String? brand;
  final String? sku;
  final int? weight;
  final Dimensions? dimensions;
  final String? warrantyInformation;
  final String? shippingInformation;
  final AvailabilityStatus? availabilityStatus;
  final List<Review>? reviews;
  final ReturnPolicy? returnPolicy;
  final int? minimumOrderQuantity;
  final int index;
  final Meta? meta;
  final List<String>? images;
  final String? thumbnail;

  const ProductDetailPage(
      {super.key,
      this.id,
      this.title,
      this.description,
      this.category,
      this.price,
      this.discountPercentage,
      this.rating,
      this.stock,
      this.tags,
      this.brand,
      this.sku,
      this.weight,
      this.dimensions,
      this.warrantyInformation,
      this.shippingInformation,
      this.availabilityStatus,
      this.reviews,
      this.returnPolicy,
      this.minimumOrderQuantity,
      this.meta,
      this.images,
      this.thumbnail,
      required this.index});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isAddedToCart = false;
  Box<CartModel>? cartBox;
  ProductResponseModel? productResponseModel;

  @override
  void initState() {
    super.initState();
    cartBox = Hive.box<CartModel>('hiveBox');
    _isAddedToCart = isItemInCart(widget.id ?? 0);
    _pageController.addListener(() {
      setState(() {
        _currentIndex = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void addToCart() {
    final cartItem = CartModel(
      id: widget.id ?? 0,
      title: widget.title ?? '',
      price: widget.price ?? 0.0,
      brand: widget.brand ?? '',
      thumbnail: widget.thumbnail ?? '',
    );

    final existingItems = cartBox?.values.toList();
    bool itemExists =
        existingItems?.any((item) => item.id == cartItem.id) ?? false;

    setState(() {
      if (itemExists) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CartPage(),
            ));
      } else {
        cartBox?.add(cartItem);
        _isAddedToCart = true;
        print("Item added to cart: ${widget.title}");
      }
    });
  }

  bool isItemInCart(int id) {
    final existingItems = cartBox?.values.toList();
    return existingItems?.any((item) => item.id == id) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: BuildIconButtonWidget(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ));
          },
        ),
        actions: [
          BuildIconButtonWidget(
              onPressed: () {},
              icon: const Icon(
                Icons.favorite_border,
                color: Colors.white,
              ))
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2.1,
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 2.9,
                        child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: widget.images!.length,
                              itemBuilder: (context, index) {
                                return Center(
                                  child: Image.network(
                                    widget.images![index],
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            )),
                      ),
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: widget.images?.length ?? 0,
                        effect: const WormEffect(
                          activeDotColor: Colors.white,
                          dotColor: Colors.grey,
                          dotHeight: 8,
                          dotWidth: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 1.12,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Card(
                        elevation: 10,
                        shadowColor: Colors.black,
                        margin: const EdgeInsets.only(top: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        color: Colors.white10,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: 400,
                            height: 370,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child: Text(
                                      widget.category
                                          .toString()
                                          .split('.')
                                          .last,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 15),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Row(
                                    children: [
                                      Text(
                                        widget.brand.toString(),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 30),
                                      ),
                                      const Spacer(),
                                      Card(
                                        color: widget.rating! > 4
                                            ? Colors.green
                                            : (widget.rating! >= 2.5
                                                ? Colors.yellow
                                                : Colors.red),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            widget.rating.toString(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    widget.title.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    widget.description.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                ),
                                Container(
                                  width: 400,
                                  decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Review:',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children:
                                              widget.reviews!.map((review) {
                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  radius: 10,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5,
                                                          top: 7,
                                                          bottom: 10),
                                                  child: Text(
                                                    '${review.reviewerName}: ${review.comment}',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
              width: 120,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        ' ₹${widget.price.toString()}',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    )),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              height: 50,
              width: 220,
              child: FloatingActionButton(
                onPressed: () {},
                child: SizedBox(
                  height: 50,
                  width: 400,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (widget.index != null) {
                        setState(() {
                          addToCart();
                        });
                      } else {
                        print("Product data is not loaded yet");
                      }
                    },
                    child: Text(
                      _isAddedToCart ? 'Go to Cart' : 'Add to Cart',
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
