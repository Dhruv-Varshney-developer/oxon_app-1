import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oxon_app/widgets/custom_appbar.dart';
import 'package:oxon_app/widgets/custom_drawer.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';


import '../theme/app_theme.dart';
class DriversSection extends StatefulWidget {
  const DriversSection({Key? key}) : super(key: key);

  @override
  _DriversSectionState createState() => _DriversSectionState();
}

class _DriversSectionState extends State<DriversSection> {

  late String vehicle_no;
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: AppTheme.colors.oxonGreen,
          drawer: CustomDrawer(),
          appBar: CustomAppBar(context, "Driver's Section"),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image:
                        Image.asset('assets/images/products_pg_bg.png').image,
                        fit: BoxFit.cover)),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 240, 0, 0),
                          child: TextFormField(
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            autofocus: true,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white, width: 2.0),
                              ),
                              border: OutlineInputBorder(
                                // borderSide: BorderSide(color: Colors.white, width: 2.0),
                                  borderRadius: BorderRadius.circular(20)),
                              hintText: 'Enter your vehicle number',
                              hintStyle: TextStyle(color: Colors.white, fontSize: 20),
                              labelText: 'Vehicle number',
                              labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300),
                            ),
                            onChanged: (value) {
                              setState(() {
                                vehicle_no = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please enter your vehicle number';
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: ElevatedButton(
                            onPressed: () {
                              _listenLocation(vehicle_no);
                              Fluttertoast.showToast(
                                  msg: 'Live location started',
                                  gravity: ToastGravity.TOP);
                            },
                            child: Text(
                              'Start live location',
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.green[900],
                                  fontWeight: FontWeight.bold),
                            ),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green[50],
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                  new BorderRadius.circular(35.0))),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            _stopListening();
                            Fluttertoast.showToast(
                                msg: 'Live location ended',
                                gravity: ToastGravity.TOP);
                          },
                          child: Text(
                            'End live location',
                            style: TextStyle(
                                fontSize: 30,
                                color: Colors.green[900],
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green[50],
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                  new BorderRadius.circular(35.0))),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        )
    );
  }

  Future<void> _listenLocation(String str) async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      await FirebaseFirestore.instance.collection('location').doc('user1').set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
        'Vehicle number': str
      }, SetOptions(merge: true));
    });
  }

  _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

}
