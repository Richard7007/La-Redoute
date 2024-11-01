import 'package:e_commerce/screens/home_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
          ),
          SizedBox(height: 200, child: Image.asset('assets/images/logo.jpg')),
          const Text(
            'La Redoute',
            style: TextStyle(color: Colors.white, fontSize: 55),
          ),
          Row(
            children: [
              const Expanded(
                child: Divider(
                  color: Colors.white,
                  thickness: 1,
                  endIndent: 10,
                  indent: 50,
                ),
              ),
              SizedBox(height: 30, child: Image.asset('assets/images/logo.jpg')),
              const Expanded(
                child: Divider(
                  color: Colors.white,
                  thickness: 1,
                  indent: 10,
                  endIndent: 50,
                ),
              ),
            ],
          ),
          const Text(
            '             Discover More, Spend Less –\n Your One-Stop Shop for Everything You Love!',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }
}