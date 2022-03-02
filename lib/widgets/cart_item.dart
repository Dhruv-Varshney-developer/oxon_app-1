import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oxon/pages/cart_pg.dart';
import 'package:provider/provider.dart';

import '../pages/cart_page.dart';

class CartItem extends StatefulWidget {
  final String productId;
  final int price;
  final int quantity;
  final String title;

  CartItem(
    this.productId,
    this.price,
    this.quantity,
    this.title,
  );

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection("users");

  User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.productId),
      background: Container(
        color: Theme.of(context).errorColor,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text(
              'Do you want to remove the item from the cart?',
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
              FlatButton(
                child: const Text('Yes'),
                onPressed: () async {
                  await _userRef
                      .doc(_user?.uid)
                      .collection("Cart")
                      .doc(widget.productId)
                      .delete()
                      .then((value) async {
                    await Navigator.of(context)
                        .pushReplacementNamed(CartPageNew.routeName);
                      
                  });
                },
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {},
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: FittedBox(
                  child: Text("\u{20B9} " + '${widget.price}'),
                ),
              ),
            ),
            title: Text(widget.title),
            subtitle:
                Text('Total: \u{20B9} ${(widget.price * widget.quantity)}'),
            trailing: Text('${widget.quantity} x'),
          ),
        ),
      ),
    );
  }
}
