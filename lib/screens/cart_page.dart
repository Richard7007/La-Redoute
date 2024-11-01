import 'package:e_commerce/model/cart_model.dart';
import 'package:e_commerce/screens/confirmation_page.dart';
import 'package:e_commerce/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:razorpay_web/razorpay_web.dart';
import '../widget/build_icon_button_widget.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final Box<CartModel> cartBox;
  List<CartModel> cartList = [];
  List<int> _itemCounts = [];
  double _totalPrice = 0.0;
  late Razorpay razorpay;

  @override
  void initState() {
    super.initState();
    cartBox = Hive.box<CartModel>('hiveBox');
    _getCartItems();
    _calculateTotalPrice();
    razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, errorHandler);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, successHandler);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, externalWalletHandler);
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }

  void _getCartItems() {
    setState(() {
      cartList = cartBox.values.toList();
      _itemCounts = List<int>.generate(cartList.length, (index) => 1);
    });
  }

  void _calculateTotalPrice() {
    _totalPrice = 0.0;
    for (int i = 0; i < cartList.length; i++) {
      _totalPrice += (cartList[i].price ?? 0) * _itemCounts[i];
    }
  }

  void _updateTotalPrice() {
    setState(() {
      _calculateTotalPrice();
    });
  }

  void openCheckout() {
    var options = {
      "key": "rzp_test_waeUUkXGdhnmoe",
      "amount": ((_totalPrice + _totalPrice * 0.18) * 100).toInt(),
      "name": "La Redoute",
      "description": "Payment for cart items",
      "timeout": "180",
      "currency": "INR",
      "prefill": {
        "contact": "",
        "email": "test@abc.com",
      }
    };
    razorpay.open(options);
  }

  void errorHandler(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        response.message ?? 'Payment error',
      ),
      backgroundColor: Colors.red,
    ));
  }

  Future<void> successHandler(PaymentSuccessResponse response) async {
    await cartBox.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ConfirmationPage(),
      ),
    );
  }

  void externalWalletHandler(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'External wallet used: ${response.walletName}',
      ),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: BuildIconButtonWidget(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomePage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
        ),
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ),
      body: cartBox.isEmpty
          ? const Center(
              child: Text(
                'Cart is empty',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: 480,
                  child: ListView.builder(
                    itemCount: cartList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 8, right: 8, bottom: 5),
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 10),
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black,
                                  image: cartList[index].thumbnail != null
                                      ? DecorationImage(
                                          image: NetworkImage(cartList[index]
                                              .thumbnail
                                              .toString()),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 177,
                                      child: Text(
                                        cartList[index].title,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text('₹${cartList[index].price}'),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  BuildIconButtonWidget(
                                    icon: const Icon(Icons.remove,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        if (_itemCounts[index] > 1) {
                                          _itemCounts[index]--;
                                        } else {
                                          cartBox.deleteAt(index);
                                          _itemCounts.removeAt(index);
                                          cartList.removeAt(index);
                                        }
                                        _updateTotalPrice();
                                      });
                                    },
                                  ),
                                  Text(_itemCounts[index].toString()),
                                  BuildIconButtonWidget(
                                    icon: const Icon(Icons.add,
                                        color: Colors.green),
                                    onPressed: () {
                                      setState(() {
                                        _itemCounts[index]++;
                                        _updateTotalPrice();
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.white,
                    child: SizedBox(
                      height: 250,
                      width: 400,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price Details:\n',
                              style: TextStyle(fontSize: 20),
                            ),
                            const Row(
                              children: [
                                Text(
                                  'Delivery Charge:',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Spacer(),
                                Text(
                                  'Free Delivery',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.indigo),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'CGST(9%):',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const Spacer(),
                                Text(
                                    '₹${(_totalPrice * 0.09).toStringAsFixed(2)}')
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'SGST(9%):',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const Spacer(),
                                Text(
                                    '₹${(_totalPrice * 0.09).toStringAsFixed(2)}')
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Goods and Service Tax(18%):',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const Spacer(),
                                Text(
                                    '₹${(_totalPrice * 0.18).toStringAsFixed(2)}')
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                const Text(
                                  'Total Price:',
                                  style: TextStyle(fontSize: 25),
                                ),
                                const Spacer(),
                                Text(
                                  '₹${(_totalPrice + _totalPrice * 0.18).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 25),
                                )
                              ],
                            ),
                            SizedBox(
                              width: 400,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: BeveledRectangleBorder(
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    backgroundColor: Colors.black),
                                onPressed: () => openCheckout(),

                                child: const Text(
                                  'Continue',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
