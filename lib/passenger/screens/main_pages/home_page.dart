import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/address_detail_page.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/passenger/screens/drive_pages/requested_drive_page.dart';
import 'package:ebuber/passenger/screens/main_screen.dart';
import 'package:ebuber/passenger/screens/message_pages/messages_page.dart';
import '../ProfilePageInnerScreens/driver_profile_screen.dart';
import '../drive_pages/rsvp_page.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  final homeScaffoldKey = GlobalKey<ScaffoldState>();

  final LatLng _center = const LatLng(45.521563, -122.677433);
  final LatLng _destination = const LatLng(45.56752541455082, -122.64465091440553);

  Map<String, dynamic> currentUser = {};
  Set<Marker> markersList = {};


  List addresses = [
    [!MainScreen.english ? "Ev" : "Home", "house", "Doğanbey Mahallesi, Talatpaşa Blv No:38, 06050 Altındağ/Ankara"],
    [!MainScreen.english ? "İş" : "Work", "work", "Plevne, Çocuk Acil Girişi, Babür Cd. No:41, 06080 Altındağ/Ankara"],
    [!MainScreen.english ? "Okul" : "School", "school", "Esertepe, Gen. Dr. Tevfik Sağlam Cd No:182, 06020 Keçiören/Ankara"],
    [!MainScreen.english ? "Kayıtlı\nAdres" : "Saved Address", "favorite", "Yücetepe, Akdeniz Cd. No:31, 06570 Çankaya/Ankara"],
  ];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  List<LatLng> polyLineCoordinates = [];
  loc.LocationData? currentLocation;
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      key: homeScaffoldKey,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: width, height: height,
              child: currentLocation == null ? Center(
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
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                mapToolbarEnabled: false,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: 11.0,
                ),

                markers: {
                  Marker(
                    markerId: MarkerId("currentLocation"),
                    position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                    icon: sourceIcon,
                  ),

                  Marker(
                      markerId: MarkerId("source"),
                      position: _center
                  ),

                  Marker(
                    markerId: MarkerId("destination"),
                    position: _destination,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),

                  ),
                },
                zoomControlsEnabled: false,
              )
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                GestureDetector(
                  onTap: _handlerPressButton,

                  child: Container(
                    padding: EdgeInsets.all(5), width: width, height: height * .08,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Material(
                        color: Colors.white,
                        child: TextField(
                          enabled: false,
                          maxLines: 1, style: TextStyle(fontFamily: kFontFamily, fontSize: 15),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search, color: kDarkColors[4],),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(top: 17.5, left: 20, right: 20),
                            counterText: "", enabled: false,
                            hintText: !MainScreen.english ? "Bugün nereye gidiyorsun?" : "Where are you going today?",
                            hintStyle: TextStyle(fontFamily: kFontFamily, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(

                  padding: EdgeInsets.only(top: 5, bottom: 5,),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: height * .05, maxWidth: width),
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance.collection("passengers")
                      .doc(FirebaseAuth.instance.currentUser!.uid).collection("addresses").snapshots(),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData) return Container();
                        return ListView.builder(
                          padding: EdgeInsets.only(left: 5, right: 5,),
                          itemCount: snapshot.data!.docs.length,
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => snapshot.data!.docs[index]["uid"] != "home" && snapshot.data!.docs[index]["uid"] != "school"
                              && snapshot.data!.docs[index]["uid"] != "work" ? Container() :
                          SavedAddresses(height: height, width: width,
                              title: snapshot.data!.docs[index]["title"],
                              icon: addresses[snapshot.data!.docs[index]["title"] == "İş" ? 1
                                  : (snapshot.data!.docs[index]["title"] == "Ev" ? 0 : 2)][1],
                              onPressed: () {},
                              address: snapshot.data!.docs[index]["description"], addressMap: snapshot.data!.docs[index].data()),
                        );
                      },
                    ),
                    //child: ListView.builder(itemBuilder: itemBuilder),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10, top: 5),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: height * .165, maxWidth: width),
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance.collection("drivers").snapshots(),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator(),);
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) => DriversHomePage(driver: snapshot.data!.docs[index].data(),
                              height: height, width: width, messageButton: () {}),
                          itemCount: snapshot.data!.docs.length,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection("passengers")
                  .doc(FirebaseAuth.instance.currentUser!.uid).collection("sentrequests").snapshots(),

              builder: (context, snapshot) {
                if(!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator(color: kDarkColors[4]),);
                }

                try {
                  if(snapshot.data!.docs[0].data().isNotEmpty)
                    return Container(
                    alignment: Alignment.topCenter,

                    child: Container(
                      width: width, height: height * .25,
                      padding: EdgeInsets.all(12),
                      child: ClipRRect(
                        child: MaterialButton(
                          color: Colors.white,
                          onPressed: () {
                            Navigator.push(context, _routeToSignInScreen(RequestedDrivePage(
                              driverUid: snapshot.data!.docs[0].data()["driver_uid"],
                              driveUid: snapshot.data!.docs[0].data()["drive_uid"],
                              targetName: snapshot.data!.docs[0].data()["placeToGo"],
                            )));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(!MainScreen.english ? "İstenilen Sürücü" : "Requested Driver",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: kFontFamily),),
                                    SizedBox(height: 15,),
                                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                      builder: (context, snapshot2) {
                                        if(!snapshot.hasData) {
                                          return Center(child: CircularProgressIndicator(),);
                                        }

                                        try {
                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundImage: NetworkImage("${snapshot2.data!.data()!["photo"] ?? ""}"),
                                                    radius: 17.5,
                                                  ),
                                                  SizedBox(width: 10,),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      ConstrainedBox(
                                                        child: Text("${snapshot2.data!.data()!["name"]  ?? ""}",
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
                                                          Text("${(snapshot2.data!.data()!["point"] as double).toStringAsFixed(2)} - 325 ${!MainScreen.english ? "Yorum" : "Ratings"}",
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
                                                      Navigator.push(context, _routeToSignInScreen(DriverProfileScreen(driverUid: snapshot2.data!.data()!["uid"])));
                                                    },
                                                    child: Text(!MainScreen.english ? "Profile Git" : "Go Profile", style: TextStyle(
                                                        color: kDarkColors[2], fontWeight: FontWeight.bold,
                                                        fontFamily: kFontFamily, fontSize: 15), maxLines: 1,),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(context,
                                                          _routeToSignInScreen(MessagesPage(
                                                              chatID: snapshot2.data!.data()!["uid"])));
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
                                          );
                                        }
                                        catch(E) {
                                          return Container();
                                        }
                                      },
                                      stream: FirebaseFirestore.instance.collection("drivers")
                                          .doc(snapshot.data!.docs[0]["driver_uid"]).snapshots(),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset("images/icons/pin.png", width: width * .05, fit: BoxFit.contain),
                                        SizedBox(width: 5,),
                                        ConstrainedBox(
                                          child: Text("${snapshot.data!.docs[0]["placeToGo"]}", style: TextStyle(
                                              fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.normal
                                          ), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          constraints: BoxConstraints(maxWidth: width * .5),
                                        ),
                                      ],
                                    ),
                                    Text("${snapshot.data!.docs[0]["status"] == "request"
                                        ? (!MainScreen.english ? "İstek Gönderildi" : "Requested")
                                        : snapshot.data!.docs[0]["status"] == "rejected" ? (!MainScreen.english ? "Reddedildi" : "Rejected")
                                        : (!MainScreen.english ? "Onaylandı" : "Accepted")}", style: TextStyle(
                                        fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.bold
                                    ),),
                                    /*Text("${DateTime.now().difference((snapshot.data!.docs[0]["date"] as Timestamp).toDate()).inMinutes < 1
                                              ? (!MainScreen.english ? "Şimdi" : "Now") :
                                          (DateTime.now().difference((snapshot.data!.docs[0]["date"] as Timestamp).toDate()).inMinutes < 60
                                              ? "${DateTime.now().difference((snapshot.data!.docs[0]["date"] as Timestamp).toDate()).inMinutes} ${!MainScreen.english ? "DK" : "Min"}"
                                              : "${DateTime.now().difference((snapshot.data!.docs[0]["date"] as Timestamp).toDate()).inHours} ${!MainScreen.english ? "Saat" : "h"}")}",
                                            style: TextStyle(fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.normal
                                          ),),*/

                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  );

                  else if(snapshot.data!.docs[0].data().isEmpty)
                    return Container();

                  else
                    return Container();
                }

                catch(e) {
                  print("I'm in catch");
                  return Container();
                }
              },
            ),


          ],
        )

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

  @override
  void initState() {
    getCurrentLocation();
    getPolyPoints();

    super.initState();
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyA8DU86tOXazmyjn8TL3sU3hNiSWQhb88Q",
      PointLatLng(_center.latitude, _center.longitude),
      PointLatLng(_destination.latitude, _destination.longitude),
    );


    if(result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) => polyLineCoordinates.add(
          LatLng(point.latitude, point.longitude)
      )
      );
      setState(() {});
    }
  }


  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size.fromRadius(5)), "images/icons/pin.png",
    ).then((icon) {
      sourceIcon = icon;
    });
  }

  getCurrentUser() async {
    await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
      setState(() {
        currentUser = value.data()!;
      });
    });
  }



  void getCurrentLocation() async {
    loc.Location location = loc.Location();


    location.getLocation().then((location) async{
      setState(() {
        currentLocation = location;
      });
      await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid).update({
        "latlng" : [location.latitude!.toDouble(), location.longitude!.toDouble()]
      });
    });



    /*GoogleMapController googleMapController = await mapController.future;


    location.onLocationChanged.listen((newLoc) {
      currentLocation= newLoc;

      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: 13.5,
          target: LatLng(newLoc.latitude!, newLoc.longitude!),
        ),
      ),);

    });
    setState(() {});*/

  }



  Future<void> _handlerPressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: "AIzaSyA8DU86tOXazmyjn8TL3sU3hNiSWQhb88Q",
      mode: Mode.overlay,
      language: !MainScreen.english ? "en" : "tr",
      strictbounds: false,
      types: [],
      decoration: InputDecoration(
        hintText: !MainScreen.english ? "Yaz" : 'Search',
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white),
        ),
      ),
        components: [Component(Component.country,"tr"),Component(Component.country,"usa")]
    );

    displayPrediction(p!, homeScaffoldKey.currentState);
  }

  void onError(PlacesAutocompleteResponse response){
    //homeScaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(response.errorMessage!)));
  }

  Future<void> displayPrediction(Prediction p, ScaffoldState? currentState) async {

    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: "AIzaSyA8DU86tOXazmyjn8TL3sU3hNiSWQhb88Q",
        apiHeaders: await const GoogleApiHeaders().getHeaders()
    );

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    markersList.clear();
    markersList.add(Marker(markerId: const MarkerId("0"),position: LatLng(lat, lng),infoWindow: InfoWindow(title: detail.result.name)));

    setState(() {});

    mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));

  }
}

class SavedAddresses extends StatelessWidget {
  const SavedAddresses({
    Key? key,
    required this.height, required this.width, required this.icon, required this.address,
    required this.title, required this.addressMap, required this.onPressed,
  }) : super(key: key);

  final double height;
  final double width;
  final String icon;
  final String address;
  final String title;
  final Map<String, dynamic> addressMap;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return 1 == 1 ? ElevatedButton(
        onPressed: () {
          onPressed();
        },//!destinationBar ? Icons.sort : Icons.density_medium_sharp
        child: Image.asset("images/icons/${icon != "home" && icon != "work" && icon != "school" ? "distance" : icon}.png", width: width * .065, fit: BoxFit.contain,),//Image.asset("images/icons/comment.png", fit: BoxFit.contain, width: width * .075, color: Colors.white,),

        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(10),
          backgroundColor: kDarkColors[9]

        )
    ) :
    Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        width: width * .3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7.5),
          child: MaterialButton(
            color: Colors.white,//Colors.grey.shade200,
            onPressed: () {
              onPressed();
              //Navigator.push(context, _routeToSignInScreen(AddresDetailPage(addressMap: addressMap,)));
            },
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset("images/icons/${icon != "home" && icon != "work" && icon != "school" ? "distance" : icon}.png", width: width * .05, fit: BoxFit.contain,),
                  SizedBox(width: 10,),
                  Text(title, style: TextStyle(fontSize: 12.5, fontFamily: kFontFamily, color: Colors.black, fontWeight: FontWeight.bold),)
                ],
              ),
            ),
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

class DriversHomePage extends ConsumerStatefulWidget {
  final double height;
  final double width;
  final double horizontal;
  final double factor;
  final Map<String, dynamic> driver;
  final Color color;
  final Function messageButton;

  DriversHomePage({required this.height, required this.width, required this.driver,
    this.color = Colors.white, this.horizontal = 7.5, this.factor = 1, required this.messageButton});

  @override
  ConsumerState<DriversHomePage> createState() => _DriversHomePageState();
}

class _DriversHomePageState extends ConsumerState<DriversHomePage> {
  @override
  Widget build(BuildContext context) {
    final driver = ref.watch(driverStreamProvider(widget.driver["uid"]));
    return driver.when(
      data: (driver) => Container(
        padding: EdgeInsets.symmetric(horizontal: widget.horizontal),
        child: Container(

          width: widget.width * .65,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),

            child: MaterialButton(
              color: widget.color,
              child: Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: widget.width * .25 * widget.factor,
                              height: widget.height * .04 * widget.factor,
                              decoration: BoxDecoration(
                                  color: kBackgroundGrey,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: Center(
                                child: Text("${driver.car["plate"]}", style:
                                TextStyle(color: kBottomBarIconsColor, fontSize: 12.5 * widget.factor ,
                                    fontWeight: FontWeight.bold, fontFamily: kFontFamily),),
                              ),
                            ),
                            SizedBox(height: 2.5 * widget.factor,),
                            Text("${driver.car["type"]} - ${driver.car["color"]}",
                              style: TextStyle(fontFamily: kFontFamily, fontSize: 9 * widget.factor, color: Colors.black54, fontWeight: FontWeight.bold),)
                          ],
                        ),
                        Text(!MainScreen.english ? "Ücret:\n300 TL" : "Amount:\n300 TL", style: TextStyle(
                            fontSize: 10 * widget.factor, fontFamily: kFontFamily, color: Colors.black, fontWeight: FontWeight.bold
                        ),)
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, _routeToSignInScreen(DriverProfileScreen(driverUid: driver.uid)));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage("${driver.photo}"),
                                radius: 17.5 * widget.factor,
                              ),
                              SizedBox(width: 10 * widget.factor,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: widget.width * .3 * widget.factor,),
                                    child: Text("${driver.name}", style: TextStyle(fontSize: 12.5, fontFamily: kFontFamily,
                                        fontWeight: FontWeight.bold, color: kBottomBarIconsColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                  SizedBox(height: 2 * widget.factor,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.star, color: Colors.orangeAccent, size: widget.height * 0.02,),
                                      SizedBox(width: 2.5 * widget.factor,),
                                      Text("${(driver.point).toStringAsFixed(2)} - 325 ${!MainScreen.english ? "Yorum" : "Ratings"}",
                                        style: TextStyle(fontFamily: kFontFamily, fontSize: 10 * widget.factor),),


                                    ],
                                  ),



                                ],
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              widget.messageButton();
                            },
                            child: Image.asset("images/icons/comment.png", fit: BoxFit.contain,
                              width: widget.width * .05 * widget.factor, color: kDarkColors[9],),

                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              primary: Colors.white, // <-- Button color
                              onPrimary: Colors.red, // <-- Splash color
                            ),
                          )
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              onPressed: () {
                //Navigator.push(context, _routeToSignInScreen(RSVPPage(driver: {}, info: ,)));
              },
            ),
          ),
          //padding: EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 10)
        ),
      ),
      loading: () => Center(child: CircularProgressIndicator(),),
      error: (error, stackTrace) => Container(),
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

