import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/Auth.dart';
import './screens/auth_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/splash_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './providers/orders.dart';
import './providers/cart.dart';
import './screens/cart_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import './providers/products.dart';


void main() =>runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create:(context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (context) => Products('','', []),
          update: (context, auth, previousProducts) {
            return Products( auth.token, auth.userId, previousProducts == null ? [] : previousProducts.items);
          },
          ),
        ChangeNotifierProvider(
        create: (context) => Cart(),
          ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) => Orders('','', []),
          update: (context, auth, previousOrders) {
            return Orders(auth.token!, auth.userId!,previousOrders == null ? [] : previousOrders.orders);
          },
        )],
        child: Consumer<Auth>(
          builder: (context, auth, child) {
             return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'MyShop',
              theme: ThemeData(colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple).copyWith(secondary: Colors.deepOrange),
                fontFamily: 'Lato',

              ),

              /// if false instead of displaying AuthScreen() we need to try to log in
              home: auth.isAuth ? ProductsOverviewScreen() :
              FutureBuilder(
                future: auth.tryAutoLogin(),
                builder: (context, snapshot) =>
                   snapshot.connectionState == ConnectionState.waiting ?
                    SplashScreen() : AuthScreen(),
              ),
              routes: {
                //'/': (context) => AuthScreen(),
                //productsOverViewScreen
                ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
                CartScreen.routeName: (context)=>CartScreen(),
                OrdersScreen.routeName: (context) => OrdersScreen(),
                UserProductsScreen.routeName : (context) => UserProductsScreen(),
                EditProductScreen.routeName :(context) => EditProductScreen(),
              },


            );
          },
        ),
    );
  }
}


