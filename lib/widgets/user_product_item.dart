import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  const UserProductItem({required this.id,required this.title, required this.imageUrl,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(icon: Icon(Icons.edit),
              onPressed: (){
                    Navigator.of(context).pushNamed(EditProductScreen.routeName, arguments: id);
            }, ),
            Consumer<Products>(
              builder: (context, value, child) =>
              IconButton(icon: Icon(Icons.delete, color: Theme.of(context).errorColor,),
                onPressed: () async {
                try{
                  await value.deleteProduct(id);
                }catch(error){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete Failed')));
                }
                },

              ),
            )
          ],
        ),
      ),
    );
  }
}
