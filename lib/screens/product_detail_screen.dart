import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product_detail_screen_route';


   ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct = Provider.of<Products>(context, listen: false).findById(productId);
    return Scaffold(
      appBar: AppBar(title: Text(loadedProduct.productTitle),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: Image.network(loadedProduct.productImageUrl, fit: BoxFit.cover,),
            ),
            SizedBox(height: 10,),
            Text('${loadedProduct.productPrice}\$', style: TextStyle(color: Colors.grey, fontSize: 20),),
            SizedBox(height: 10,),
            Container(padding: EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
              child: Text(loadedProduct.productDescription, textAlign: TextAlign.center, softWrap: true,),
            )
          ],
        ),
      ),

    );
  }
}
