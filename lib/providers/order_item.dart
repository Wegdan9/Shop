import 'package:shop/providers/cart_item.dart';

class OrderItem{

  final String orderId;
  final double amount;
  final List<CartItem>products;
  final DateTime dateTime;

  OrderItem({required this.orderId,required this.amount,required this.products,required this.dateTime});
}