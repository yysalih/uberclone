import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/passenger/screens/drive_pages/rating_page.dart';
import 'package:ebuber/passenger/screens/main_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecentDrivesInnerPage extends ConsumerStatefulWidget {
  RecentDrivesInnerPage({required this.driveUid, required this.driverUid});

  final String driveUid;
  final String driverUid;

  @override
  ConsumerState<RecentDrivesInnerPage> createState() => _RecentDrivesInnerPageState();
}

class _RecentDrivesInnerPageState extends ConsumerState<RecentDrivesInnerPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final recentDrive = ref.watch(recentDriveStreamProvider(widget.driveUid));
    final driver = ref.watch(driverStreamProvider(widget.driverUid));

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      fontSize: 25, fontFamily: kFontFamily, color: kDarkColors[8], fontWeight: FontWeight.bold
                  ),),
                ],
              ),
              driver.when(
                data: (driver) => Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(driver.photo),
                      radius: 60,
                    ),
                    SizedBox(height: 15,),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: height * .1, maxWidth: width),
                      child: Text(driver.name, style: TextStyle(
                          fontSize: 25, color: Colors.black, fontFamily: kFontFamily, fontWeight: FontWeight.bold
                      ), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 2),
                    ),
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.orangeAccent, size: 30,),
                        SizedBox(width: 5,),
                        Text("${double.parse(driver.point.toString())}", style: TextStyle(
                            fontSize: 22.5, color: Colors.black, fontFamily: kFontFamily, fontWeight: FontWeight.bold
                        ),),
                      ],
                    ),
                  ],
                ),
                loading: () => Center(child: CircularProgressIndicator(),),
                error: (error, stackTrace) => Container(),
              ),

              recentDrive.when(
                error: (error, stackTrace) => Container(),
                loading: () => Center(child: CircularProgressIndicator(),),
                data: (recentDrive) => Column(
                  children: [
                    RatingBar.builder(
                      wrapAlignment: WrapAlignment.center,
                      glow: false,
                      initialRating: double.parse(recentDrive.point.toString()),
                      minRating: .5,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemSize: width * .125,
                      unratedColor: kLightColors[5],
                      itemCount: 5,
                      tapOnlyMode: false,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        Navigator.push(context, _routeToSignInScreen(
                            RatingPage(driverUid: widget.driverUid,
                              driveUid: widget.driveUid,)));
                      },
                    ),
                    SizedBox(height: 10,),
                    Container(
                      width: width, height: height * .07,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: kLightColors[0]
                      ),
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(!MainScreen.english ? "Yolculuk Tarihi" : "Date of Drive", style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold,
                              fontFamily: kFontFamily, fontSize: 20
                          ),),
                          Text("${recentDrive.enddate.day}."
                              "${recentDrive.enddate.month}."
                              "${recentDrive.enddate.year}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,
                                fontFamily: kFontFamily, color: Colors.white),)
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      width: width, height: height * .07,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: kLightColors[0]
                      ),
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(!MainScreen.english ? "Mesafe" : "Distance", style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold,
                              fontFamily: kFontFamily, fontSize: 20
                          ),),
                          Text("${(recentDrive.distance)} KM",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,
                                fontFamily: kFontFamily, color: Colors.white),)
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      width: width, height: height * .07,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: kLightColors[0]
                      ),
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(!MainScreen.english ? "Mesafe" : "Distance", style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold,
                              fontFamily: kFontFamily, fontSize: 20
                          ),),
                          Text("${recentDrive.amount} ₺",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,
                                fontFamily: kFontFamily, color: Colors.white),)
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      width: width, height: height * .07,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: kLightColors[0]
                      ),
                      padding: EdgeInsets.all(10),
                      child: Text(!MainScreen.english ? "Yolculuk Faturası" : "Drive Bill", style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold,
                          fontFamily: kFontFamily, fontSize: 20
                      ),),
                    ),
                  ],
                ),
              )

            ],
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
