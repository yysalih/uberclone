import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/recent_drives_inner_page.dart';
import 'package:ebuber/passenger/screens/drive_pages/rating_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main_screen.dart';

class RecentDrivesPage extends ConsumerStatefulWidget {
  RecentDrivesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RecentDrivesPage> createState() => _RecentDrivesPageState();
}

class _RecentDrivesPageState extends ConsumerState<RecentDrivesPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Color color = Colors.black87;

    final recentDrives = ref.watch(recentDrivesStreamProvider);

    return Scaffold(

      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            padding: EdgeInsets.only(top: 12, left: 0, right: 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    Text(!MainScreen.english ? "Geçmiş Yolculuklar" : "Recent Drives", style: TextStyle(
                        fontSize: 17.5, fontFamily: kFontFamily, color: kDarkColors[8], fontWeight: FontWeight.bold
                    ),),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Image.asset("images/ills/car.png", width: width * .5,
                        fit: BoxFit.contain,),
                      SizedBox(height: 10,),
                      recentDrives.when(
                        data: (recentDrives) => recentDrives.length != 0 ? ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: width, maxHeight: height),
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () {
                                Navigator.push(context, _routeToSignInScreen(
                                    RecentDrivesInnerPage(driveUid: recentDrives[index].drive_uid,
                                        driverUid: recentDrives[index].driver_uid)));
                                /*Navigator.push(context, _routeToSignInScreen(
                                RatingPage(driverUid: snapshot.data!.docs[index]["driver_uid"],
                                  driveUid: snapshot.data!.docs[index]["drive_uid"],))),*/
                              },
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                                      gradient: LinearGradient(
                                          colors: [kDarkColors[0], kLightColors[4]], begin: Alignment.topLeft,
                                          end: Alignment.bottomRight
                                      ),),
                                    width: width, height: height * .125, padding: EdgeInsets.all(12),
                                    child: Row(

                                      children: [
                                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                          builder: (context, snapshot2) {
                                            if(!snapshot2.hasData)
                                              return Center(child: CircularProgressIndicator(),);

                                            try {
                                              return CircleAvatar(
                                                backgroundImage: CachedNetworkImageProvider(snapshot2.data!.data()!["photo"]),
                                                radius: 30,
                                              );
                                            }
                                            catch(E) {
                                              return Center(child: CircularProgressIndicator(),);
                                            }
                                          },
                                          stream: FirebaseFirestore.instance.collection("drivers")
                                              .doc(recentDrives[index].driver_uid).snapshots(),
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,

                                          children: [
                                            Image.asset("images/icons/calendar3.png", color: color,
                                              fit: BoxFit.contain, width: width * .075,),
                                            SizedBox(height: 10,),
                                            Text("${recentDrives[index].enddate.day}."
                                                "${recentDrives[index].enddate.month}."
                                                "${recentDrives[index].enddate.year}",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,
                                                  fontFamily: kFontFamily, color: color),)
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,

                                          children: [
                                            Image.asset("images/icons/clock.png", color: color,
                                              fit: BoxFit.contain, width: width * .075,),
                                            SizedBox(height: 10,),

                                            Text("${(recentDrives[index].enddate.difference(recentDrives[index].startdate).inMinutes / 60) > 1
                                                ?
                                            (recentDrives[index].enddate.difference(recentDrives[index].startdate).inMinutes / 60).toStringAsFixed(0) + "${!MainScreen.english ? " Saat" : " Hours"}"
                                                :
                                            recentDrives[index].enddate.difference(recentDrives[index].startdate).inMinutes} "
                                                "${(recentDrives[index].enddate.difference(recentDrives[index].startdate).inMinutes / 60) > 1 ? ""
                                                : (!MainScreen.english ? "DK" : "Mins")}"
                                              ,
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,
                                                  fontFamily: kFontFamily, color: color),)
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,

                                          children: [
                                            Image.asset("images/icons/distance.png", color: color,
                                              fit: BoxFit.contain, width: width * .075,),
                                            SizedBox(height: 10,),

                                            Text("${recentDrives[index].distance} KM",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,
                                                  fontFamily: kFontFamily, color: color),)
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,

                                          children: [
                                            Image.asset("images/icons/wallet.png", color: color,
                                              fit: BoxFit.contain, width: width * .075,),
                                            SizedBox(height: 10,),

                                            Text("${recentDrives[index].amount} ₺",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,
                                                  fontFamily: kFontFamily, color: color),)
                                          ],
                                        ),
                                      ],
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                ],
                              ),
                            ),
                            /*GestureDetector(
                            onTap: () => Navigator.push(context, _routeToSignInScreen(
                                RatingPage(driverUid: snapshot.data!.docs[index]["driver_uid"], driveUid: snapshot.data!.docs[index]["drive_uid"],))),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: LinearGradient(
                                      colors: [kDarkColors[0], kLightColors[4]], begin: Alignment.topLeft, end: Alignment.bottomRight
                                  ),),
                                  width: width, height: height * .3, padding: EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                            builder: (context, snapshot2) {
                                              if(!snapshot2.hasData)
                                                return Center(child: CircularProgressIndicator(),);

                                              try {
                                                return Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundImage: NetworkImage(snapshot2.data!.data()!["photo"]),
                                                          radius: 35,
                                                        ),

                                                        SizedBox(height: 0,),
                                                        Row(
                                                          children: [
                                                            Icon(Icons.star, color: Colors.orangeAccent, size: 22.5,),
                                                            SizedBox(width: 0,),
                                                            Text("${(snapshot2.data!.data()!["point"] as double).toStringAsFixed(2)}",
                                                              style: TextStyle(fontFamily: kFontFamily,
                                                                fontSize: 15, color: Colors.white),)
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(width: 15,),
                                                    Column(
                                                      children: [
                                                        ConstrainedBox(
                                                          constraints: BoxConstraints(maxWidth: width * .3,
                                                          maxHeight: height * .1),
                                                          child: Text(snapshot2.data!.data()!["name"],style: TextStyle(
                                                            fontFamily: kFontFamily, color: Colors.white,
                                                            fontSize: 17.5, fontWeight: FontWeight.bold
                                                          ), overflow: TextOverflow.ellipsis, maxLines: 2),
                                                        ),
                                                        SizedBox(height: 5,),
                                                        Text("${snapshot2.data!.data()!["car"]["type"]} "
                                                            "- ${snapshot2.data!.data()!["car"]["alttype"]}",
                                                        style: TextStyle(fontSize: 15,
                                                            fontFamily: kFontFamily, color: Colors.white),),
                                                        SizedBox(height: 5,),
                                                        Text("${snapshot2.data!.data()!["car"]["color"]}",
                                                        style: TextStyle(fontSize: 15,
                                                            fontFamily: kFontFamily, color: Colors.white),),
                                                        SizedBox(height: 5,),
                                                        Text("${snapshot2.data!.data()!["car"]["plate"]}",
                                                          style: TextStyle(fontSize: 15,
                                                              fontFamily: kFontFamily, color: Colors.white),),
                                                      ],
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                    )
                                                  ],
                                                );
                                              }
                                              catch(E) {
                                                return Center(child: CircularProgressIndicator(),);
                                              }
                                            },
                                            stream: FirebaseFirestore.instance.collection("drivers")
                                                .doc(snapshot.data!.docs[index]["driver_uid"]).snapshots(),
                                          ),
                                          Column(
                                            children: [
                                              Text(!MainScreen.english ? "Yolculuğa Puanın" : "Your Rate",
                                                style: TextStyle(fontFamily: kFontFamily, fontSize: 10,
                                                    color: Colors.white),),
                                              SizedBox(height: 2,),
                                              Row(
                                                children: [
                                                  Icon(Icons.star, color: Colors.orangeAccent, size: 22.5,),
                                                  SizedBox(width: 0,),
                                                  Text("${(snapshot.data!.docs[index]["point"] as double).toStringAsFixed(2)}",
                                                    style: TextStyle(fontFamily: kFontFamily,
                                                      fontSize: 15, color: Colors.white),)
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Text("${!MainScreen.english ? "Fiyat" : "Amount"}: 200\$",
                                                style: TextStyle(fontFamily: kFontFamily, fontSize: 15,
                                                    color: Colors.white),),
                                            ],
                                          ),
                                        ],
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      ),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(!MainScreen.english ? "Nereden" : "From",
                                                style: TextStyle(color: Colors.white, fontFamily: kFontFamily,
                                                  fontSize: 12.5, fontWeight: FontWeight.bold),),
                                              SizedBox(height: 5,),
                                              Row(
                                                children: [
                                                  Image.asset("images/icons/pin.png", width: width * 0.05,
                                                    fit: BoxFit.contain,),
                                                  SizedBox(width: 5,),
                                                  ConstrainedBox(
                                                    constraints: BoxConstraints(maxWidth: width * .35,
                                                        maxHeight: height * .2),
                                                    child: Text("Caferağa, Küçükmoda Burnu Sk No:21, 34710 Kadıköy/İstanbul",
                                                        textAlign: TextAlign.start,
                                                        overflow: TextOverflow.ellipsis, maxLines: 3,
                                                        style: TextStyle(fontSize: 12.5, color: Colors.white,
                                                            fontFamily: kFontFamily
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(!MainScreen.english ? "Nereye" : "To",
                                                style: TextStyle(color: Colors.white, fontFamily: kFontFamily,
                                                  fontSize: 12.5, fontWeight: FontWeight.bold),),
                                              SizedBox(height: 5,),
                                              Row(
                                                children: [
                                                  Image.asset("images/icons/pin.png", width: width * 0.05,
                                                    fit: BoxFit.contain,),
                                                  SizedBox(width: 5,),
                                                  ConstrainedBox(
                                                    constraints: BoxConstraints(maxWidth: width * .35,
                                                        maxHeight: height * .2),
                                                    child: Text("${snapshot.data!.docs[index]["destinationFullAddress"]}",
                                                        textAlign: TextAlign.start, overflow: TextOverflow.ellipsis,
                                                        maxLines: 3, style: TextStyle(fontSize: 12.5, color: Colors.white,
                                                            fontFamily: kFontFamily
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10,),
                              ],
                            ),
                          ),*/
                            itemCount: recentDrives.length,
                          ),
                        ) :
                        Center(child: Text(!MainScreen.english ? "Henüz bir yolculuk yapmadın" :
                        "You haven't been in a drive yet", style: TextStyle(fontSize: 15,
                            fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: kFontFamily
                        ),),),
                        loading: () => Center(child: CircularProgressIndicator(),),
                        error: (error, stackTrace) => Container(),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
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
}
