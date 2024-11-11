import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/address.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/add_new_address_select_on_map_page.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/select_address_on_map_page.dart';
import 'package:location/location.dart' as loc;
import 'package:ebuber/utils/directions_model.dart';
import '../../../constant.dart';
import '../main_screen.dart';

class AddNewAddressPage extends StatefulWidget {
  static LatLng addressLocation = LatLng(0.0, 0.0);
  static String addressName = "";


  @override
  State<AddNewAddressPage> createState() => _AddNewAddressPageState();
}

class _AddNewAddressPageState extends State<AddNewAddressPage> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);
  final LatLng _destination = const LatLng(45.56752541455082, -122.64465091440553);


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController noteController = TextEditingController();


  Marker destination = Marker(markerId: MarkerId("destination"));
  loc.LocationData? currentLocation;
  String addressString = !MainScreen.english ? "Adres Ara" : "Search";

  Completer<GoogleMapController> _controller = Completer();


  Directions info = Directions(
      bounds: LatLngBounds(northeast: LatLng(0,0), southwest: LatLng(0,0)),
      polylinePoints: [PointLatLng(0, 0)],
      totalDistance: "",
      totalDuration: ""
  );

  final homeScaffoldKey = GlobalKey<ScaffoldState>();

  bool destinationBar = true;

  double distance = 0;

  String fullAddress = !MainScreen.english ? "Adresin" : "Your Address";




  void getCurrentLocation() async {

    loc.Location location = loc.Location();


    location.getLocation().then((location) {
      currentLocation = location;
    });

    GoogleMapController googleMapController = await _controller.future;


    location.onLocationChanged.listen((newLoc) async {
      currentLocation= newLoc;

      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: 13.5,
          target: LatLng(newLoc.latitude!, newLoc.longitude!),
        ),
      ),);
      await updateLocationOnFirebase();
      setState(() {});

    });



  }

  updateLocationOnFirebase() async {
    await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid).update({
      "latlng" : [currentLocation!.latitude!, currentLocation!.longitude!]
    });
  }


  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      key: homeScaffoldKey,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.keyboard_backspace, color: Colors.white, size: 20,),

                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(10),
                          primary: kDarkColors[2], // <-- Button color
                          onPrimary: kDarkColors[0], // <-- Splash color
                        ),
                      ),
                      SizedBox(width: width * .01,),
                      Text(!MainScreen.english ? "Yeni Adres Kaydet" : "Save A New Address", style: TextStyle(
                          fontSize: 17.5, fontFamily: kFontFamily, color: kDarkColors[8], fontWeight: FontWeight.bold
                      ),),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(!MainScreen.english ? "Başlık" : "Title", style: TextStyle(
                              fontSize: 15, fontFamily: kFontFamily, color: Colors.black87
                          ),),
                          SizedBox(height: 5,),
                          Container(
                            width: width, height: height * .075,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Material(
                                color: kLightColors[8],
                                child: TextField(
                                  controller: titleController,

                                  style: TextStyle(color: Colors.black54, fontFamily: kFontFamily, fontSize: 12,),
                                  decoration: InputDecoration(
                                    hintText: !MainScreen.english ? "Bir başlık ekle" : "Add a title",
                                    contentPadding: EdgeInsets.all(20),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * .05,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(!MainScreen.english ? "Adres" : "Address", style: TextStyle(
                              fontSize: 15, fontFamily: kFontFamily, color: Colors.black87
                          ),),
                          SizedBox(height: 5,),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, _routeToSignInScreen(AddNewAddressSelectOnMapPage()));
                            },
                            child: Container(
                              width: width, height: height * .2,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Material(
                                  color: kLightColors[8],
                                  child: TextField(

                                    enabled: false,
                                    controller: TextEditingController()..text = AddNewAddressPage.addressName,
                                    style: TextStyle(color: Colors.black54, fontFamily: kFontFamily, fontSize: 12,),
                                    maxLines: 6,
                                    decoration: InputDecoration(

                                      enabled: false,
                                      hintText: !MainScreen.english ? "Harita üzerinden adresi belirle" :
                                      "Select the address on the map",
                                      contentPadding: EdgeInsets.all(20),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * .05,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(!MainScreen.english ? "Not" : "Note", style: TextStyle(
                              fontSize: 15, fontFamily: kFontFamily, color: Colors.black87
                          ),),
                          SizedBox(height: 5,),
                          Container(
                            width: width, height: height * .2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Material(
                                color: kLightColors[8],
                                child: TextField(
                                  controller: noteController,
                                  style: TextStyle(color: Colors.black54, fontFamily: kFontFamily, fontSize: 12,),
                                  maxLines: 6,
                                  decoration: InputDecoration(
                                    hintText: !MainScreen.english ? "Kendin ve sürücüler için açıklayıcı bir not ekle" :
                                    "Add a descriptive note for you and drivers",
                                    contentPadding: EdgeInsets.all(20),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, _routeToSignInScreen(AddNewAddressSelectOnMapPage()));
                        },

                        child: Text(!MainScreen.english ? "Haritadan Seç" : "Select On The Map", style: TextStyle(
                            fontSize: 12.5, fontFamily: kFontFamily
                        ),),
                      ),
                      Container(
                        width: width, height: height * .25,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),

                          child: GoogleMap(
                            scrollGesturesEnabled: false,
                            zoomGesturesEnabled: false,
                            mapToolbarEnabled: false,
                            onMapCreated: (controller) {
                              setState(() {
                                mapController = controller;
                              });
                            },
                            initialCameraPosition: CameraPosition(
                              target: AddNewAddressPage.addressLocation,
                              zoom: 11.0,
                            ),

                            markers: {
                              Marker(
                                markerId: MarkerId("source"),
                                position: AddNewAddressPage.addressLocation,
                              ),
                            },
                            zoomControlsEnabled: false,
                          ),
                        ),

                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Container(
                    width: width, height: height * .07,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: MaterialButton(
                        color: kDarkColors[2],
                        onPressed: () async {
                          Address address = Address(
                            note: noteController.text,
                            uid: titleController.text,
                            description: AddNewAddressPage.addressName,
                            title: titleController.text,
                            latlng: [AddNewAddressPage.addressLocation.latitude, AddNewAddressPage.addressLocation.longitude],
                          );
                          if(AddNewAddressPage.addressLocation != LatLng(0.0, 0.0)) {
                            await FirebaseFirestore.instance.collection("passengers").
                              doc(FirebaseAuth.instance.currentUser!.uid).collection("addresses")
                                  .doc(titleController.text).set(address.toDocument());

                            Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(MainScreen()), (route) => false);



                          }

                          else {

                          }

                        },
                        child: Text(!MainScreen.english ? "Adresi Kaydet" : "Save the Address", style: TextStyle(
                            color: Colors.white, fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.bold
                        ),),
                      ),
                    ),
                  )
                ],
              )
          ),
        ),
      ),
    );
  }



  Route _routeToSignInScreen(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
