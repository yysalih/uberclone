import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:ebuber/common_pages/rent_history_page.dart';
import 'package:ebuber/common_pages/rent_inner_page.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart' as latlong;

import 'package:flutter/material.dart';
//import 'package:flutter_map/flutter_map.dart' as map;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/address_detail_page.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/driver_profile_screen.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/passenger/screens/drive_pages/requested_drive_page.dart';
import 'package:ebuber/passenger/screens/drive_pages/rsvp_page.dart';
import 'package:ebuber/passenger/screens/main_screen.dart';
import 'package:ebuber/passenger/screens/message_pages/messages_page.dart';
import 'package:ebuber/utils/directions_model.dart';
import 'package:location/location.dart' as loc;
import 'package:screenshot/screenshot.dart';
import '../../../classes/driver.dart';
import '../../../classes/rent.dart';
import '../../../common_pages/sent_requests_page.dart';
import '../../../main.dart';
import '../../../utils/directions_api.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:path/path.dart' as path;
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'dart:math' as math;

import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';




import 'home_page.dart';


class DrivePage extends ConsumerStatefulWidget {
  const DrivePage({Key? key}) : super(key: key);

  @override
  ConsumerState<DrivePage> createState() => _DrivePageState();
}

class _DrivePageState extends ConsumerState<DrivePage> with SingleTickerProviderStateMixin {

  Set<Marker> markers = Set();

  late GoogleMapController _mapController;
  Completer<GoogleMapController> _controller = Completer();

  final LatLng _start = const LatLng(37.4269, -122.0808);
  final LatLng _end = const LatLng(37.3985, -121.9754);

  late Circle circle;

  Marker destination = Marker(markerId: MarkerId("destination"));

  String addressString = !MainScreen.english ? "Adres Ara" : "Search";
  String fullAddress = "";

  double distance = 0;

  Directions info = Directions(
    bounds: LatLngBounds(northeast: LatLng(0,0), southwest: LatLng(0,0)),
    polylinePoints: [PointLatLng(0, 0)],
    totalDistance: "",
    totalDuration: ""
  );


  final homeScaffoldKey = GlobalKey<ScaffoldState>();


  List<LatLng> polyLineCoordinates = [];
  loc.LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;


  void getCurrentLocation() async {
    loc.Location location = loc.Location();
    GoogleMapController googleMapController = await _controller.future;


    location.getLocation().then((location) async {
      setState(() {
        currentLocation = location;
        _mapController = googleMapController;
      });
      await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid).update({
        "latlng" : [location.latitude!, location.longitude!]
      });
    });



    location.onLocationChanged.listen((newLoc) async {

      await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid).update({
        "latlng" : [newLoc.latitude!, newLoc.longitude!]
      });


    });



  }


  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyBGIPc00JPoRYPJeV-WRSV4cOhgc0Ruqfk",
        PointLatLng(_start.latitude, _start.longitude),
        PointLatLng(_end.latitude, _end.longitude),
    );


    if(result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) => polyLineCoordinates.add(
          LatLng(point.latitude, point.longitude)
        )
      );
      setState(() {});
    }
  }

  @override
  void initState() {
    addMarkers();
    getCurrentLocation();
    getPolyPoints();
    super.initState();

  }

  bool destinationBar = true;

  addMarkers({String category = ""}) async {
    loc.Location location = loc.Location();

    Uint8List beachBytes = (await rootBundle.load("images/icons/car64.png")).buffer.asUint8List();

    BitmapDescriptor driverMarker = await BitmapDescriptor.fromBytes(beachBytes);

    location.getLocation().then((location) async {
      await FirebaseFirestore.instance.collection("drivers").get().then((value) async {
        List<Driver> drivers = value.docs.map((e) => Driver.fromSnapshot(e)).toList();
        for(int i = 0; i < drivers.length; i++) {
          print("here: ${getDistanceFromLatLonInKm(drivers[i].latlng[0], drivers[i].latlng[1], location.latitude, location.longitude) <= 20}");
          if(getDistanceFromLatLonInKm(drivers[i].latlng[0], drivers[i].latlng[1], location.latitude, location.longitude) <= 20) {
            markers.add(
                Marker(


                    markerId: MarkerId(drivers[i].uid),
                    infoWindow: InfoWindow(title: drivers[i].point.toStringAsFixed(2),),

                    position: LatLng(drivers[i].latlng[0], drivers[i].latlng[1]), //position of marker
                    onTap: () {
                      if(info.totalDistance != "")
                        Navigator.push(context, _routeToSignInScreen(RSVPPage(driver: drivers[i].toDocument(), info: info, fullAddress: fullAddress,
                          addressString: addressString, currentLocation: currentLocation!, destination: destination,)));
                    },
                    icon: driverMarker//Icon for Marker
                )
            );
          }
        }
      });
    });





  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final drivers = ref.watch(driversStreamProvider);
    final user = ref.watch(passengerStreamProvider(FirebaseAuth.instance.currentUser!.uid));
    final sentrequests = ref.watch(sentRequestsStreamProvider);
    final rents = ref.watch(rentsStreamProvider);
    final addresses = ref.watch(addressesStreamProvider);

    final startHour = ref.watch(startHourStreamProvider);
    final endHour = ref.watch(endHourStreamProvider);

    return Scaffold(
      key: homeScaffoldKey,
      body: SafeArea(
        child: drivers.when(
          data: (drivers) => startHour.when(
            data: (start) => endHour.when(
              data: (end) => user.when(
                data: (user) {

                  final zoom = ref.watch(zoomProvider);
                  final driverInBound = ref.watch(driverInBoundryProvider);
                  final cameraBound = ref.watch(cameraBoundProvider);

                  if(DateTime.now().hour >= start || DateTime.now().hour < end) {
                    return Center(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset("images/ills/indates.png", width: width * .75, fit: BoxFit.contain,),
                            SizedBox(height: 20,),
                            Text(MainScreen.english ? "There is no drives between 10 pm and 6 am" : "Saat 22.00 ile 06.00 arası sürüş yapılamaz", style: TextStyle(
                                fontWeight: FontWeight.bold, fontFamily: kFontFamily, fontSize: 20
                            ), textAlign: TextAlign.center,)
                          ],
                        ),
                      ),
                    );
                  }
                  else return Stack(
                    children: [


                      GoogleMap(
                        zoomControlsEnabled: false,
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(user.latlng[0], user.latlng[1]),
                          zoom: 15,

                        ),
                        onCameraIdle: () async {
                          final _zoom = await _mapController.getZoomLevel();
                          ref.read(zoomProvider.notifier).state = _zoom;

                          LatLngBounds visibleRegion = await _mapController.getVisibleRegion();
                          ref.read(cameraBoundProvider.notifier).state = visibleRegion;

                        },
                        onCameraMove: (position) async {
                          ref.read(zoomProvider.notifier).state = position.zoom;

                          LatLngBounds visibleRegion = await _mapController.getVisibleRegion();
                          ref.read(cameraBoundProvider.notifier).state = visibleRegion;

                        },
                        myLocationButtonEnabled: true,

                        markers: {
                          for(Marker marker in markers) if(zoom >= 13) marker,
                          // Marker(
                          //   markerId: MarkerId(user.name),
                          //   position: LatLng(user.latlng[0], user.latlng[1]),
                          //   onTap: () {
                          //
                          //   },
                          // ),
                          destination
                        },

                        onMapCreated: (GoogleMapController controller) async {
                          _controller.complete(controller);
                          _mapController = await _controller.future;
                        },
                        onTap: (argument) async {
                          GoogleMapController googleMapController = await _controller.future;
                          _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: argument, zoom: 13.5)));
                          _addMarker(argument, LatLng(user.latlng[0], user.latlng[1]));

                        },
                        polylines: {
                          if (info != null)
                            Polyline(
                              polylineId: const PolylineId('overview_polyline'),
                              color: kDarkColors[4],
                              width: 5,
                              points: info.polylinePoints
                                  .map((e) => LatLng(e.latitude, e.longitude))
                                  .toList(),
                            ),
                        },
                      ),



                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Container(
                          //   padding: EdgeInsets.only(bottom: 20, left: 10),
                          //   child: ElevatedButton(
                          //     child: Icon(Icons.my_location, color: Colors.white),
                          //     onPressed: () {
                          //       _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(user.latlng[0], user.latlng[1]), zoom: 13.5)));
                          //
                          //     },
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: Colors.lightBlueAccent,
                          //       padding: EdgeInsets.all(15),
                          //       shape: CircleBorder()
                          //     ),
                          //   ),
                          // ),
                          info.totalDistance != "" ? Container(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              padding: EdgeInsets.only(bottom: 20),

                              child: Container(
                                width: width * .375,
                                height: 40,
                                padding: EdgeInsets.only(left: 10),

                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.shade400,
                                            spreadRadius: 1,
                                            blurRadius: 1
                                        )
                                      ]

                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: MaterialButton(
                                      color: Colors.white,

                                      onPressed: () async {
                                        if(info.totalDistance != "") {
                                          await showModalBottomSheet(context: context,
                                              isScrollControlled: true,
                                              backgroundColor: Colors.white.withOpacity(.001),
                                              builder: (context) => SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [

                                                    Container(
                                                      width: width,
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                                          color: Colors.white
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          SizedBox(height: 5,),
                                                          Container(
                                                            width: 40, height: 5,
                                                            decoration: BoxDecoration(
                                                              color: kLightColors[7].withOpacity(.5),
                                                              borderRadius: BorderRadius.circular(20),

                                                            ),

                                                          ),
                                                          SizedBox(height: 10,),
                                                          Container(
                                                            alignment: Alignment.centerLeft,
                                                            padding: EdgeInsets.only(left: 10),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text(MainScreen.english ? "Available Drivers" : "Uygun Sürücüler", style: TextStyle(
                                                                    fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.bold
                                                                ),),
                                                                ElevatedButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                  child: Icon(Icons.close, color: Colors.white),

                                                                  style: ElevatedButton.styleFrom(
                                                                    shape: CircleBorder(),
                                                                    primary: Colors.redAccent, // <-- Button color
                                                                    onPrimary: Colors.black, // <-- Splash color
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            alignment: Alignment.bottomCenter,
                                                            padding: EdgeInsets.only(bottom: 10, top: 5),
                                                            child: ConstrainedBox(
                                                              constraints: BoxConstraints(maxHeight: height * .7, maxWidth: width),
                                                              child: drivers.where((element) => cameraBound.contains(LatLng(element.latlng[0], element.latlng[1])) && zoom >= 13).length == 0
                                                                  ? Container(
                                                                padding: EdgeInsets.symmetric(vertical: 10),
                                                                child: Text(MainScreen.english ? "There is no available driver in this area" : "Bu bölgede uygun sürücü yok", style: TextStyle(
                                                                    fontWeight: FontWeight.bold, fontSize: 17.5, fontFamily: kFontFamily
                                                                ),),
                                                              ) : ListView.builder(
                                                                scrollDirection: Axis.vertical,
                                                                physics: BouncingScrollPhysics(),
                                                                itemBuilder: (context, index) {
                                                                  try {

                                                                    if(cameraBound.contains(LatLng(drivers[index].latlng[0], drivers[index].latlng[1])) && zoom >= 13)
                                                                      return Drivers(width: width, height: height, driver: drivers[index].toDocument(),
                                                                        info: info, addressString: addressString, fullAddress: fullAddress,
                                                                        currentLocation: currentLocation!, destination: destination,
                                                                        messageButton: () => Navigator.push(context,
                                                                            _routeToSignInScreen(MessagesPage(chatID: drivers[index].uid))),
                                                                        onTap: () {
                                                                          _mapController.animateCamera(CameraUpdate.newCameraPosition(
                                                                            CameraPosition(
                                                                              zoom: 14,
                                                                              target: LatLng(double.parse("${drivers[index].latlng[0]}"), double.parse("${drivers[index].latlng[1]}")),
                                                                            ),
                                                                          ),);
                                                                        },);

                                                                    else return Container();
                                                                  } catch (E) {
                                                                    print(E);
                                                                    return Center(child: Container(),);
                                                                  }
                                                                },
                                                                itemCount: drivers.length,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ));
                                        }

                                      },
                                      child: Center(

                                        child: Row(
                                          children: [
                                            Icon(Icons.menu, size: 20,),
                                            SizedBox(width: 5,),
                                            Text(MainScreen.english ? "Drivers" : "Sürücüler", style: TextStyle(
                                                fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.bold
                                            ),),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ) : Container(),
                        ],
                      ),

                      SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 10,),
                            sentrequests.when(
                              error: (error, stackTrace) {
                                print("An error: $error\n$stackTrace");
                                return Container();
                              },
                              loading: () => Container(),
                              data: (sentrequests) {
                                if(sentrequests.length != 0) {
                                  final driver = ref.watch(driverStreamProvider(sentrequests[0].driver_uid));

                                  return Container(
                                    alignment: Alignment.topCenter,

                                    child: Container(
                                      width: width, height: height * .22,

                                      padding: EdgeInsets.all(12),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  spreadRadius: 1,
                                                  blurRadius: 1
                                              )
                                            ]

                                        ),
                                        child: ClipRRect(
                                          child: MaterialButton(
                                            color: Colors.white,
                                            onPressed: () {
                                              Navigator.push(context, _routeToSignInScreen(RequestedDrivePage(
                                                driverUid: sentrequests[0].driver_uid,
                                                driveUid: sentrequests[0].drive_uid,
                                                targetName: sentrequests[0].placeToGo,
                                              )));
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 12),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(!MainScreen.english ? "İstenilen Sürücü" : "Requested Driver",
                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.5, fontFamily: kFontFamily),),
                                                      sentrequests.length > 1 ?
                                                      TextButton(
                                                        child: Text(MainScreen.english ? "See other drives" : "Diğer isteklerini gör", style: TextStyle(
                                                            fontSize: 12.5, fontFamily: kFontFamily
                                                        ),),
                                                        onPressed: () {
                                                          Navigator.push(context, _routeToSignInScreen(SentRequestsPage()));
                                                        },
                                                      )
                                                          : Container()
                                                    ],
                                                  ),
                                                  driver.when(
                                                    data: (driver) => Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundImage: CachedNetworkImageProvider("${driver.photo}"),
                                                              radius: 17.5,
                                                            ),
                                                            SizedBox(width: 10,),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                ConstrainedBox(
                                                                  child: Text("${driver.name}",
                                                                    style: TextStyle(fontSize: 12.5, fontFamily: kFontFamily,
                                                                        fontWeight: FontWeight.bold, color: kBottomBarIconsColor),
                                                                    overflow: TextOverflow.ellipsis, maxLines: 1,),
                                                                  constraints: BoxConstraints(maxWidth: width * .3,),
                                                                ),
                                                                SizedBox(height: 2,),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Icon(Icons.star, color: Colors.orangeAccent, size: height * 0.02,),
                                                                    SizedBox(width: 2.5,),
                                                                    Text("${driver.point.toStringAsFixed(2)}",
                                                                      style: TextStyle(fontFamily: kFontFamily, fontSize: 10),),


                                                                  ],
                                                                ),



                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.push(context, _routeToSignInScreen(DriverProfileScreen(driverUid: driver.uid)));
                                                              },
                                                              child: Text(!MainScreen.english ? "Profile Git" : "Go Profile", style: TextStyle(
                                                                  color: kDarkColors[2], fontWeight: FontWeight.bold,
                                                                  fontFamily: kFontFamily, fontSize: 15), maxLines: 1,),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.push(context,
                                                                    _routeToSignInScreen(MessagesPage(
                                                                        chatID: driver.uid)));
                                                              },
                                                              child: Image.asset("images/icons/comment.png", fit: BoxFit.contain, width: width * .05, color: kDarkColors[9],),

                                                              style: ElevatedButton.styleFrom(
                                                                shape: CircleBorder(),
                                                                primary: Colors.white, // <-- Button color
                                                                onPrimary: Colors.red, // <-- Splash color
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    loading: () => Center(child: CircularProgressIndicator(),),
                                                    error: (error, stackTrace) => Container(),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Image.asset("images/icons/pin.png", width: width * .045, fit: BoxFit.contain),
                                                          SizedBox(width: 5,),
                                                          ConstrainedBox(
                                                            child: Text("${sentrequests[0].placeToGo}", style: TextStyle(
                                                                fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.normal
                                                            ), maxLines: 2, overflow: TextOverflow.ellipsis),
                                                            constraints: BoxConstraints(maxWidth: width * .5),
                                                          ),
                                                        ],
                                                      ),
                                                      Text("${sentrequests[0].status == "request"
                                                          ? (!MainScreen.english ? "İstek Gönderildi" : "Requested")
                                                          : sentrequests[0].status == "rejected" ? (!MainScreen.english ? "Reddedildi" : "Rejected")
                                                          : (!MainScreen.english ? "Onaylandı" : "Accepted")}", style: TextStyle(
                                                          fontFamily: kFontFamily, fontSize: 12.5, fontWeight: FontWeight.bold
                                                      ),),


                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  );
                                }


                                /*Container(
                              alignment: Alignment.topCenter,

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: ElevatedButton(
                                        onPressed: () async {
                                          final imageUrl = "https://firebasestorage.googleapis.com/v0/b/uberclone-d441d.appspot.com/o/files%2Fscaled_image_picker1056267769859809128.png?alt=media&token=b7cdd7a1-2251-4e4e-8ba7-2e87297a7f3a";
                                          setState(() {
                                            if(!destinationBar) destinationBar = true;
                                            else if(destinationBar) destinationBar = false;
                                          });

                                          mapController.animateCamera(CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                              zoom: 13.5,
                                              target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                                            ),
                                          ),);

                                          /*Driver driver = Driver(
                                          uid: "beta_driver_2", point: 4.5, latlng: [36.543695, 32.013397], token: "",
                                          femaleoption: false, approved: true, name: "Mehmet", email: "deneme@gmail.com",
                                          phone: "", busy: false, photo: "http://t3.gstatic.com/licensed-image?q=tbn:ANd9GcTIGd4cubjxq_3-rPHhoOzO8ZCxU1DGssorn3rLmdAs6cQuvpFxsdRWgjCpQQFf2KOwIoKu5hKBLCs91EUM1BU",
                                          car: {
                                            "alttype" : "X6", "color" : "black", "plate" : "06 ABC 123", "type" : "Honda"
                                          }, emailapproved: true, gender: "male"
                                        );

                                        await FirebaseFirestore.instance.collection("drivers").doc(driver.uid).set(driver.toDocument());*/

                                        },//!destinationBar ? Icons.sort : Icons.density_medium_sharp
                                        child: Icon(Icons.pin_drop, color: Colors.white, size: 20),//Image.asset("images/icons/comment.png", fit: BoxFit.contain, width: width * .075, color: Colors.white,),

                                        style: ElevatedButton.styleFrom(
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(10),
                                          primary: Colors.redAccent, // <-- Button color
                                          onPrimary: kLightColors[6], // <-- Splash color
                                        )
                                    ),
                                  ),
                                  Container(
                                    height: height * .07,
                                    padding: EdgeInsets.only(top: 12, right: 12),
                                    child: ClipRRect(
                                      child: MaterialButton(
                                        color: Colors.white,
                                        onPressed: () {
                                          Navigator.push(context, _routeToSignInScreen(RequestedDrivePage(
                                            driverUid: sentrequests[0].driver_uid,
                                            driveUid: sentrequests[0].drive_uid,
                                            targetName: sentrequests[0].placeToGo,
                                          )));
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 12),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Image.asset("images/icons/flag.png", width: width * .05, fit: BoxFit.contain),
                                                  SizedBox(width: 5,),
                                                  ConstrainedBox(
                                                    child: Text("${sentrequests[0].placeToGo}", style: TextStyle(
                                                        fontFamily: kFontFamily, fontSize: 12.5, fontWeight: FontWeight.normal
                                                    ), maxLines: 2, overflow: TextOverflow.ellipsis),
                                                    constraints: BoxConstraints(maxWidth: width * .5),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: 10),
                                              Icon(sentrequests[0].status == "request"
                                                  ? Icons.timer_outlined
                                                  : sentrequests[0].status == "rejected" ? Icons.cancel
                                                  : Icons.drive_eta, size: 15),
                                              /*Text("${DateTime.now().difference((snapshot.data!.docs[0]["date"] as Timestamp).toDate()).inMinutes < 1
                                                ? (!MainScreen.english ? "Şimdi" : "Now") :
                                            (DateTime.now().difference((snapshot.data!.docs[0]["date"] as Timestamp).toDate()).inMinutes < 60
                                                ? "${DateTime.now().difference((snapshot.data!.docs[0]["date"] as Timestamp).toDate()).inMinutes} ${!MainScreen.english ? "DK" : "Min"}"
                                                : "${DateTime.now().difference((snapshot.data!.docs[0]["date"] as Timestamp).toDate()).inHours} ${!MainScreen.english ? "Saat" : "h"}")}",
                                              style: TextStyle(fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.normal
                                            ),),*/

                                            ],
                                          ),
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ],
                              ),
                            )*/

                                return Container();
                              },
                            ),
                            rents.when(
                              error: (error, stackTrace) {
                                print("An error: $error\n$stackTrace");
                                return Container();
                              },
                              loading: () => Container(),
                              data: (rentss) {

                                if(rentss.where((element) => element.status != "finished" && element.status != "canceled").length != 0) {
                                  Rent rentToShowFirst = rentss.where((element) => element.status != "finished" && element.status != "canceled").first;
                                  final driver = ref.watch(driverStreamProvider(rentToShowFirst.driver));

                                  return Container(
                                    alignment: Alignment.topCenter,

                                    child: Container(
                                      width: width, height: height * .2,


                                      padding: EdgeInsets.only(left: 12, right: 12, top: 0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  spreadRadius: 1,
                                                  blurRadius: 1
                                              )
                                            ]

                                        ),
                                        child: ClipRRect(
                                          child: MaterialButton(
                                            color: kLightColors[10],
                                            onPressed: () {
                                              Navigator.push(context, _routeToSignInScreen(
                                                  RentInnerPage(rent: rentToShowFirst.uid)
                                              ));
                                            },
                                            child: Container(
                                              padding: EdgeInsets.only(bottom: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(!MainScreen.english ? "İstenilen Kiralama" : "Requested Rental",
                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.5, fontFamily: kFontFamily),),

                                                      TextButton(
                                                        child: Text(MainScreen.english ? "See other rents" : "Diğer kiralamaları gör", style: TextStyle(
                                                            fontSize: 12.5, fontFamily: kFontFamily
                                                        ),),
                                                        onPressed: () {
                                                          Navigator.push(context, _routeToSignInScreen(RentHistoryPage()));
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                  driver.when(
                                                    data: (driver) => Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundImage: CachedNetworkImageProvider("${driver.photo}"),
                                                              radius: 17.5,
                                                            ),
                                                            SizedBox(width: 10,),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                ConstrainedBox(
                                                                  child: Text("${driver.name}",
                                                                    style: TextStyle(fontSize: 12.5, fontFamily: kFontFamily,
                                                                        fontWeight: FontWeight.bold, color: kBottomBarIconsColor),
                                                                    overflow: TextOverflow.ellipsis, maxLines: 1,),
                                                                  constraints: BoxConstraints(maxWidth: width * .3,),
                                                                ),
                                                                SizedBox(height: 2,),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Icon(Icons.star, color: Colors.orangeAccent, size: height * 0.02,),
                                                                    SizedBox(width: 2.5,),
                                                                    Text("${driver.point.toStringAsFixed(2)}",
                                                                      style: TextStyle(fontFamily: kFontFamily, fontSize: 10),),


                                                                  ],
                                                                ),



                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.push(context, _routeToSignInScreen(DriverProfileScreen(driverUid: driver.uid)));
                                                              },
                                                              child: Text(!MainScreen.english ? "Profile Git" : "Go Profile", style: TextStyle(
                                                                  color: kDarkColors[2], fontWeight: FontWeight.bold,
                                                                  fontFamily: kFontFamily, fontSize: 15), maxLines: 1,),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.push(context,
                                                                    _routeToSignInScreen(MessagesPage(
                                                                        chatID: driver.uid)));
                                                              },
                                                              child: Image.asset("images/icons/comment.png", fit: BoxFit.contain, width: width * .05, color: kDarkColors[9],),

                                                              style: ElevatedButton.styleFrom(
                                                                shape: CircleBorder(),
                                                                primary: Colors.white, // <-- Button color
                                                                onPrimary: Colors.red, // <-- Splash color
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    loading: () => Center(child: CircularProgressIndicator(),),
                                                    error: (error, stackTrace) => Container(),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Image.asset("images/icons/pin.png", width: width * .045, fit: BoxFit.contain),
                                                          SizedBox(width: 5,),
                                                          ConstrainedBox(
                                                            child: Text("${rentToShowFirst.city} - ${rentToShowFirst.county}", style: TextStyle(
                                                                fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.normal
                                                            ), maxLines: 2, overflow: TextOverflow.ellipsis),
                                                            constraints: BoxConstraints(maxWidth: width * .5),
                                                          ),
                                                        ],
                                                      ),
                                                      Text("${rentToShowFirst.status == "request"
                                                          ? (!MainScreen.english ? "İstek Gönderildi" : "Requested")
                                                          : rentToShowFirst.status == "canceled" ? (!MainScreen.english ? "Reddedildi" : "Rejected")
                                                          : (!MainScreen.english ? "Onaylandı" : "Accepted")}", style: TextStyle(
                                                          fontFamily: kFontFamily, fontSize: 12.5, fontWeight: FontWeight.bold
                                                      ),),


                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  );
                                }


                                /*Container(
                              alignment: Alignment.topCenter,

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: ElevatedButton(
                                        onPressed: () async {
                                          final imageUrl = "https://firebasestorage.googleapis.com/v0/b/uberclone-d441d.appspot.com/o/files%2Fscaled_image_picker1056267769859809128.png?alt=media&token=b7cdd7a1-2251-4e4e-8ba7-2e87297a7f3a";
                                          setState(() {
                                            if(!destinationBar) destinationBar = true;
                                            else if(destinationBar) destinationBar = false;
                                          });

                                          mapController.animateCamera(CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                              zoom: 13.5,
                                              target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                                            ),
                                          ),);

                                          /*Driver driver = Driver(
                                          uid: "beta_driver_2", point: 4.5, latlng: [36.543695, 32.013397], token: "",
                                          femaleoption: false, approved: true, name: "Mehmet", email: "deneme@gmail.com",
                                          phone: "", busy: false, photo: "http://t3.gstatic.com/licensed-image?q=tbn:ANd9GcTIGd4cubjxq_3-rPHhoOzO8ZCxU1DGssorn3rLmdAs6cQuvpFxsdRWgjCpQQFf2KOwIoKu5hKBLCs91EUM1BU",
                                          car: {
                                            "alttype" : "X6", "color" : "black", "plate" : "06 ABC 123", "type" : "Honda"
                                          }, emailapproved: true, gender: "male"
                                        );

                                        await FirebaseFirestore.instance.collection("drivers").doc(driver.uid).set(driver.toDocument());*/

                                        },//!destinationBar ? Icons.sort : Icons.density_medium_sharp
                                        child: Icon(Icons.pin_drop, color: Colors.white, size: 20),//Image.asset("images/icons/comment.png", fit: BoxFit.contain, width: width * .075, color: Colors.white,),

                                        style: ElevatedButton.styleFrom(
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(10),
                                          primary: Colors.redAccent, // <-- Button color
                                          onPrimary: kLightColors[6], // <-- Splash color
                                        )
                                    ),
                                  ),
                                  Container(
                                    height: height * .07,
                                    padding: EdgeInsets.only(top: 12, right: 12),
                                    child: ClipRRect(
                                      child: MaterialButton(
                                        color: Colors.white,
                                        onPressed: () {
                                          Navigator.push(context, _routeToSignInScreen(RequestedDrivePage(
                                            driverUid: sentrequests[0].driver_uid,
                                            driveUid: sentrequests[0].drive_uid,
                                            targetName: sentrequests[0].placeToGo,
                                          )));
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 12),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Image.asset("images/icons/flag.png", width: width * .05, fit: BoxFit.contain),
                                                  SizedBox(width: 5,),
                                                  ConstrainedBox(
                                                    child: Text("${sentrequests[0].placeToGo}", style: TextStyle(
                                                        fontFamily: kFontFamily, fontSize: 12.5, fontWeight: FontWeight.normal
                                                    ), maxLines: 2, overflow: TextOverflow.ellipsis),
                                                    constraints: BoxConstraints(maxWidth: width * .5),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: 10),
                                              Icon(sentrequests[0].status == "request"
                                                  ? Icons.timer_outlined
                                                  : sentrequests[0].status == "rejected" ? Icons.cancel
                                                  : Icons.drive_eta, size: 15),
                                              /*Text("${DateTime.now().difference((snapshot.data!.docs[0]["date"] as Timestamp).toDate()).inMinutes < 1
                                                ? (!MainScreen.english ? "Şimdi" : "Now") :
                                            (DateTime.now().difference((snapshot.data!.docs[0]["date"] as Timestamp).toDate()).inMinutes < 60
                                                ? "${DateTime.now().difference((snapshot.data!.docs[0]["date"] as Timestamp).toDate()).inMinutes} ${!MainScreen.english ? "DK" : "Min"}"
                                                : "${DateTime.now().difference((snapshot.data!.docs[0]["date"] as Timestamp).toDate()).inHours} ${!MainScreen.english ? "Saat" : "h"}")}",
                                              style: TextStyle(fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.normal
                                            ),),*/

                                            ],
                                          ),
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ],
                              ),
                            )*/

                                else return Container();
                              },
                            ),

                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Center(child: CircularProgressIndicator(),),
                error: (error, stackTrace) {
                  print("An error: $error\n$stackTrace");
                  return Container();
                },
              ),
              loading: () => Center(child: CircularProgressIndicator(),),
              error: (error, stackTrace) {
                print("An error: $error\n$stackTrace");
                return Container();
              },
            ),
            loading: () => Center(child: CircularProgressIndicator(),),
            error: (error, stackTrace) {
              print("An error: $error\n$stackTrace");
              return Container();
            },
          ),
          loading: () => Center(child: CircularProgressIndicator(),),
          error: (error, stackTrace) {
            print("An error: $error\n$stackTrace");
            return Container();
          },
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: addresses.when(
        error: (error, stackTrace) => Container(),
        data: (addresses) => user.when(
          loading: () => Container(),
          data: (user) => ExpandableFab(
            openButtonBuilder: RotateFloatingActionButtonBuilder(
              child: const Icon(Icons.search),
              fabSize: ExpandableFabSize.regular,
              foregroundColor: Colors.white,
              backgroundColor: kLightColors[0],
              shape: const CircleBorder(),
            ),
            closeButtonBuilder: DefaultFloatingActionButtonBuilder(
              child: const Icon(Icons.close),
              fabSize: ExpandableFabSize.regular,
              foregroundColor: Colors.white,
              backgroundColor: kLightColors[0],
              shape: const CircleBorder(),
            ),
            children: [
              for(int i = 0; i < addresses.length; i++) if(addresses[i].uid == "home" || addresses[i].uid == "school" || addresses[i].uid == "work")
                SavedAddresses(height: height, width: width,
                    title: addresses[i].title,
                    icon: addresses[i].uid,
                    address: addresses[i].description, addressMap: addresses[i].toDocument(),
                    onPressed: () {
                      if(addresses[i].latlng[0] != 0) {
                        _addMarker(LatLng(double.parse("${addresses[i].latlng[0]}"),
                            double.parse("${addresses[i].latlng[1]}")),
                            LatLng(user.latlng[0], user.latlng[1]));
                        _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: destination.position, zoom: 13.5)));
                      } else {
                        Navigator.push(context, _routeToSignInScreen(AddresDetailPage(addressMap: addresses[i].toDocument())));
                      }
                    }),

              ElevatedButton(
                  onPressed: () {
                    _handlerPressButton(LatLng(user.latlng[0], user.latlng[1]));
                    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: destination.position, zoom: 13.5)));
                  },
                  //!destinationBar ? Icons.sort : Icons.density_medium_sharp
                  child: Center(child: Icon(Icons.search, color: Colors.white, ),),//Image.asset("images/icons/comment.png", fit: BoxFit.contain, width: width * .075, color: Colors.white,),

                  style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(10),
                      backgroundColor: kDarkColors[9]// <-- Splash color
                  )
              ),
            ],
          ),
          error: (error, stackTrace) => Container(),
        ),
        loading: () => Container(),
      )
    );
  }



  _addMarker(LatLng pos, LatLng currentPos) async { //origin == null || (origin != null && destination != null)
    setState(() {
      destination = Marker(
        markerId: MarkerId("destination"),
        position: LatLng(pos.latitude, pos.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
      );
      //origin = Marker(markerId: MarkerId("origin"));
    });




    final directions = await DirectionsAPI().getDirections(origin: currentPos,
        destination: LatLng(destination.position.latitude, destination.position.longitude));
    setState(() {
      info = directions;

    });

    List<Placemark> placemarks = await placemarkFromCoordinates(destination.position.latitude, destination.position.longitude);
    

    for(int i = 0; i < placemarks.length; i++) {
      if(!isNumeric(placemarks[i].name!)) {
        setState(() {
          addressString = placemarks[i].name!;
          fullAddress = "${placemarks[i].name.toString()}, "
              "${placemarks[i].subAdministrativeArea.toString()}, ${placemarks[i].administrativeArea.toString()},"
              " ${placemarks[i].country.toString()}";
        });
      }

    }



    /* final coordinates = new Coordinates(destination.position.latitude, destination.position.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    print("${first.featureName} : ${first.addressLine}");*/
  }

  bool isNumeric(String s) {
   /* if (s == null) {
      return false;
    }*/
    return double.tryParse(s) != null;
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

  _handlerPressButton(LatLng currentPos) async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: "AIzaSyBGIPc00JPoRYPJeV-WRSV4cOhgc0Ruqfk",
        mode: Mode.overlay,
        language: !MainScreen.english ? "en" : "tr",
        strictbounds: false,
        types: [""],
        onError: onError,
        decoration: InputDecoration(
          hintText: !MainScreen.english ? "Yaz" : 'Search',
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        components: [Component(Component.country, "tr")]
    );

    displayPrediction(p!,homeScaffoldKey.currentState, currentPos);

  }

  void onError(PlacesAutocompleteResponse response){
    print("HATA: ${response.errorMessage}");
    //homeScaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(response.errorMessage!)));
  }

  Future<void> displayPrediction(Prediction p, ScaffoldState? currentState, LatLng currentPos) async {

    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: "AIzaSyBGIPc00JPoRYPJeV-WRSV4cOhgc0Ruqfk",
        apiHeaders: await GoogleApiHeaders().getHeaders()
    );

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    await _addMarker(LatLng(detail.result.geometry!.location.lat, detail.result.geometry!.location.lng), currentPos);

    print("KONUMUN: ${detail.result.name}\n${detail.result.formattedAddress}");



    setState(() {
      addressString = detail.result.name.toString();
      fullAddress = detail.result.formattedAddress.toString();
    });

    // markersList.clear();
    // markersList.add(Marker(markerId: const MarkerId("0"),position: LatLng(lat, lng),infoWindow: InfoWindow(title: detail.result.name)));

    setState(() {});

    //flutterMapController.move(latlong.LatLng(lat, lng), 13);
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));

    final zoomLevel = await _mapController.getZoomLevel();
  }


  double getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2-lat1);  // deg2rad below
    var dLon = deg2rad(lon2-lon1);
    var a = math.sin(dLat/2) * math.sin(dLat/2) +
        math.cos(deg2rad(lat1)) * math.cos(deg2rad(lat2)) *
            math.sin(dLon/2) * math.sin(dLon/2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a));
    var d = R * c; // Distance in km
    return d;
  }

  double deg2rad(deg) {
    return deg * (math.pi/180);
  }

}

class Drivers extends StatelessWidget {
  Drivers({required this.height, required this.width, required this.driver, required this.info,
    required this.addressString, required this.currentLocation,
    required this.destination, required this.fullAddress, required this.messageButton, required this.onTap});

  final double height;
  final double width;
  final Map<String, dynamic> driver;
  final Directions info;
  final String addressString;
  final String fullAddress;
  final loc.LocationData currentLocation;
  final Marker destination;
  final Function messageButton;
  final Function onTap;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 7.5),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            width: width * .55,
            height: height * .175,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /*Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: width * .25,
                          height: height * .04,
                          decoration: BoxDecoration(
                              color: kBackgroundGrey,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Center(
                            child: Text('${driver["car"]["plate"]}', style: TextStyle(color: kBottomBarIconsColor, fontSize: 15,
                                fontWeight: FontWeight.bold, fontFamily: kFontFamily),),
                          ),
                        ),
                        SizedBox(height: 2.5,),
                        Text("${driver["car"]["type"]} ${driver["car"]["alttype"]} - ${driver["car"]["color"]}",
                          style: TextStyle(fontFamily: kFontFamily, fontSize: 9, color: Colors.grey),)
                      ],
                    ),
                    Text(!MainScreen.english ? "Ücret:\n300 TL" : "Amount:\n300 TL", style: TextStyle(
                        fontSize: 12.5, fontFamily: kFontFamily, color: Colors.black, fontWeight: FontWeight.bold
                    ),)
                  ],
                ),*/
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, _routeToSignInScreen(DriverProfileScreen(driverUid: driver["uid"],)));
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider("${driver["photo"]}"),
                        radius: 22.5,
                      ),
                      SizedBox(width: 5,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: width * .35,),
                            child: Text("${driver["name"]}", style: TextStyle(fontSize: 15, fontFamily: kFontFamily,
                                fontWeight: FontWeight.bold, color: kBottomBarIconsColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,),
                          ),
                          SizedBox(height: 2,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  for(int i = 0; i < (driver["point"] as double).toInt(); i++)
                                    Icon(Icons.star, color: Colors.orangeAccent, size: height * 0.025,),
                                ],
                              ),
                              SizedBox(width: 2.5,),
                              Text("${(driver["point"] as double).toStringAsFixed(2)}",
                                style: TextStyle(fontFamily: kFontFamily, fontSize: 12.5),),


                            ],
                          ),



                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: width * .75,
                      height: height * .055,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: MaterialButton(
                          color: kLightColors[0],
                          onPressed: () {
                            if(info.totalDistance != "")
                              Navigator.push(context, _routeToSignInScreen(RSVPPage(driver: driver, info: info, fullAddress: fullAddress,
                                addressString: addressString, currentLocation: currentLocation, destination: destination,)));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(!MainScreen.english ? "Yer Ayır" : "Book",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                                  fontFamily: kFontFamily, fontSize: 15),),
                              Image.asset("images/icons/racing.png", width: width * .04, fit: BoxFit.contain, color: Colors.white,)
                            ],
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        messageButton();
                      },
                      child: Image.asset("images/icons/comment.png", fit: BoxFit.contain, width: width * .05, color: kDarkColors[9],),

                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(15),
                        primary: Colors.white, // <-- Button color
                        onPrimary: Colors.red, // <-- Splash color
                      ),
                    )


                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Center(
                    child: Container(

                      width: width , height: 1,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: kLightColors[0].withOpacity(.5)
                      ),
                    ),
                  ),
                ),
              ],
            ),
            padding: EdgeInsets.only(top: 10, bottom: 0, right: 10, left: 10)
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

  addDriver() async {
    await FirebaseFirestore.instance.collection("drivers").add({
      "car" : {
        "type" : "Ford", "alttype" : "Focus", "color" : "Mavi", "plate" : "30 SB 03"
      },

      "drivecount" : 16, "drivekm" : 604, "email" : "deneme@gmail.com", "gender" : "female",
      "latlng" : [0,0], "name" : "Seda Çapak", "phone" : "+905458761266", "photo" : "", "point" : "4.8", "uid" : ""
    });
  }


}

final zoomProvider = StateProvider<double>((ref) {
  return 0.0;
});

final driverInBoundryProvider = StateProvider<List>((ref) {
  return [];
});

final cameraBoundProvider = StateProvider<LatLngBounds>((ref) {
  return LatLngBounds(southwest: LatLng(0.0,0.0), northeast: LatLng(0.0,0.0));
});
