
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/rating.dart';
import 'package:ebuber/main.dart';
import 'package:flutter/material.dart';
import 'package:ebuber/passenger/screens/main_screen.dart';
import 'package:ebuber/passenger/screens/message_pages/chats_page.dart';
import 'package:ebuber/passenger/screens/message_pages/messages_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constant.dart';

class DriverProfileScreen extends ConsumerStatefulWidget {
  DriverProfileScreen({Key? key, required this.driverUid}) : super(key: key);
  final String driverUid;

  @override
  ConsumerState<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends ConsumerState<DriverProfileScreen> {
  List<String> days = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Pzr"];

  List<String> daysEng = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<String> hours = ["00\n00", "01\n00", "02\n00", "03\n00", "04\n00", "05\n00", "06\n00",
  "07\n00", "08\n00", "09\n00", "10\n00", "11\n00", "12\n00", "13\n00", "14\n00", "15\n00", "16\n00",
  "17\n00", "18\n00", "19\n00", "20\n00", "21\n00", "22\n00", "23\n00"];

  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final driver = ref.watch(driverStreamProvider(widget.driverUid));
    final ratings = ref.watch(ratingsStreamProvider(widget.driverUid));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(12),
            child: driver.when(
              data: (driver) => Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                          Text(!MainScreen.english ? "Sürücün" : "Your Driver", style: TextStyle(
                              fontSize: 25, fontFamily: kFontFamily, color: kDarkColors[8], fontWeight: FontWeight.bold
                          ),),
                        ],
                      ),
                      SizedBox(height: height * .03,),
                      Column(
                        children: [
                          CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider("${driver.photo}"),
                            radius: width * .15,
                          ),
                          SizedBox(height: 10,),
                          Text("${driver.name}",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black,
                                fontFamily: kFontFamily, fontSize: 20),),
                          SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  for(int i = 0; i < driver.point.toInt(); i++)
                                    Icon(Icons.star, color: Colors.orangeAccent, size: height * 0.025,),
                                ],
                              ),
                              SizedBox(width: 2.5,),
                              Text("${driver.point}",
                                style: TextStyle(fontFamily: kFontFamily, fontSize: 15),),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: height * .03,),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance.collection("drivers").doc(driver.uid).collection("recentdrives").snapshots(),
                        builder: (context, snapshot) {
                          if(!snapshot.hasData) return Container();
                          double toplamMesafe = 0.0;

                          // Gelen her belge için mesafeyi toplayalım
                          for (var doc in snapshot.data!.docs) {
                            // Eğer mesafe double türünde değilse ya da mesafe alanı eksikse atlayalım
                            if (doc.data()['distance'] is! double) continue;

                            // Mesafeyi toplayalım
                            toplamMesafe += doc.data()['distance'];
                          }
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset("images/icons/driver.png", width: width * .075, fit: BoxFit.contain, color: kDarkColors[5],),
                                  SizedBox(width: 10,),
                                  Text("${snapshot.data!.docs.length}\n${!MainScreen.english ? "Yolculuk" : "Drives"}",
                                    style: TextStyle(fontSize: 12.5, fontFamily: kFontFamily,
                                    color: Colors.black54, fontWeight: FontWeight.bold,), textAlign: TextAlign.center,)
                                ],
                              ),
                              IconButton(
                                splashRadius: 25,
                                onPressed: () {
                                  Navigator.push(context,
                                      _routeToSignInScreen(MessagesPage(chatID: driver.uid)));
                                },
                                icon: Image.asset("images/icons/email.png", width: width * .075, fit: BoxFit.contain, color: kDarkColors[4]),
                              ),
                              Row(
                                children: [
                                  Image.asset("images/icons/distance.png", width: width * .075, fit: BoxFit.contain, color: kDarkColors[5],),
                                  SizedBox(width: 5,),
                                  Text("${toplamMesafe} KM\n${!MainScreen.english ? "Yol Katetti" : "Drived"}", style: TextStyle(fontSize: 12.5, fontFamily: kFontFamily,
                                    color: Colors.black54, fontWeight: FontWeight.bold,), textAlign: TextAlign.center,)
                                ],
                              ),
                            ],
                          );
                        }
                      ),
                      SizedBox(height: height * .02,),
                      Container(
                        width: width, height: .5, color: kDarkColors[6],
                      ),
                    ],
                  ),
                  SizedBox(height: height * .02,),
                  ratings.when(
                    error: (error, stackTrace) => Column(
                      children: [
                        Image.asset("images/ills/nocomment.png", width: width * .5, fit: BoxFit.contain,),
                        SizedBox(height: 20,),
                        Text(MainScreen.english ? "No comment for this driver" : "Sürücü için henüz yorum yapılmamış.", style: TextStyle(
                            fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.bold
                        ),)
                      ],
                    ),
                    loading: () => Center(child: CircularProgressIndicator(),),
                    data: (ratings) {
                      if(ratings.length == 0) {
                        return GestureDetector(
                          onTap: () async {
                            Rating rating = Rating(
                              comment: "Bu sürücü oldukça iyi ve sakin bir sürüşe sahipti. Kendisiyle bir daha yolculuk dileğiyle...",
                              by: "Uf3JHuWLL8Ps8XwqNXVDB5izy5S2",
                              point: 5.0,
                              uid: "Uf3JHuWLL8Ps8XwqNXVDB5izy5S2_DSazPGSGLYXyh6XSOn0p",
                              date: DateTime.now(), $for: 'DSazPGSGLYXyh6XSOn0p'
                            );
                            await FirebaseFirestore.instance.collection("drivers").doc(widget.driverUid)
                                .collection("ratings").doc(rating.uid).set(rating.toDocument());
                          },
                          child: Column(
                            children: [
                              Image.asset("images/ills/nocomment.png", width: width * .5, fit: BoxFit.contain,),
                              SizedBox(height: 20,),
                              Text(MainScreen.english ? "No comment for this driver" : "Sürücü için henüz yorum yapılmamış.", style: TextStyle(
                                fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.bold
                              ),)
                            ],
                          ),
                        );

                      }
                      return Column(
                        children: [
                          for(int i = 0; i < ratings.length; i++)
                            Container(
                              width: width,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                  stream: FirebaseFirestore.instance.collection("passengers").doc(ratings[i].by).snapshots(),
                                  builder: (context, snapshot) {
                                    if(!snapshot.hasData) return Container();
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                Rating rating = Rating(
                                                    comment: "Bu sürücü oldukça iyi ve sakin bir sürüşe sahipti. Kendisiyle bir daha yolculuk dileğiyle...",
                                                    by: "Uf3JHuWLL8Ps8XwqNXVDB5izy5S2",
                                                    point: 5.0,
                                                    uid: "Uf3JHuWLL8Ps8XwqNXVDB5izy5S2_DSazPGSGLYXyh6XSOn0pss",
                                                    date: DateTime.now(), $for: 'DSazPGSGLYXyh6XSOn0p'
                                                );
                                                await FirebaseFirestore.instance.collection("drivers").doc(widget.driverUid)
                                                    .collection("ratings").doc(rating.uid).set(rating.toDocument());
                                              },
                                              child: CircleAvatar(
                                                backgroundImage: CachedNetworkImageProvider(snapshot.data!.data()!["photo"]),
                                                backgroundColor: kColor1,
                                                radius: 20,
                                              ),
                                            ),
                                            SizedBox(width: 5,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(snapshot.data!.data()!["name"], style: TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 12.5, fontFamily: kFontFamily
                                                ),),
                                                SizedBox(height: 5,),
                                                ConstrainedBox(
                                                  constraints: BoxConstraints(maxWidth: width * .675),
                                                  child: Text("${ratings[i].comment}", style: TextStyle(fontFamily: kFontFamily, fontSize: 10),),
                                                ),

                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.star, color: Colors.orangeAccent, size: 20,),
                                            SizedBox(height: 5,),
                                            Text(ratings[i].point.toStringAsFixed(2), style: TextStyle(
                                              fontSize: 10, fontFamily: kFontFamily ,fontWeight: FontWeight.bold
                                            ),)
                                          ],
                                        ),
                                      ],
                                    );
                                  }
                                ),
                              ),
                            ),
                        ],
                      );
                    },

                  )

                ],
              ),
              loading: () => Center(child: CircularProgressIndicator(),),
              error: (error, stackTrace) => Container(),
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

