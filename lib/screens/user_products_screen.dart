import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/screens/edit_product_screen.dart';
import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {

  static const routeName = '/user-products-screen';
  const UserProductsScreen({Key? key}) : super(key: key);

  Future <void> refreshProducts(BuildContext context) async{
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts(true);
  }


  @override
  Widget build(BuildContext context) {
    //final productsData = Provider.of<Products>(context);

    return Scaffold(
        appBar: AppBar(title: Text('Your Products'),
        actions: [
          IconButton(
                  icon: Icon(Icons.add),
                  onPressed: (){
                  Navigator.of(context).pushNamed(EditProductScreen.routeName);
                  }, )
        ],
    ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: refreshProducts(context),
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.waiting ? CircularProgressIndicator()
           :RefreshIndicator(
            onRefresh: () => refreshProducts(context),
            child: Consumer<Products>(
              builder: (context, value, child) {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: ListView.builder(itemBuilder: (context, index){
                    return Column(
                      children: [
                        UserProductItem(
                            id: value.items[index].productId,
                            title: value.items[index].productTitle,
                            imageUrl: value.items[index].productImageUrl),
                        Divider(thickness: 2,),
                      ],

                    );
                  }, itemCount: value.items.length,),
                );
              },
            ),
          );
        },

      ),
    );
  }


}
