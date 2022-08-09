import 'package:flutter/material.dart';
import 'package:shop/providers/products.dart';
import './product_item.dart';
import '../providers/product.dart';
import'package:provider/provider.dart';


class ProductsGrid extends StatelessWidget {

  bool showFavs;
   ProductsGrid(this.showFavs,{Key? key,}) : super(key: key);


  @override
  Widget build(BuildContext context) {
      final productsData = Provider.of<Products>(context);
      final products = showFavs ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 3/2 ,
      ),
      itemBuilder: (context, index) =>
          ChangeNotifierProvider.value(
              value: products[index],
              child: ProductItem()),
      itemCount: products.length,);
  }
}

/**
 * gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 200,
    childAspectRatio: 3/2,
    crossAxisSpacing: 15,
    mainAxisSpacing: 15,
    )
 * */