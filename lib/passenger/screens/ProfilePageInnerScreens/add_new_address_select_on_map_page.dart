import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/add_new_address_page.dart';
import '../../../constant.dart';
import '../../../utils/directions_api.dart';
import '../../../utils/directions_model.dart';
import '../main_screen.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';



class AddNewAddressSelectOnMapPage extends StatefulWidget {


  @override
  State<AddNewAddressSelectOnMapPage> createState() => _AddNewAddressSelectOnMapPageState();
}

class _AddNewAddressSelectOnMapPageState extends State<AddNewAddressSelectOnMapPage> {


  late GoogleMapController mapController;
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
      setState(() {
        currentLocation = location;
      });
    });

    GoogleMapController googleMapController = await _controller.future;


    location.onLocationChanged.listen((newLoc) async {
      setState(() {
        currentLocation= newLoc;
      });

      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: 13.5,
          target: LatLng(newLoc.latitude!, newLoc.longitude!),
        ),
      ),);
      setState(() {});

      await updateLocationOnFirebase();

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
      body: SafeArea(
        child: Stack(
          children: [
            currentLocation == null ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15,),
                  Text(!MainScreen.english ? "Yükleniyor..." : "Loading...", style: TextStyle(fontFamily: kFontFamily),)
                ],
              ),
            ) :
            GoogleMap(
              /*onMapCreated: (mapController) {
                _controller.complete(mapController);
              },*/
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
              },

              //_onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 11.0,
              ),

              circles: {
                Circle(
                  circleId: CircleId("passenger"),
                  radius: 25,
                  zIndex: 1,
                  strokeColor: Colors.deepPurpleAccent,
                  center: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                  fillColor: Colors.deepPurpleAccent.withAlpha(70),
                )
              },

              markers: {
                if(destination != null) destination,
                /*Marker(
                  markerId: MarkerId("currentLocation"),
                  position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                  icon: sourceIcon,

                ),

                Marker(
                    markerId: MarkerId("source"),
                    position: _start
                ),

                Marker(
                    markerId: MarkerId("destination"),
                    position: _end,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),

                ),*/

              },

              onLongPress: _addMarker,
              onTap: _addMarker,
              zoomControlsEnabled: false,
              myLocationEnabled: false,
            ),

            Container(
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.keyboard_backspace, color: Colors.white, size: 20,),

                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(10),
                      primary: kDarkColors[4], // <-- Button color
                      onPrimary: kDarkColors[0], // <-- Splash color
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _handlerPressButton,
                    child: Icon(Icons.search, color: Colors.white, size: 20,),

                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(10),
                      primary: kDarkColors[4], // <-- Button color
                      onPrimary: kDarkColors[0], // <-- Splash color
                    ),
                  ),
                ],
              ),
            ),

            Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      padding: EdgeInsets.all(10),
                      width: width, height: height * .25,
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text("$fullAddress", style: TextStyle(fontSize: 15, fontFamily: kFontFamily),
                        maxLines: 7,  overflow: TextOverflow.ellipsis,)
                  ),
                  SizedBox(height: 10,),
                  Container(
                    width: width, height: height * .07,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: MaterialButton(
                        color: kDarkColors[2],
                        onPressed: () async {

                          Navigator.pop(context);
                        },
                        child: Text(!MainScreen.english ? "Adresi Kaydet" : "Save the Address", style: TextStyle(
                            color: Colors.white, fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.bold
                        ),),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
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



    setState(() {
      addressString = detail.result.name.toString();
      fullAddress = detail.result.formattedAddress.toString();
      AddNewAddressPage.addressLocation = LatLng(lat, lng);
      AddNewAddressPage.addressName = detail.result.formattedAddress.toString();
      print(detail.result.adrAddress.toString());
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
        infoWindow: InfoWindow(title: "Destination"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: pos,
        onTap: () {
          setState(() {
            destination = Marker(markerId: MarkerId("destination"), infoWindow: InfoWindow(title: ""));;
          });
        },
      );
      //origin = Marker(markerId: MarkerId("origin"));
    });

    final directions = await DirectionsAPI().getDirections(origin: LatLng(currentLocation!.latitude!, currentLocation!.longitude!), destination: destination.position);
    setState(() {
      info = directions;
      distance = double.parse((Geolocator.distanceBetween(destination.position.latitude, destination.position.longitude,
          currentLocation!.latitude!, currentLocation!.longitude!) / 1000).toStringAsFixed(2));

      AddNewAddressPage.addressLocation = destination.position;

    });

    List<Placemark> placemarks = await placemarkFromCoordinates(destination.position.latitude, destination.position.longitude);

    print("FIRST: ${destination.position.latitude} ${destination.position.longitude}");



    for(int i = 0; i < placemarks.length; i++) {
      if(!isNumeric(placemarks[i].name!)) {
        setState(() {
          addressString = placemarks[i].name!;
          fullAddress = "${placemarks[i].name.toString()}, "
              "${placemarks[i].subAdministrativeArea.toString()}, ${placemarks[i].administrativeArea.toString()}, ${placemarks[i].country.toString()}";

          AddNewAddressPage.addressName = fullAddress = "${placemarks[i].name.toString()}, "
              "${placemarks[i].subAdministrativeArea.toString()}, ${placemarks[i].administrativeArea.toString()}, ${placemarks[i].country.toString()}";
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

}
