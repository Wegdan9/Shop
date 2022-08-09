import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';
import '../widgets/app_drawer.dart';
import 'package:shop/widgets/badge.dart';
import '../screens/cart_screen.dart';
import 'package:shop/screens/products_overview_screen.dart';
import '../widgets/products_grid.dart';
import '../providers/cart.dart';


enum FilterOptions{
  Favorites,
  All
}

class ProductsOverviewScreen extends StatefulWidget {

  ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

@override
  void didChangeDependencies() {
    if(_isInit){
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((value) {
        setState(() {
          _isLoading= false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Shop'),
      actions: [
        Consumer<Cart>(
          builder: (context, cart,  iconChild) =>
           Badge(
            value: cart.itemCount.toString(),
            child: iconChild!,
          ),
          child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: (){
                Navigator.of(context).pushNamed(CartScreen.routeName);
              }),
        ),
        PopupMenuButton(
          icon: Icon(Icons.more_vert),
          onSelected: (FilterOptions selectedValue) {
            setState(() {
              if(selectedValue == FilterOptions.Favorites){
                _showOnlyFavorites = true;
              }else{
                _showOnlyFavorites = false;
              }
            });
          },
          itemBuilder: (context) =>[
          const PopupMenuItem(
            child: Text('Favorites'),
            value: FilterOptions.Favorites,
          ),
            const PopupMenuItem(
              child: Text('All'),
              value: FilterOptions.All,
            )
        ],)
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading ? const Center(child: CircularProgressIndicator(),): ProductsGrid(_showOnlyFavorites),

    );
  }
}


