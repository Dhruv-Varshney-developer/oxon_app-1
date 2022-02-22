import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxon_app/pages/product_detail.dart';
import 'package:oxon_app/size_config.dart';

import 'package:oxon_app/pages/cart_pg.dart';
import 'package:oxon_app/theme/colors.dart';

import 'package:oxon_app/widgets/custom_appbar.dart';

import '../widgets/custom_drawer.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  static const routeName = '/products-page';

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

var scaffoldKey = GlobalKey<ScaffoldState>();

class _ProductsPageState extends State<ProductsPage> {
  final urlImages =
  [
    'https://firebasestorage.googleapis.com/v0/b/oxon-app-a4ede.appspot.com/o/slide_show%2FOXON%20Banner%20for%20Facebook.png?alt=media&token=411ed100-7449-4319-9a80-0b507b9dfbdf',
    'https://firebasestorage.googleapis.com/v0/b/oxon-app-a4ede.appspot.com/o/slide_show%2FIMG-20220131-WA0005.png?alt=media&token=19cfd3c1-59ba-435c-aaa8-e9ea37e5270d',
    'https://firebasestorage.googleapis.com/v0/b/oxon-app-a4ede.appspot.com/o/slide_show%2FWhatsApp%20Image%202022-02-22%20at%2012.44.36%20PM.png?alt=media&token=93298035-ef0d-46b5-a54b-eb448c0eb64f'
  ];

  final CollectionReference _productReference =
  FirebaseFirestore.instance.collection('products');
  bool plant=true;
  bool other = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            drawer: CustomDrawer(),
            appBar: CustomAppBar(context, "Let's Shop", [
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartPage()),
                  );
                },
                child: Container(
                    width: 105,
                    height: 105,
                    child: Container(
                      width: 6.29 * SizeConfig.responsiveMultiplier,
                      height: 6.29 * SizeConfig.responsiveMultiplier,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  "assets/icons/shopping_cart.png"))),
                    )),
              ),
            ]),
            backgroundColor: Color.fromARGB(255, 34, 90, 0),
            body: DoubleBackToCloseApp(
              snackBar: const SnackBar(content: Text('Press again to exit the app'),duration: Duration(seconds:2)),
              child: SafeArea(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image:
                              Image.asset('assets/images/products_pg_bg.png')
                                  .image,
                              fit: BoxFit.cover)),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            CarouselSlider.builder(
                                itemCount: urlImages.length,
                                itemBuilder: (context, index, realIndex)
                                {
                                  final urlImage = urlImages[index];
                                  return buildImage(urlImage, index);
                                },
                                options: CarouselOptions(
                                    height: (MediaQuery. of(context). size. height)*0.3,
                                  autoPlay: true,
                                    autoPlayAnimationDuration: Duration(seconds: 10),
                                  enableInfiniteScroll: true,
                                  //viewportFraction: 1,
                                  //enlargeCenterPage: true,
                                  initialPage: 0,
                                )
                            ),
                            FutureBuilder<QuerySnapshot>(
                                future: _productReference.get(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Scaffold(
                                      body: Center(
                                        child: Text("Error Loading products"),
                                      ),
                                    );
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return ListView(
                                      padding: EdgeInsets.only(
                                        top: 30.0,
                                        bottom: 20.0,
                                      ),
                                      children: snapshot.data!.docs.map((document) {
                                        return GestureDetector(
                                          onTap: (){
                                            Navigator.push(context,MaterialPageRoute(
                                                builder: (context) => ProductDetail(
                                                  name: "${document.get('name')}",
                                                  ID: document.id,
                                                  description: "${document.get('description')}",
                                                  image: document.get('image'),
                                                  price: document.get('price'),
                                                  delivery: document.get('delivery'),
                                                  isplant: document.get('isplant'),
                                                )
                                            )
                                            );
                                          },
                                          child: Container(
                                            height: 210.0,

                                            decoration: BoxDecoration(
                                              color: AppColors().oxonOffWhite,
                                              borderRadius:
                                              BorderRadius.circular(12.0),
                                            ),
                                            margin: EdgeInsets.symmetric(
                                              vertical: 5.0,
                                              horizontal: 24.0,
                                            ),
                                            child :Stack(
                                              children: [
                                                Center(
                                                  child: Container(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(10.0,),
                                                      child: Column(
                                                        mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                                        children:[Container(
                                                          height:100.0,
                                                          child: Image.network(

                                                            "${document.get('image')[0]}",

                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                          Column(
                                                            mainAxisAlignment : MainAxisAlignment.start,

                                                            children: [
                                                              Center(
                                                                child: Padding(
                                                                  padding: EdgeInsets.only(top: 5.0),
                                                                  child: Center(
                                                                    child: Text("${document.get('name')}",
                                                                      style: TextStyle(color:AppColors().oxonGreen,fontSize: 18),),
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  color: AppColors().oxonOffWhite,
                                                                  borderRadius: BorderRadius.circular(12.0),

                                                                ),
                                                                child:Padding(
                                                                    padding: const EdgeInsets.symmetric(
                                                                      vertical: 5.0,
                                                                      horizontal: 5.0,
                                                                    ),child: Center(
                                                                  child: Text("\u{20B9} ${document.get('price')}",
                                                                      style: TextStyle(fontSize: 13,color: AppColors().oxonGreen)),
                                                                )),
                                                              ),
                                                            ],

                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],

                                            ),
                                          ),

                                        );
                                      }).toList(),
                                    );
                                  }
                                  return Scaffold(
                                    body: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                })
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
        )
    );
  }

  Widget buildImage(String urlImage, int index) =>
      Container(
       // margin: EdgeInsets.symmetric(horizontal:5),
        color: Colors.grey,
        child: Image.network(urlImage,
          fit: BoxFit.fill,
        ),

      );

}