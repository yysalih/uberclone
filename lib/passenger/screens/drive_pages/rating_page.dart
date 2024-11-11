import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/rating.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ebuber/passenger/screens/main_pages/home_page.dart';

import '../../../constant.dart';
import '../main_screen.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({Key? key, required this.driverUid, required this.driveUid}) : super(key: key);
  final String driverUid;
  final String driveUid;

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {

  double _rating = 0.0;

  TextEditingController commentController = TextEditingController();
  final homeScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: homeScaffoldKey,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(!MainScreen.english ? "Yorum Yap" : "Add A Comment", style: TextStyle(
                      fontSize: 25, fontFamily: kFontFamily, color: kDarkColors[8], fontWeight: FontWeight.bold
                  ),),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("$_rating", style: TextStyle(color: Colors.black, fontFamily: kFontFamily,
                      fontSize: 25, fontWeight: FontWeight.bold),),
                  SizedBox(height: 15,),
                  Center(
                    child: RatingBar.builder(
                      wrapAlignment: WrapAlignment.center,
                      glow: false,
                      initialRating: 5,
                      minRating: .5,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemSize: width * .125,
                      unratedColor: kLightColors[5],
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          print(rating);
                          _rating = rating;
                        });
                      },
                      updateOnDrag: true,
                    ),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(!MainScreen.english ? "Yorum ekle" : "Leave a comment", style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 17.5, fontFamily: kFontFamily
                  ),),
                  SizedBox(height: 5,),
                  Container(
                    width: width, height: height * .2,
                    child: ClipRRect(
                      child: Material(
                        color: kLightColors[9],
                        child: TextField(
                          controller: commentController,
                          maxLines: 5,
                          style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: kFontFamily),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: !MainScreen.english ? "Sürücü hakkında bir yorum ekle" : "Leave a comment about the driver",
                            hintStyle: TextStyle(color: Colors.black54, fontSize: 20, fontFamily: kFontFamily),
                            contentPadding: EdgeInsets.all(10),
                            counterText: "",
                          ),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(!MainScreen.english ? "Oyladığın Sürücü" : "The Driver You Rate", style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 17.5, fontFamily: kFontFamily
                  ),),
                  SizedBox(height: 5,),
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection("drivers").doc(widget.driverUid).snapshots(),
                    builder: (context, snapshot) {
                      if(!snapshot.hasData) return Center(child: CircularProgressIndicator(),);

                      try {
                        return Container(
                          width: width, height: height * .175 * 1.2,
                          child: DriversHomePage(height: height, width: width, driver: snapshot.data!.data()!,
                              messageButton: () {}, factor: 1.25, horizontal: 0, color: kLightColors[9],),
                        );
                      }

                      catch(E) {
                        return Center(child: Text(!MainScreen.english ? "Sürücüye ait bir bilgi bulunamadı" :
                        "No data has been found about this driver", style: TextStyle(
                          fontFamily: kFontFamily, fontSize: 20, fontWeight: FontWeight.bold
                        ),),);
                      }
                    },
                  )

                ],
              ),
              Container(
                width: width, height: height * .07,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MaterialButton(
                    color: kDarkColors[2],
                    onPressed: () async {
                      if(_rating != 0.0) {
                        await rateTheDriver();
                        Navigator.pop(context);

                      }

                      else {

                      }
                    },
                    child: Text(!MainScreen.english ? "Onayla" : "Complete", style: TextStyle(
                        color: Colors.white, fontFamily: kFontFamily, fontSize: 22.5, fontWeight: FontWeight.bold
                    ),),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  rateTheDriver() async {
    Rating rating = Rating(
      uid: "${FirebaseAuth.instance.currentUser!.uid}_${widget.driverUid}",
      date: DateTime.now(),
      point: _rating,
      by: FirebaseAuth.instance.currentUser!.uid,
      comment: commentController.text, $for: widget.driverUid,
    );

    if(commentController.text != "") {
      await FirebaseFirestore.instance.collection("drivers").doc(widget.driverUid)
          .collection("ratings").doc("${FirebaseAuth.instance.currentUser!.uid}_${widget.driverUid}").set(
          rating.toDocument()
      );
      double driverPoint = 0.0;

      await FirebaseFirestore.instance.collection("drivers").doc(widget.driverUid).get().then((value) {
        setState(() {
          driverPoint = value["point"];
        });
      });

      await FirebaseFirestore.instance.collection("drivers").doc(widget.driverUid).update({
        "point" : driverPoint == 0.0 ? driverPoint + _rating : (driverPoint + _rating) / 2
      });

      await FirebaseFirestore.instance.collection("recentdrives")
          .doc(widget.driveUid).update({
        "point" : driverPoint == 0.0 ? driverPoint + _rating : (driverPoint + _rating) / 2
      });

    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(MainScreen.english ? "A comment has to be written." : "Sürücüye yorum bırakmak zorunludur.", style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontFamily: kFontFamily, fontSize: 12.5
        ),),
        backgroundColor: kDarkColors[6],
      ));
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
