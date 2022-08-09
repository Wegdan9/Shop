import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop/providers/order_item.dart' as oi;

class OrderItem extends StatefulWidget {
  final oi.OrderItem orderItem;

  const OrderItem(this.orderItem, {Key? key}) : super(key: key);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(title: Text('${widget.orderItem.amount} \$'),
          subtitle: Text(DateFormat('dd/MM/yyyy hh:mm').format(widget.orderItem.dateTime)),
              trailing: IconButton(icon: Icon(_expanded ? Icons.expand_less: Icons.expand_more),
                  onPressed: (){
                    setState(() {
                      _expanded = !_expanded;
                    });
                  }),
            ),
          if(_expanded) Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            height: min(widget.orderItem.products.length * 20 + 10, 100),
            child: ListView(children:
              widget.orderItem.products.map((product) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(product.itemTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${product.quantity} * ${product.price}\$', style: TextStyle(fontSize: 18, color: Colors.grey),)
                ],
    )).toList(),
            ),
          )
        ],
      ),
    );
  }
}
