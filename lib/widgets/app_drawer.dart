import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/Auth.dart';
import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
          children: [
        AppBar(title: Text('Hello Friend'),
        automaticallyImplyLeading: false,
        ),
            Divider(),
            ListTile(leading: Icon(Icons.shopping_cart),
            title: Text('Shop'),
            onTap: (){
              Navigator.of(context).pushReplacementNamed('/');
            },),
            Divider(),
            ListTile(leading: Icon(Icons.payment),
              title: Text('Orders'),
              onTap: (){
                Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
              },),
            Divider(),
            ListTile(leading: Icon(Icons.edit),
              title: Text('Manage Products'),
              onTap: (){
                Navigator.of(context).pushReplacementNamed(UserProductsScreen.routeName);
              },),
            Divider(),
            ListTile(leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: (){
                Navigator.of(context).pop();
              Provider.of<Auth>(context, listen: false).logout();

                //Navigator.of(context).pushReplacementNamed(UserProductsScreen.routeName);

              },)
      ]),
    );
  }
}
