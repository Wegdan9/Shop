import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop/providers/cart_item.dart';

import '../providers/order_item.dart';

class Orders with ChangeNotifier{

  List<OrderItem> _orders =[];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders{
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    try{
      final url = 'https://meals-2ad8a-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
      final response = await http.get(Uri.parse(url));
      final extractedOrder = json.decode(response.body) as Map <String , dynamic>;
      if(extractedOrder == null){
        return;
      }
      List<OrderItem> loadedOrders = [];
      extractedOrder.forEach((key, value) {
        loadedOrders.add(OrderItem(
            orderId: key,
            amount: value['amount'],
            dateTime: DateTime.parse(value['dateTime']),
            products: (value['products'] as List<dynamic>).map((element) => CartItem(
                itemId: element['id'],
                itemTitle: element['title'],
                quantity: element['quantity'],
                price: element['price'])
            ).toList(),
        ));
        _orders = loadedOrders;
        notifyListeners();
      });

    }catch(error){
      throw error;
    }

    notifyListeners();
  }

 Future <void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = 'https://meals-2ad8a-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timeStamp = DateTime.now();
     final response = await http.post(Uri.parse(url), body: json.encode({
      'amount' : total,
      'dateTime': timeStamp.toIso8601String(),
      'products' : cartProducts.map((cartProduct) => {
        'id' : cartProduct.itemId,
        'title' : cartProduct.itemTitle,
        'quantity' : cartProduct.quantity,
        'price' : cartProduct.price
      }).toList()
    }));
   _orders.insert(0, OrderItem(
       orderId: json.decode(response.body)['name'],
       amount: total,
       products: cartProducts,
       dateTime: timeStamp));
   notifyListeners();
  }
}