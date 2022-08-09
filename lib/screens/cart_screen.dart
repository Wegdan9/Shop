import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/orders.dart';
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart' as ci;

class CartScreen extends StatelessWidget {

  static const String routeName = '/cart-screen';

   CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(title: Text('YourCart')
      ),
        body: Column(
            children: [
              Card(
              margin: EdgeInsets.all(15),
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    Text('Total', style: TextStyle(fontSize: 20),),
                    Spacer(),
                    Chip(label: Text('${cart.totalAmount.toStringAsFixed(2)}\$', style: TextStyle(color: Colors.white),),
                         backgroundColor: Theme.of(context).colorScheme.primary,),
                    OrderButton(cart: cart),

                  ]
                  ),

              ),
              ),
              Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) => ci.CartItem(
                        cart.items.values.toList()[index]!.itemId,
                        cart.items.keys.toList()[index],
                        cart.items.values.toList()[index]!.itemTitle,
                        cart.items.values.toList()[index]!.quantity,
                        cart.items.values.toList()[index]!.price),

                    itemCount: cart.items.length,))
        ]),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
     onPressed: (widget.cart.totalAmount <= 0 ||  _isLoading) ? null :() async{
       setState(() {
         _isLoading = true;
       });
       await Provider.of<Orders>(context, listen: false).addOrder(widget.cart.items.values.toList(), widget.cart.totalAmount);
       setState(() {
         _isLoading = false;
       });
      widget.cart.clearCart();
    }, child:_isLoading ? CircularProgressIndicator() : Text('Place Order'));
  }
}
