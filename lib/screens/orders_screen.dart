import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/orders.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {

  static const routeName = '/orders_screen';

  OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  /// var _isLoading = false;
  /// var _isInit = true;
  /// old approach used by converting to stateful widget to access initState() to load the data from provider when creating object of the state
  ///@override
  /// void didChangeDependencies() {
  ///   if(_isInit){
  ///     setState(() {
  ///       _isLoading = true;
  ///     });
  ///     Provider.of<Orders>(context, listen: false).fetchAndSetOrders().then((value) {
  ///       setState(() {
  ///         _isLoading = false;
  ///       });});
  ///   }
  ///   _isInit = false;
  ///
  ///
  ///   super.didChangeDependencies();
  /// }


  ///by that we Ensuring that no new FUTURE is created in case if we rebuild our widget

  Future? _ordersFuture;

  Future _obtainOrdersFuture (){
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    /// final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Your Orders'),
    ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }else {
            if(snapshot.error != null){
              print(snapshot.error);
              return Center(child: Text('error occurred'),);
            }else{
              return Consumer<Orders>(
                builder: (context, value, child) {
                  return ListView.builder(itemBuilder: (context, index) {
                    return OrderItem(value.orders[index]);
                  }, itemCount: value.orders.length,);
                },
              );
            }
          }
      },)

      /// old approach WE used alternative approach from changing to statefulWidget (useless transforming) to use initState() to load data from provider once we create the state object
      /// we using FutureBuilder()
      /// _isLoading ? Center(child: CircularProgressIndicator(),) : ListView.builder(
      ///     itemBuilder: (context, index) {
      ///       return OrderItem(orderData.orders[index]);
      ///     },
      ///     itemCount: orderData.orders.length,),
    );
  }
}
