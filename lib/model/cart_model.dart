import 'package:hive_flutter/adapters.dart';
part 'cart_model.g.dart';
@HiveType(typeId: 0)
class CartModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String brand;

  @HiveField(3)
  final String thumbnail;

  @HiveField(4)
  final double price;



  CartModel( {
    required this.id,
    required this.title,
    required this.brand,
    required this.thumbnail,
    required this.price,
  });
}
