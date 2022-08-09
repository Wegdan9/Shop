import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/screens/product_detail_screen.dart';

import '../providers/Auth.dart';

class ProductItem extends StatelessWidget {

  // final String id;
  // final String title;
  // final String imageUrl;
  //
  //  ProductItem(this.id, this.title, this.imageUrl,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context,listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GridTile(
        footer:GridTileBar(
            backgroundColor: Colors.black87,
            leading: Consumer<Product>(
                builder: (context, value, child) {
                    return IconButton(
                     icon: Icon(product.isFavorite ? Icons.favorite: Icons.favorite_border),
                     color: Theme.of(context).colorScheme.secondary,
                     onPressed: (){
                        product.toggleFavoriteStatue(auth.token!, auth.userId!);
                         },
                    );
                }),
            title: Text(product.productTitle, textAlign: TextAlign.center,),
            trailing: IconButton(
                icon:  Icon(Icons.shopping_cart),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: (){
                  cart.addItem(product.productId, product.productPrice, product.productTitle);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar( SnackBar(
                      content: Text('Item added to cart!'),
                      duration: Duration(seconds: 3),
                      action: SnackBarAction(label: 'Undo',
                          onPressed: (){
                              cart.removeSingleItem(product.productId);
                          }),
                  )
                  );
                }),
        ),
        child: GestureDetector(
            onTap: () =>  Navigator.of(context).pushNamed(ProductDetailScreen.routeName, arguments: product.productId),
            child: Image.network(product.productImageUrl,fit: BoxFit.cover)),
      ),
    );
  }
}
