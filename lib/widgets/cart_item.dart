import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cart.dart';

class CartItem extends StatelessWidget {
  final String cartItemId;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  const CartItem(this.cartItemId, this.productId, this.title, this.quantity, this.price,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(cartItemId),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(Icons.delete, size: 40, color: Colors.white,),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction){
        return showDialog(context: context, builder: (ctx) {
                  return AlertDialog(title: Text('Are you sure?'),
                                    content: Text('You are about to delete the item'),
                                    actions: [
                                      TextButton(child: Text('Yes'),
                                        onPressed: (){
                                        Navigator.of(ctx).pop(true);
                                        },),
                                      TextButton(child: Text('No'),
                                        onPressed: (){
                                          Navigator.of(ctx).pop(false);
                                        },),
                                    ],
                  );
        },);
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      child: Card(
         margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
         child: Padding(padding: EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(radius: MediaQuery.of(context).size.width * 0.1,
                child: FittedBox(
                    child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${price}\$'),
            )
            )
            ),
              title: Text(title),
              subtitle: Text('Total: ${price*quantity}\$'),
              trailing: Text('${quantity} X'),
            ),
         ),
      ),
    );
  }
}
