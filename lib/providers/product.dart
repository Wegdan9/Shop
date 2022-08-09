import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier{
  final String productId;
  final String productTitle;
  final String productDescription;
  final double productPrice;
  final String productImageUrl;
  bool isFavorite;

  Product({ required this.productId, required this.productTitle, required this.productDescription,
          required this.productPrice, required this.productImageUrl, this.isFavorite = false});

  void _setFavValue (bool newValue){
    isFavorite = newValue;
    notifyListeners();
  }

  Future <void> toggleFavoriteStatue(String token, String userId) async{
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url = 'https://meals-2ad8a-default-rtdb.firebaseio.com/userFavorites/$userId/$productId.json?auth=$token';
    try{
      final response = await http.put(Uri.parse(url), body: json.encode(
         isFavorite
      ));

      if(response.statusCode >= 400){
       _setFavValue(oldStatus);
      }
    }catch(error){
      _setFavValue(oldStatus);
      throw error;

    }

  }
}