import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import '../../../classes/sentrequest.dart';
import '../../../utils/directions_api.dart';
import '../../../utils/directions_model.dart';
import '../ProfilePageInnerScreens/driver_profile_screen.dart';
import '../../../constant.dart';
import '../main_screen.dart';
import 'package:google_api_headers/src/google_api_headers.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter_map/flutter_map.dart' as map;
import 'package:latlong2/latlong.dart' as latlong;



class RSVPPage extends ConsumerStatefulWidget {
  RSVPPage({required this.driver, required this.info, required this.addressString, required this.currentLocation, required this.destination, required this.fullAddress});

  final Map<String, dynamic> driver;
  final Directions info;
  final String addressString;
  final String fullAddress;
  final loc.LocationData currentLocation;
  final Marker destination;

  @override
  ConsumerState<RSVPPage> createState() => _RSVPPageState();
}

class _RSVPPageState extends ConsumerState<RSVPPage> {

  int passengerCount = 1;

  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);
  final LatLng _destination = const LatLng(45.56752541455082, -122.64465091440553);

  final LatLng _start = const LatLng(37.4269, -122.0808);
  final LatLng _end = const LatLng(37.3985, -121.9754);

  Marker destination = Marker(markerId: MarkerId("destination"));

  final homeScaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController noteController = TextEditingController();

  double distance = 0;

  Widget finishButton = Text(!MainScreen.english ? "Onayla" : "Let's Go", style: TextStyle(
      color: Colors.white, fontFamily: kFontFamily, fontSize: 25, fontWeight: FontWeight.bold
  ),);

  String addressString = !MainScreen.english ? "Adres Ara" : "Search";
  String fullAddress = "";
  Directions info = Directions(
      bounds: LatLngBounds(northeast: LatLng(0,0), southwest: LatLng(0,0)),
      polylinePoints: [PointLatLng(0, 0)],
      totalDistance: "",
      totalDuration: ""
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  List<LatLng> polyLineCoordinates = [];

  loc.LocationData? currentLocation;

  Completer<GoogleMapController> _controller = Completer();

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
    getCurrentLocation();
    getPolyPoints();
    // TODO: implement initState
    super.initState();

    setState(() {
      currentLocation = widget.currentLocation;
      info = widget.info;
      addressString = widget.addressString;
      fullAddress = widget.fullAddress;
      destination = widget.destination;
      distance = double.parse((Geolocator.distanceBetween(destination.position.latitude, destination.position.longitude,
          currentLocation!.latitude!, currentLocation!.longitude!) / 1000).toStringAsFixed(2));


    });
  }

  setPassengerCount(bool reduce) {
    setState(() {
      if(reduce) {
        if(passengerCount > 1) passengerCount -= 1;
      }

      else {
        if(passengerCount < 5) passengerCount += 1;
      }
    });

  }

  bool bookNow = true;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final driver = ref.watch(driverStreamProvider(widget.driver["uid"]));
    final passenger = ref.watch(passengerStreamProvider(FirebaseAuth.instance.currentUser!.uid));
    final pickedTime = ref.watch(pickedTimeProvider);

    return Scaffold(
      key: homeScaffoldKey,
      body: SafeArea(
        child: driver.when(
          data: (driver) => passenger.when(
            loading: () => Center(child: CircularProgressIndicator(),),
            error: (error, stackTrace) => Container(),
            data: (passenger) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                        SizedBox(width: 5,),
                        Text(!MainScreen.english ? "Sürücüyü Onayla" : "Approve Driver", style: TextStyle(
                            fontSize: 17.5, fontFamily: kFontFamily, color: kDarkColors[8], fontWeight: FontWeight.bold
                        ),),

                      ],
                    ),
                    SizedBox(height: height * .02,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: width, height: height * .25,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),

                            child: map.FlutterMap(
                              options: map.MapOptions(
                                zoom: 12,
                                center: latlong.LatLng(passenger.latlng[0], passenger.latlng[1]),
                              ),
                              children: [
                                map.TileLayer(
                                  retinaMode: true,
                                  tileProvider: map.NetworkTileProvider(),
                                  backgroundColor: Colors.black,
                                  urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                                  subdomains: ['a', 'b', 'c'],
                                ),

                                map.MarkerLayer(
                                  markers: [
                                    map.Marker(
                                      point: latlong.LatLng(destination.position.latitude, destination.position.longitude),
                                      builder: (context) => Icon(Icons.location_on, color: Colors.blueAccent),
                                      width: 40,
                                      height: 40
                                    ),
                                    map.Marker(
                                        point: latlong.LatLng(passenger.latlng[0], passenger.latlng[1]),
                                        builder: (context) => Icon(Icons.location_on, color: Colors.redAccent),
                                        width: 40,
                                        height: 40
                                    ),
                                  ],
                                )
                              ],
                            )
                          ),

                        ),
                        SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}", style: TextStyle(
                                color: Colors.black38, fontSize: 12.5, fontFamily: kFontFamily, fontWeight: FontWeight.bold
                            ),),

                            Text(!MainScreen.english ? "Mesafe $distance KM" : "Distance $distance KM", style: TextStyle(
                                color: Colors.black38, fontSize: 12.5, fontFamily: kFontFamily, fontWeight: FontWeight.bold
                            ),),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: height * .02,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: bookNow,
                                  activeColor: kLightColors[0],
                                  onChanged: (value) {
                                    setState(() {
                                      bookNow = value!;
                                    });
                                  },
                                  shape: CircleBorder(),
                                ),
                                Text(MainScreen.english ? "Book Now" : "Şimdi Gelsin", style: TextStyle(
                                  fontFamily: kFontFamily, fontWeight: FontWeight.bold, fontSize: 15
                                ),)
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: !bookNow,
                                  activeColor: kLightColors[0],
                                  onChanged: (value) async {
                                    final TimeOfDay? newTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    ref.read(pickedTimeProvider.notifier).state = newTime!;

                                    setState(() {
                                      bookNow = !value!;
                                    });
                                  },
                                  shape: CircleBorder(),
                                ),
                                Text(MainScreen.english ? "Book for later" : "Sonra Gelsin", style: TextStyle(
                                  fontFamily: kFontFamily, fontWeight: FontWeight.bold, fontSize: 15
                                ),)
                              ],
                            ),
                          ],
                        ),
                        bookNow ? Container() : Text("Sürücünün geleceği saat: ${formatTimeOfDay(pickedTime)}",
                          style: TextStyle(
                          fontSize: 15, fontFamily: kFontFamily
                        ),)
                      ],
                    ),
                    SizedBox(height: height * .02,),
                    Container(
                      width: width,
                      height: height * .175,
                      decoration: BoxDecoration(
                        color: kBackgroundGrey,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text(!bookNow ? "${formatTimeOfDay(pickedTime)}" : "${DateFormat.Hm().format(DateTime.now())}",
                                      style: TextStyle(fontWeight: FontWeight.normal, fontFamily: kFontFamily,
                                      fontSize: 15, color: kDarkColors[9]),),
                                  //SizedBox(height: height * .01,),
                                  Text("?", style: TextStyle(fontWeight: FontWeight.normal, fontFamily: kFontFamily,
                                      fontSize: 15, color: kDarkColors[9]),)
                                ],
                              ),

                            ],
                          ),
                          Image.asset("images/icons/downarrow2.png", width: width * .15, fit: BoxFit.contain, color: kDarkColors[5],),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: width * .5,
                                child: MaterialButton(
                                    onPressed: () {
                                      mapController.animateCamera(CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          zoom: 13.5,
                                          target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                                        ),
                                      ),);
                                    },
                                    child: Text(!MainScreen.english ? "Bulunduğun konum" : "Your Location", style: TextStyle(color: Colors.black,
                                        fontFamily: kFontFamily, fontSize: 12.5),)
                                ),
                              ),
                              Container(
                                width: width * .4,
                                height: 1,
                                color: Colors.grey,
                              ),
                              Container(
                                width: width * .5,
                                child: MaterialButton(
                                    onLongPress: () {
                                      mapController.animateCamera(CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          zoom: 13.5,
                                          target: LatLng(destination.position.latitude, destination.position.longitude),
                                        ),
                                      ),);
                                    },
                                    onPressed: _handlerPressButton,
                                    child: Text(fullAddress, style: TextStyle(color: Colors.black,
                                        fontFamily: kFontFamily, fontSize: 12.5),)
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    //SizedBox(height: height * .04,),
                    /*Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(!MainScreen.english ? "Kaç kişi için" : "For how many passengers", style: TextStyle(
                      color: kBottomBarIconsColor, fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.w700
                    )),
                    SizedBox(height: 5,),
                    Container(
                      width: width,
                      height: height * .09,
                      decoration: BoxDecoration(
                        color: kLightColors[9],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: kLightColors[6], borderRadius: BorderRadius.circular(10),
                            ),
                            width: 50, height: 50,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: MaterialButton(
                                  onPressed: () {

                                    setPassengerCount(true);
                                  },
                                  child: Center(child: Icon(Icons.remove, size: 20,)),
                                ),
                              ),
                            ),
                          ),
                          Text("$passengerCount", style: TextStyle(color: Colors.black87, fontSize: 30, fontFamily: kFontFamily, fontWeight: FontWeight.bold),),
                          Container(
                            decoration: BoxDecoration(
                              color: kLightColors[6], borderRadius: BorderRadius.circular(10),
                            ),
                            width: 50, height: 50,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: MaterialButton(
                                  onPressed: () {
                                    setPassengerCount(false);
                                  },
                                  child: Center(child: Icon(Icons.add, size: 20,)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5,),
                    Text(!MainScreen.english ? "Toplam Tutar ${passengerCount * 50} TL" : "Total Amount ${passengerCount * 50} TL", style: TextStyle(
                        color: kBottomBarIconsColor, fontFamily: kFontFamily, fontSize: 15,
                    )),
                  ],
                ),*/
                    SizedBox(height: height * .02,),
                    Container(
                      width: width, height: height * .15,
                      child: ClipRRect(
                        child: Material(
                          color: kLightColors[9],
                          child: TextField(
                            controller: noteController,
                            maxLines: 5,
                            style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: kFontFamily),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: !MainScreen.english ? "Sürücüye bir not bırak" : "Leave a note to the driver",
                              hintStyle: TextStyle(color: Colors.black54, fontSize: 15, fontFamily: kFontFamily),
                              contentPadding: EdgeInsets.all(10),
                              counterText: "",
                            ),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    SizedBox(height: height * .02),
                    Text(!MainScreen.english ? "Toplam Tutar ${passengerCount * 50} TL" : "Total Amount ${passengerCount * 50} TL",
                        style: TextStyle(fontWeight: FontWeight.bold,
                          color: kBottomBarIconsColor, fontFamily: kFontFamily, fontSize: 12.5,
                        )),
                    SizedBox(height: height * .02,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, _routeToSignInScreen(DriverProfileScreen(driverUid: widget.driver["uid"],)));
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider("${widget.driver["photo"]}"),
                                radius: 20,
                              ),
                              SizedBox(width: 7.5,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${widget.driver["name"]}", style: TextStyle(fontSize: 15, fontFamily: kFontFamily,
                                      fontWeight: FontWeight.bold, color: kBottomBarIconsColor)),
                                  SizedBox(height: 5,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.star, color: Colors.orangeAccent, size: height * 0.02,),
                                      SizedBox(width: 2.5,),
                                      Text("${(widget.driver["point"] as double).toStringAsFixed(2)}", style: TextStyle(fontFamily: kFontFamily, fontSize: 12.5),),


                                    ],
                                  ),



                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {

                              },
                              child: Image.asset("images/icons/comment.png", fit: BoxFit.contain, width: width * .05, color: Colors.black87,),

                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(10),
                                primary: Colors.white, // <-- Button color
                                onPrimary: Colors.red, // <-- Splash color
                              ),
                            ),
                            Container(
                              width: width * .3, height: height * .045,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: MaterialButton(
                                  color: kLightColors[4],
                                  onPressed: () {
                                    Navigator.push(context, _routeToSignInScreen(DriverProfileScreen(driverUid: widget.driver["uid"])));

                                  },

                                  child: Center(
                                    child: Text(!MainScreen.english ? "Profile Git" : "See Profile", style: TextStyle(
                                        fontSize: 12.5, fontFamily: kFontFamily, color: Colors.black
                                    ),),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )


                      ],
                    ),

                    SizedBox(height: height * .02,),
                    Container(
                      width: width, height: height * .07,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: MaterialButton(
                            color: kDarkColors[2],
                            onPressed: () async {
                              setState(() {
                                finishButton = Center(child: CircularProgressIndicator(color: Colors.white,),);
                              });
                              await sendBookRequest(widget.driver, "", pickedTime);
                              sendPushMessage("${passenger.name} sana yolculuk isteği gönderdi!", "Bir yolculuk isteğin var!", driver.token, passenger.uid);


                              Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(MainScreen()), (route) => false);
                            },
                            child: finishButton
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          error: (error, stackTrace) => Container(),
          loading: () => Center(child: CircularProgressIndicator(),),
        ),
      ),
    );
  }

  String formatTime(DateTime dateTime) {
    final formatter = DateFormat.Hm(); // H: 24 saatlik saat, m: dakika

    return formatter.format(dateTime);
  }
  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final formatter = DateFormat.Hm(); // H: 24 saatlik saat, m: dakika

    return DateFormat.Hm().format(dateTime);
  }

  int extractNumber(String input) {
    RegExp regExp = RegExp(r'\d+');
    Match? match = regExp.firstMatch(input);

    if (match != null) {
      return int.parse(match.group(0)!);
    } else {
      return 0;
    }
  }

  void sendPushMessage(String body, String title, String token, currentUid) async {
    try {
      await post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
          'key=AAAAB5zGRdw:APA91bEBo9ZXqSdVh6-GSM7JX8JTmG2BQZ_v4WCm0UeXbd89DicUWcP9KsdYMGFq_CKULNws1AbqVnRJFKv_ViGEpXkvLVqSK2uwBoIre12BvXGYJVVMcpYrHtt2_Ecm90QQ_YJSFaYB',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'rsvp',
              "uid" : currentUid,
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
      print('done');


    } catch (e) {
      print("error push notification");
    }
  }



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

  _handlerPressButton() async {
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
        components: [Component(Component.country, "tr"), Component(Component.country, "usa")]
    );

    displayPrediction(p!,homeScaffoldKey.currentState);
  }

  void onError(PlacesAutocompleteResponse response){
    print("HATA: ${response.errorMessage}");
    //homeScaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(response.errorMessage!)));
  }

  Future<void> displayPrediction(Prediction p, ScaffoldState? currentState) async {

    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: "AIzaSyBGIPc00JPoRYPJeV-WRSV4cOhgc0Ruqfk",
        apiHeaders: await GoogleApiHeaders().getHeaders()
    );

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    await _addMarker(LatLng(detail.result.geometry!.location.lat, detail.result.geometry!.location.lng));

    print("KONUMUN: ${detail.result.name}\n${detail.result.formattedAddress}");



    setState(() {
      addressString = detail.result.name.toString();
      fullAddress = detail.result.formattedAddress.toString();

    });

    // markersList.clear();
    // markersList.add(Marker(markerId: const MarkerId("0"),position: LatLng(lat, lng),infoWindow: InfoWindow(title: detail.result.name)));

    setState(() {});

    mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));

  }

  _addMarker(LatLng pos) async { //origin == null || (origin != null && destination != null)
    setState(() {
      destination = Marker(
        markerId: MarkerId("destination"),
        position: LatLng(pos.latitude, pos.longitude),

      );
      //origin = Marker(markerId: MarkerId("origin"));
    });

    final directions = await DirectionsAPI().getDirections(origin: LatLng(currentLocation!.latitude!, currentLocation!.longitude!), destination: LatLng(destination.position.latitude, destination.position.longitude));
    setState(() {
      info = directions;
      distance = double.parse((Geolocator.distanceBetween(destination.position.latitude, destination.position.longitude,
          currentLocation!.latitude!, currentLocation!.longitude!) / 1000).toStringAsFixed(2));
    });

    List<Placemark> placemarks = await placemarkFromCoordinates(destination.position.latitude, destination.position.longitude);

    print("FIRST: ${destination.position.latitude} ${destination.position.longitude}");



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
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  sendBookRequest(Map<String, dynamic> driver, String note, TimeOfDay pickedTime) async {
    try {
      User? user = await FirebaseAuth.instance.currentUser;
      SentRequest sentRequest = SentRequest(
        money: 0.0,
        bookednow: bookNow,
        placeToGo: addressString, passengers_count: passengerCount, driver_uid: driver["uid"], drive_uid: "${user!.uid}_${driver["uid"]}",
        from: [currentLocation!.latitude, currentLocation!.longitude], note: noteController.text, distance: distance, passenger_uid: user.uid,
        status: "request", to: [destination.position.latitude, destination.position.longitude], point: 0.001, date: bookNow ? DateTime.now()
          :  DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, pickedTime.hour, pickedTime.minute),
        destinationFullAddress: fullAddress, hasfinished: false, hasmet: false
      );
      await FirebaseFirestore.instance.collection("passengers").doc(user.uid)
          .collection("sentrequests").doc("${user.uid}_${driver["uid"]}").set(sentRequest.toDocument());

      await FirebaseFirestore.instance.collection("drivers").doc(driver["uid"])
          .collection("receivedrequests").doc("${user.uid}_${driver["uid"]}").set(sentRequest.toDocument());
      print("Request sent");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kDarkColors[2],
          content: Text(!MainScreen.english ? "Sürücüye istek gönderildi" : "The request has been sent to the driver",
              style: TextStyle(fontFamily: kFontFamily, fontSize: 17.5, color: Colors.white, fontWeight: FontWeight.bold)),),
      );
    }

    catch(E) {
      print(E);
    }
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

final pickedTimeProvider = StateProvider<TimeOfDay>((ref) {
  return TimeOfDay.now(); // declared elsewhere
});
