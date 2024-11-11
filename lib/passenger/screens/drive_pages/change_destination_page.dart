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
import 'package:ebuber/passenger/screens/main_screen.dart';
import 'package:ebuber/utils/directions_api.dart';
import 'package:ebuber/utils/directions_model.dart';
import 'package:google_maps_webservice/places.dart';
import '../../../constant.dart';
import 'package:google_api_headers/google_api_headers.dart';


class ChangeDestinationPage extends StatefulWidget {

  final String driveUid;
  final String driverUid;

  const ChangeDestinationPage({super.key, required this.driveUid, required this.driverUid, });

  @override
  State<ChangeDestinationPage> createState() => _ChangeDestinationPageState();
}

class _ChangeDestinationPageState extends State<ChangeDestinationPage> {

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
              onMapCreated: (controller) => mapController = controller,

              //_onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 11.0,
              ),
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
              alignment: Alignment.topCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 15),
                    child: ElevatedButton(
                        onPressed: () {
                          final imageUrl = "https://firebasestorage.googleapis.com/v0/b/uberclone-d441d.appspot.com/o/files%2Fscaled_image_picker1056267769859809128.png?alt=media&token=b7cdd7a1-2251-4e4e-8ba7-2e87297a7f3a";
                          setState(() {
                            if(!destinationBar) destinationBar = true;
                            else if(destinationBar) destinationBar = false;
                          });
                        },
                        child: Icon(!destinationBar ? Icons.sort : Icons.density_medium_sharp, color: Colors.white, size: 20),//Image.asset("images/icons/comment.png", fit: BoxFit.contain, width: width * .075, color: Colors.white,),

                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(10),
                          primary: kDarkColors[2], // <-- Button color
                          onPrimary: kLightColors[6], // <-- Splash color
                        )
                    ),
                  ),
                  destinationBar ? Container(
                    padding: EdgeInsets.only(top: 20, right: 20),
                    child: Container(
                      width: width * .7,
                      height: height * .225,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset("images/icons/destination.png", width: width * .125, fit: BoxFit.contain,),
                              Column(
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
                                        child: Text(!MainScreen.english ? "Konumun" : "Your Location", style: TextStyle(color: Colors.black,
                                            fontFamily: kFontFamily, fontSize: 15),)
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
                                        child: Text(addressString, style: TextStyle(color: Colors.black,
                                            fontFamily: kFontFamily, fontSize: 15),)
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: width,
                            height: height * .04,
                            decoration: BoxDecoration(
                                color: kDarkColors[1],
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: Center(
                              child: Text(!MainScreen.english ? "En Hızlı ${info.totalDuration}, ${info.totalDistance}"
                                  : "Fastest ${info.totalDuration}, ${info.totalDistance}", style: TextStyle(
                                  color: Colors.white, fontSize: 15, fontFamily: kFontFamily, fontWeight: FontWeight.bold
                              ),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ): Container(),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: TextButton(
                    child: Text(!MainScreen.english ? "Geri Dön" : "Back", style: TextStyle(
                      fontFamily: kFontFamily, fontSize: 20, color: kDarkColors[6], fontWeight: FontWeight.bold
                    ),),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                if(info.totalDistance != "") Container(
                  padding: EdgeInsets.all(12),
                  child: Container(
                    width: width, height: height * .07,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: MaterialButton(
                        color: kDarkColors[4],
                        onPressed: () async {
                          await updateDestination();
                          Navigator.pop(context);
                        },
                        child: Text(!MainScreen.english ? "Adresi Kaydet" : "Save the Address", style: TextStyle(
                            color: Colors.white, fontFamily: kFontFamily, fontSize: 22.5, fontWeight: FontWeight.bold
                        ),),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  updateDestination() async {
    try {
      User? user = await FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection("passengers").doc(user!.uid)
          .collection("sentrequests").doc("${user.uid}_${widget.driverUid}").update({

        "to" : [destination.position.latitude, destination.position.longitude],
        "distance" : distance,
        "placeToGo" : addressString
      });

      await FirebaseFirestore.instance.collection("drivers").doc(widget.driverUid)
          .collection("receivedrequests").doc("${user.uid}_${widget.driverUid}").update({
        "to" : [destination.position.latitude, destination.position.longitude],
        "distance" : distance,
        "placeToGo" : addressString
      });
      print("Request sent");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kDarkColors[2],
          content: Text(!MainScreen.english ? "Gidilecek adres değiştirildi" : "The destination has been changed",
              style: TextStyle(fontFamily: kFontFamily, fontSize: 17.5, color: Colors.white, fontWeight: FontWeight.bold)),),
      );
    }

    catch(E) {
      print(E);
    }
  }


  _handlerPressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: "your-api-key-here",
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



    setState(() {
      addressString = detail.result.name.toString();
      print(detail.result.adrAddress);
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
    });

    List<Placemark> placemarks = await placemarkFromCoordinates(destination.position.latitude, destination.position.longitude);

    print("FIRST: ${destination.position.latitude} ${destination.position.longitude}");



    for(int i = 0; i < placemarks.length; i++) {
      if(!isNumeric(placemarks[i].name!)) {
        setState(() {
          addressString = placemarks[i].name!;
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
