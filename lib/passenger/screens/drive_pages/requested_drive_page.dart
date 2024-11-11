import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/driver.dart';
import 'package:ebuber/classes/passenger.dart';
import 'package:ebuber/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ebuber/passenger/screens/drive_pages/change_destination_page.dart';
import 'package:ebuber/passenger/screens/main_pages/drive_page.dart';
import 'package:ebuber/passenger/screens/main_pages/home_page.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import '../../../classes/activedriver.dart';
import '../../../classes/recentdrive.dart';
import '../../../classes/sentrequest.dart';
import '../../../constant.dart';
import '../main_screen.dart';

class RequestedDrivePage extends ConsumerStatefulWidget {

  final String driveUid;
  final String driverUid;
  final String targetName;

  const RequestedDrivePage({super.key, required this.driveUid, required this.driverUid, required this.targetName});

  @override
  ConsumerState<RequestedDrivePage> createState() => _RequestedDrivePageState();
}

class _RequestedDrivePageState extends ConsumerState<RequestedDrivePage> {

  late GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();

  final LatLng _center = const LatLng(45.521563, -122.677433);
  final LatLng _destination = const LatLng(45.56752541455082, -122.64465091440553);
  List<LatLng> polyLineCoordinates = [];


  loc.LocationData? currentLocation;

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

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

    });

    setState(() {});


  }

  updateLocationOnFirebase() async {
    await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid).update({
      "latlng" : [currentLocation!.latitude!, currentLocation!.longitude!]
    });
  }

  void getPolyPoints() async {

    LatLng destination = LatLng(0, 0);

    await FirebaseFirestore.instance.collection("sentrequests").doc(widget.driveUid).get().then((value) {
      setState(() {
        destination = LatLng(value["to"][0], value["to"][1]);
        print(destination);
      });
    });

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "android",
      PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      PointLatLng(destination.latitude, destination.latitude),
    );


    if(result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) => polyLineCoordinates.add(
          LatLng(point.latitude, point.longitude)
      )
      );
      setState(() {});
    }
  }

  String roadCheckButton = !MainScreen.english ? "Motora Bindim" : "I'm with the Driver";
  String bottomText = !MainScreen.english ? "Sürücü henüz gelmedi" : "Driver isn't here yet";
  String topText = !MainScreen.english ? "Sürücü ile buluştuğunda buraya tıklamaya unutma!" :
  "Don't forget to press this button when you meet the driver!";
  
  @override
  void initState() {
    // TODO: implement initState
    getCurrentLocation();
    getPolyPoints();
    super.initState();
    checkDriveStat();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final sentrequest = ref.watch(sentRequestStreamProvider(widget.driveUid));
    final driver = ref.watch(driverStreamProvider(widget.driverUid));
    final passenger = ref.watch(passengerStreamProvider(FirebaseAuth.instance.currentUser!.uid));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: checkDriveStat,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Container(
              padding: EdgeInsets.all(12),
              child: sentrequest.when(
                error: (error, stackTrace) => Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(context,
                          _routeToSignInScreen(MainScreen()), (route) => false),
                      child: Text(!MainScreen.english ? "Ana Menüye Dön" : "Back to Main Screen",
                        style: TextStyle(fontFamily: kFontFamily, fontSize: 15,
                            fontWeight: FontWeight.bold, color: kDarkColors[6]),),
                    ),
                    Text(!MainScreen.english ? "Gösterilecek veri bulunamıyor"
                        : "No data has been found", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,
                        fontFamily: kFontFamily)),
                  ],
                ),),
                data: (data) {
                  try {
                    return driver.when(
                      data: (driver) => passenger.when(
                        data: (passenger) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance.collection("drivers").doc(widget.driverUid)
                                .collection("activedrive").doc(widget.driveUid).snapshots(),

                            builder: (context, snapshot) {
                              if(!snapshot.hasData) return Container();
                              return Column(
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
                                      Text(!MainScreen.english ? "İstenilen Yolculuk" : "Requested Drive", style: TextStyle(
                                          fontSize: 17.5, fontFamily: kFontFamily, color: kDarkColors[8], fontWeight: FontWeight.bold
                                      ),),

                                    ],
                                  ),
                                  SizedBox(height: height * .05,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(topText, style: TextStyle(
                                          color: Colors.redAccent, fontSize: 15, fontFamily: kFontFamily, fontWeight: FontWeight.bold
                                      ),),
                                      SizedBox(height: height * .02,),
                                      Container(
                                        width: width, height: height * .05,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(5),
                                          child: MaterialButton(
                                            color: kLightColors[6],
                                            onPressed: () async {
                                              if(roadCheckButton == (!MainScreen.english ? "Sürüşü Bitir" : "Complete the Drive")) {
                                                await finishTheDrive(passenger, driver);
                                              }
                                              else
                                                await driveCheck(driver, passenger, snapshot.data!.data()!, data.toDocument());
                                            },
                                            child: Text(roadCheckButton, style: TextStyle(
                                                fontWeight: FontWeight.bold, fontFamily: kFontFamily, fontSize: 15, color: Colors.black54
                                            ),),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: height * .02,),
                                      Text(bottomText, style: TextStyle(
                                          color: Colors.black, fontSize: 12.5, fontFamily: kFontFamily, fontWeight: FontWeight.bold
                                      ),),
                                    ],
                                  ),
                                  SizedBox(height: height * .05,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(!MainScreen.english ? "Nereden:" : "From:", style: TextStyle(
                                              fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.bold
                                          ),),
                                          SizedBox(width: 5,),
                                          Text(!MainScreen.english ? "Konumun" : "Your Location", style: TextStyle(
                                              fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.normal
                                          ),),
                                        ],
                                      ),
                                      SizedBox(height: height * .04,),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(!MainScreen.english ? "Nereye:" : "To:", style: TextStyle(
                                              fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.bold
                                          ),),
                                          SizedBox(width: 5,),
                                          ConstrainedBox(
                                            constraints: BoxConstraints(maxWidth: width * .75),
                                            child: Text("${data.placeToGo}", style: TextStyle(
                                                fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.normal
                                            ),  maxLines: 3, overflow: TextOverflow.ellipsis),
                                          ),
                                        ],
                                      ),
                                      data.bookednow ? Container() : SizedBox(height: height * .04,),
                                      data.bookednow ? Container() : Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(!MainScreen.english ? "Sürücünün Geleceği Vakit:" : "Time That Driver Arrives:", style: TextStyle(
                                              fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.bold
                                          ),),
                                          SizedBox(width: 5,),
                                          ConstrainedBox(
                                            constraints: BoxConstraints(maxWidth: width * .75),
                                            child: Text("${formatTime(data.date)}", style: TextStyle(
                                                fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.normal
                                            ),  maxLines: 3, overflow: TextOverflow.ellipsis),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * .05,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(!MainScreen.english ? "Sürücü:" : "Driver:", style: TextStyle(
                                          fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.bold
                                      ),),
                                      SizedBox(height: height * .02,),
                                      Column(
                                        children: [
                                          Container(
                                            width: width, height: height * .175 * 1.2,
                                            child: DriversHomePage(height: height, width: width, horizontal: 0,
                                                factor: 1.1, color: kLightColors[8], messageButton: () async {
                                                  await finishTheDrive(passenger, driver);
                                                  Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(MainScreen()), (route) => false);
                                                },
                                                driver: driver.toDocument()),

                                          ),
                                          SizedBox(height: height * .05,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(!MainScreen.english ? "Sürücünün Konumu:" : "Driver's Location:", style: TextStyle(
                                                  fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.bold
                                              ),),
                                              SizedBox(height: height * .02,),
                                              Container(
                                                width: width, height: height * .4,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(15),

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
                                                  ) :GoogleMap(
                                                    onMapCreated: _onMapCreated,
                                                    initialCameraPosition: CameraPosition(
                                                      target: LatLng(driver.latlng[0], driver.latlng[1]),
                                                      zoom: 11.0,
                                                    ),

                                                    polylines: {
                                                      Polyline(
                                                        polylineId: PolylineId("route"),
                                                        points: polyLineCoordinates,
                                                        color: kDarkColors[4],
                                                        width: 3,
                                                      )
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
                                                      Marker(
                                                        markerId: MarkerId("source"),
                                                        position: LatLng(driver.latlng[0], driver.latlng[1]),
                                                      ),

                                                      Marker(
                                                          markerId: MarkerId("source"),
                                                          position: LatLng(data.to[0], data.to[1]),
                                                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
                                                      ),
                                                    },
                                                    zoomControlsEnabled: false,
                                                  ),
                                                ),

                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: height * .05,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      /*TextButton(
                                  child: Text(!MainScreen.english ? "Gidilecek Konumu Değiştir" : "Change The Destination",
                                      style: TextStyle(fontFamily: kFontFamily, fontSize: 17.5,
                                          color: kDarkColors[4], fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    Navigator.push(context, _routeToSignInScreen(ChangeDestinationPage(
                                      driveUid: widget.driveUid, driverUid: widget.driverUid,)));
                                  },
                                ),*/
                                      data.status != "request" ? Container() : Container(
                                        width: width, height: height * .07,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: MaterialButton(
                                              color: kDarkColors[2],
                                              onPressed: () => cancelTheRequest(driver, passenger, data),
                                              child: Text(!MainScreen.english ? "İsteği İptal Et" : "Cancel The Request", style: TextStyle(
                                                  color: Colors.white, fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.bold
                                              ),)
                                          ),
                                        ),
                                      )

                                    ],
                                  ),
                                ],
                              );
                            }
                        ),
                        error: (error, stackTrace) => Container(),
                        loading: () => Center(child: CircularProgressIndicator(),),

                      ),
                      error: (error, stackTrace) => Container(),
                      loading: () => Center(child: CircularProgressIndicator(),),

                    );
                  }

                  catch(E) {
                    return Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pushAndRemoveUntil(context,
                              _routeToSignInScreen(MainScreen()), (route) => false),
                          child: Text(!MainScreen.english ? "Ana Menüye Dön" : "Back to Main Screen",
                            style: TextStyle(fontFamily: kFontFamily, fontSize: 17.5,
                                fontWeight: FontWeight.bold, color: kDarkColors[6]),),
                        ),
                        Text(!MainScreen.english ? "Gösterilecek veri bulunamıyor"
                            : "No data has been found", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,
                            fontFamily: kFontFamily)),
                      ],
                    ),);
                  }
                },
                loading: () => Center(child: CircularProgressIndicator(),),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatTime(DateTime dateTime) {
    final formatter = DateFormat.Hm(); // H: 24 saatlik saat, m: dakika

    return formatter.format(dateTime);
  }

  driveCheck(Driver driver, Passenger passenger, Map<String, dynamic> value, Map<String, dynamic> value2) async {
    if(roadCheckButton == (!MainScreen.english ? "Araca Bindim" : "I'm with the Driver")) {
      setState(() {
        bottomText = !MainScreen.english ? "Sürücünün onayı bekleniyor..." :
        "Awaiting Driver's approval...";

        roadCheckButton = !MainScreen.english ? "İptal Et" : "Cancel";
      });
      await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("sentrequests").doc(widget.driveUid).update({
        "hasmet" : true
      });
      sendPushMessage("Yolcun ile buluştun mu?", "${passenger.name} ile buluştun!", driver.token, passenger.uid);
    }
    else {

      if(value["hasmet"] && value2["hasmet"]) {
        if(value["hasfinished"] && value2["hasfinished"]) {
          print("Drive is over");
          sendPushMessage("Yolcu istediği ulaştı!", "${passenger.name} ile sürüşünüz bitti!", driver.token, passenger.uid);

        }

        else {

          if(!value2["hasfinished"]) {
            await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid)
                .collection("sentrequests").doc(widget.driveUid).update({
              "hasfinished" : true
            });

            if(value["hasfinished"]) {
              setState(() {
                bottomText = !MainScreen.english ? "Sürücü sürüşü onayladı." :
                "Driver approved the drive";

                roadCheckButton = !MainScreen.english ? "Sürüşü Bitir" : "Complete the Drive";
                topText = !MainScreen.english ? "Sürüşü tamamlayıp ana menüye dönebilirsin" :
                "You can complete the drive and turn back to the main screen";
              });
              sendPushMessage("Yolcu istediği ulaştı!", "${passenger.name} ile sürüşünüz bitti!", driver.token, passenger.uid);

            }

            else {
              setState(() {
                bottomText = !MainScreen.english ? "Sürücünün onayı bekleniyor..." :
                "Awaiting Driver's approval...";

                roadCheckButton = !MainScreen.english ? "İptal Et" : "Cancel";
                topText = !MainScreen.english ? "Sürücü onayladıktan sonra sürüş tamamlanacaktır." :
                "Drive will be completed after driver has approved the drive";
              });
              sendPushMessage("Yolcunu istediği yere bıraktın mı?", "${passenger.name} ile sürüşünüz bitti mi?", driver.token, passenger.uid);

            }

          }

          else if(value["hasfinished"] && !value2["hasfinished"]) {
            await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid)
                .collection("sentrequests").doc(widget.driveUid).update({
              "hasfinished" : false
            });
          }

        }
      }

      else {

        setState(() {
          roadCheckButton = !MainScreen.english ? "Araca Bindim" :
          "I'm with the Driver";
          bottomText = !MainScreen.english ? "Sürücü henüz gelmedi" :
          "Driver isn't here yet";
          topText = !MainScreen.english ? "Sürücü ile buluştuğunda buraya tıklamaya unutma!" :
          "Don't forget to press this button when you meet the driver!";
        });

        await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("sentrequests").doc(widget.driveUid).update({
          "hasmet" : false
        });
      }


    }
  }

  Future<void> checkDriveStat() async {
    await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("sentrequests").doc(widget.driveUid).get().then((value) async {

      await FirebaseFirestore.instance.collection("drivers").doc(widget.driverUid).collection("activedrive")
          .doc(widget.driveUid).get().then((value2) {
            setState(() {

              if(value["hasmet"] == true) {
                if(value2["hasmet"] == false) {
                  bottomText = !MainScreen.english ? "Sürücünün onayı bekleniyor..." :
                  "Awaiting Driver's approval...";
                  topText = !MainScreen.english ? "Sürücü ile buluştuğunda buraya tıklamaya unutma!" :
                  "Don't forget to press this button when you meet the driver!";
                  roadCheckButton = !MainScreen.english ? "İptal Et" : "Cancel";
                }

                else {


                  if(value["hasfinished"] && value2["hasfinished"]) {
                    bottomText = !MainScreen.english ? "Sürücü sürüşü onayladı." :
                    "Driver approved the drive";

                    roadCheckButton = !MainScreen.english ? "Sürüşü Bitir" : "Complete the Drive";
                    topText = !MainScreen.english ? "Sürüşü tamamlayıp ana menüye dönebilirsin" :
                        "You can complete the drive and turn back to the main screen";
                  }

                  else if(value["hasfinished"] && !value2["hasfinished"]) {
                    bottomText = !MainScreen.english ? "Sürücünün onayı bekleniyor..." :
                    "Awaiting Driver's approval...";

                    roadCheckButton = !MainScreen.english ? "İptal Et" : "Cancel";

                    topText = !MainScreen.english ? "Sürücü onayladıktan sonra sürüş tamamlanacaktır." :
                    "Drive will be completed after driver has approved the drive";
                  }

                  else {
                    bottomText = !MainScreen.english ? "Sürücü ile berabersin." :
                    "You're with the Driver";
                    topText = !MainScreen.english ? "Gideceğin yere vardığında buraya tıklamaya unutma!" :
                    "Don't forget to press this button when you get to the destination!";
                    roadCheckButton = !MainScreen.english ? "Hedefe Ulaştım" : "I Arrived the Destination";
                  }
                }
              }

              else {
              roadCheckButton = !MainScreen.english ? "Araca Bindim" : "I'm with the Driver";
              bottomText = !MainScreen.english ? "Sürücü henüz gelmedi" : "Driver isn't here yet";
              }
            });
      });


    });
  }

  finishTheDrive(Passenger passenger, Driver driver) async {

    Map<String, dynamic> drive = {};

    await FirebaseFirestore.instance.collection("passengers")
        .doc(FirebaseAuth.instance.currentUser!.uid).collection("sentrequests")
        .doc(widget.driveUid).get().then((value) {
          setState(() {
            drive = value.data()!;
          });
    });

    int length = 0;

    final drivePrice = ref.read(driveKmStreamProvider);

    drivePrice.when(
      loading: () {

      },
      error: (error, stackTrace) {

      },
      data: (price) async {
        String driveUid = "${FirebaseAuth.instance.currentUser!.uid}_${widget.driverUid}_${DateTime.now()}";

        RecentDrive recentDrive = RecentDrive(
          bookednow: drive["bookednow"],
          to: [drive["to"][0], drive["to"][1]],
          status: "completed",
          point: 0.01,
          passenger_uid: FirebaseAuth.instance.currentUser!.uid,
          enddate: DateTime.now(),
          distance: drive["distance"],
          amount: ((DateTime.now().difference(
              (drive["date"] as Timestamp).toDate()).inMinutes) * price).toDouble(),
          note: drive["note"],
          from: [currentLocation!.latitude, currentLocation!.longitude],
          destinationFullAddress: drive["destinationFullAddress"],
          drive_uid: driveUid,
          driver_uid: widget.driverUid,
          passengers_count: drive["passengers_count"],
          placeToGo: drive["placeToGo"],
          startdate: (drive["date"] as Timestamp).toDate(),
        );


        await FirebaseFirestore.instance.collection("passenger").doc(passenger.uid).update({
          "money" : passenger.money - recentDrive.amount
        });

        await FirebaseFirestore.instance.collection("drivers").doc(widget.driverUid).update({
          "money" : driver.money + recentDrive.amount
        });

        await FirebaseFirestore.instance.collection("recentdrives").doc(driveUid)
            .set(recentDrive.toDocument());


        await FirebaseFirestore.instance.collection("passengers")
            .doc(FirebaseAuth.instance.currentUser!.uid).collection("sentrequests")
            .doc("${FirebaseAuth.instance.currentUser!.uid}_${widget.driverUid}").delete();

        await FirebaseFirestore.instance.collection("drivers")
            .doc(widget.driverUid).collection("activedrive")
            .doc("${FirebaseAuth.instance.currentUser!.uid}_${widget.driverUid}").delete();

        await FirebaseFirestore.instance.collection("drivers")
            .doc(widget.driverUid).update({
          "busy" : false
        });
        Navigator.pop(context);
      },
    );


  }

  cancelTheRequest(Driver driver, Passenger passenger, SentRequest sentRequest) async {

    await showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(!MainScreen.english ? "İptal" : "Cancel", style: TextStyle(fontWeight: FontWeight.bold,
          fontSize: 15, fontFamily: kFontFamily),),

      content: Text(!MainScreen.english ? "İptal etmek istediğinize emin misiniz?"
          : "Are you sure that you want to delete the request?", style: TextStyle(
          fontSize: 15, fontFamily: kFontFamily),),

      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(MainScreen()), (route) => false);


            await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid)
                .collection("sentrequests").doc(widget.driveUid).delete();

            await FirebaseFirestore.instance.collection("drivers").doc(widget.driverUid)
                .collection("receivedrequests").doc(widget.driveUid).delete();

            await FirebaseFirestore.instance.collection("drivers").doc(widget.driverUid)
                .collection("activerequest").doc(widget.driveUid).delete();

            await FirebaseFirestore.instance.collection("drivers").doc(widget.driverUid).update({
              "busy" : false
            });

          },

          child: Text(!MainScreen.english ? "Evet" : "Yes", style: TextStyle(fontFamily: kFontFamily),),
        ),
        TextButton(
          onPressed: () async {

            Navigator.pop(context);
          },

          child: Text(!MainScreen.english ? "Hayır" : "No", style: TextStyle(fontFamily: kFontFamily),),
        ),
      ],
    ));

    sendPushMessage("Yolcu isteğinizi iptal etti!", "${passenger.name} ile sürüşünüz iptal edildi!", driver.token, passenger.uid);




  }

  void sendPushMessage(String body, String title, String token, currentUid) async {
    try {
      await post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
          'key=your-key-here',
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
