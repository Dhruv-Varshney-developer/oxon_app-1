import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:oxon/pages/payment.dart';
import 'package:oxon/size_config.dart';

import './payment.dart';
import 'package:oxon/theme/colors.dart';
import 'package:oxon/widgets/cart_item.dart';
import 'package:oxon/widgets/custom_appbar.dart';
import 'package:oxon/widgets/custom_drawer.dart';

class CartPage extends StatefulWidget {
  static const routeName = '/cart-page';

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection("users");

  User? _user = FirebaseAuth.instance.currentUser;

  int total = 0;
  int finalTotal = 0;
  int userCredits = 0;
  int finalPrice = 0;
  int discount = 0;
  int refresh = 1;

  final FirebaseAuth auth = FirebaseAuth.instance;

  _fetch() async {
    int price = total;

    final user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((ds) {
        print(ds);
        userCredits = ds.data()!['credits'] == null ? 0 : ds.data()!['credits'];
        if (price * 0.2 >= userCredits) {
          discount = (userCredits).toInt();
        } else {
          discount = (price * 0.2).toInt();
        }
      }).catchError((e) {
        print(e);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: CustomDrawer(),
        appBar: CustomAppBar(context, 'Cart'),
        backgroundColor: Color.fromARGB(255, 34, 90, 0),
        body: SingleChildScrollView(
          child: SizedBox(
            height: SizeConfig.screenHeight ,
            child: Stack(
              children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 5, 15.0, 5),
                    child: Text(
                      "Swipe left to delete a product from the cart",
                      style: TextStyle(
                          color: AppColors().oxonOffWhite,
                          fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: Container(
                    margin: EdgeInsets.all(15.0),
                    padding: EdgeInsets.all(15.0),
                    child: Stack(
                      children: [
                        FutureBuilder<QuerySnapshot>(
                          future: _userRef.doc(_user?.uid).collection("Cart").get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Scaffold(
                                body: Center(
                                  child: Text("Error Loading products"),
                                ),
                              );
                            }
                            if (snapshot.connectionState == ConnectionState.done) {
                              return Scaffold(
                                backgroundColor: AppColors().oxonGreen,
                                body: Column(
                                  children: [
                                    SizedBox(
                                      height: SizeConfig.screenHeight * 0.7,
                                      child: ListView(
                                        padding: EdgeInsets.only(
                                          top: 30.0,
                                          bottom: 20.0,
                                        ),
                                        children:
                                            snapshot.data!.docs.map((document) {
                                          int p = document.get('price') as int;
                                          int q = document.get('quantity') as int;
                                          int d = document.get('delivery') as int;
                                          total += p * q;
                  
                                          return CartItem(
                                              "${document.get('ID')}",
                                              document.get('price'),
                                              document.get('quantity'),
                                              "${document.get('name')}");
                                        }).toList(),
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    FutureBuilder(
                                        future: _fetch(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Center(
                                              child: Text("Loading"),
                                            );
                                          }
                                          return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    child: Text(
                                                  'Your cart total is: Rs. $total ',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                                Container(
                                                    child: Text(
                                                  'Discount applied from wallet (MAX 20%): Rs. $discount ',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                                Container(
                                                    child: Text(
                                                  'Delivery Charges: Rs. 49 ',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                                Container(
                                                    child: Text(
                                                  'Total amount to be paid: Rs. ${total - discount + 49} ',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                              ]);
                                        }),
                                    Center(
                                      child: GestureDetector(
                                        onTap: () async {
                                          int price = total;
                                          final user = await FirebaseAuth
                                              .instance.currentUser;
                                          await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) => (Payment(
                                                      total - discount + 49))));
                                        },
                                        child: Center(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                color:
                                                    AppColors().oxonOffWhite),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 15.0,
                                                horizontal: 25.0,
                                              ),
                                              child: Text("Proceed to payment",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: AppColors()
                                                          .oxonGreen)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }
                            return Scaffold(
                              backgroundColor: Colors.transparent,
                              body: Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.transparent,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
    
  }
}
