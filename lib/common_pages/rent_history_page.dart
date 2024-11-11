import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/common_pages/rent_inner_page.dart';
import 'package:ebuber/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constant.dart';
import '../passenger/screens/main_screen.dart';
import '../passenger/screens/message_pages/messages_page.dart';

class RentHistoryPage extends ConsumerStatefulWidget {
  const RentHistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RentHistoryPage> createState() => _RentHistoryPageState();
}

class _RentHistoryPageState extends ConsumerState<RentHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final rents = ref.watch(rentsStreamProvider);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
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
                  Text(MainScreen.english ? "Rents" : "Kiralamalar", style: TextStyle(
                    fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.bold
                  ),)

                ],
              ),
              SizedBox(height: 10,),
              rents.when(
                loading: () => Center(child: CircularProgressIndicator(),),
                error: (error, stackTrace) {
                  print(error);
                  print(stackTrace);
                  return Container();
                },
                data: (rents) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width, maxHeight: height * .75),
                    child: ListView.builder(
                      itemCount: rents.length,
                      itemBuilder: (context, index) {
                        final driver = ref.watch(driverStreamProvider(rents[index].driver));
                        return Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Container(
                            width: width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 1,
                                  spreadRadius: 1
                                )
                              ]
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: MaterialButton(
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      driver.when(
                                        data: (driver) => Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundImage: CachedNetworkImageProvider(driver.photo),
                                                  backgroundColor: kColor1,
                                                  radius: 25,
                                                ),
                                                SizedBox(width: 10,),
                                                Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(driver.name, style: TextStyle(
                                                      fontWeight: FontWeight.bold, fontFamily: kFontFamily, fontSize: 15
                                                  ),),
                                                  Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          for(int i = 0; i < driver.point.toInt(); i++)
                                                            Icon(Icons.star, color: Colors.orangeAccent, size: 15,)
                                                        ],
                                                      ),
                                                      SizedBox(width: 5,),
                                                      Text("${driver.point.toStringAsFixed(1)} - ", style: TextStyle(
                                                          fontFamily: kFontFamily, fontSize: 12.5
                                                      ),),

                                                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                                        stream: FirebaseFirestore.instance.collection("drivers").doc(driver.uid)
                                                            .collection("recentdrives").snapshots(),
                                                        builder: (context, snapshot) {
                                                          if(!snapshot.hasData) return Text("0 ${MainScreen.english ? "Drives" : "Yolculuk"}",
                                                            style: TextStyle(fontSize: 12.5, fontFamily: kFontFamily,),);
                                                          return Text("${snapshot.data!.docs.length} ${MainScreen.english ? "Drives" : "Yolculuk"}",
                                                            style: TextStyle(fontSize: 12.5, fontFamily: kFontFamily,),);
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              ],
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(context, _routeToSignInScreen(MessagesPage(chatID: rents[index].driver)));
                                              },
                                              child: Image.asset("images/icons/comment.png", width: 20, color: Colors.white,),

                                              style: ElevatedButton.styleFrom(
                                                shape: CircleBorder(),
                                                padding: EdgeInsets.all(10),
                                                primary: kLightColors[2], // <-- Button color
                                                onPrimary: kLightColors[0], // <-- Splash color
                                              ),
                                            ),
                                          ],
                                        ),
                                        error: (error, stackTrace) {
                                          print(error);
                                          print(stackTrace);
                                          return Container();
                                        },
                                        loading: () => Container(),
                                      ),
                                      SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(Icons.location_on, size: 20,),
                                              SizedBox(width: 5,),
                                              Text("${rents[index].city}\n${rents[index].county}", style: TextStyle(
                                                fontSize: 15, fontFamily: kFontFamily
                                              ),)
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(Icons.calendar_month, size: 20,),
                                              SizedBox(width: 5,),
                                              Text("${rents[index].startdate.day} ${months[rents[index].startdate.month]}\n"
                                                  "${rents[index].enddate.day} ${months[rents[index].enddate.month]}", style: TextStyle(
                                                fontSize: 15, fontFamily: kFontFamily
                                              ),)
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20,),
                                      Row(
                                        children: [
                                          Icon(rents[index].status == "sent" ? Icons.timer_outlined
                                              : rents[index].status == "accepted" ? Icons.done
                                              : Icons.close, size: 20, color: rents[index].status == "sent" ? null
                                              : rents[index].status == "accepted" ? Colors.green
                                              : Colors.redAccent,),
                                          SizedBox(width: 5,),
                                          Text("${
                                          rents[index].status == "sent" ? (MainScreen.english ? "Request sent" : "İstek gönderildi")
                                          : rents[index].status == "accepted" ? (MainScreen.english ? "Request accepted" : "İstek onaylandı")
                                              : (MainScreen.english ? "Request rejected" : "İstek reddedildi")

                                          }", style: TextStyle(
                                            fontFamily: kFontFamily, fontSize: 12.5, fontWeight: FontWeight.bold
                                          ),)
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(context, _routeToSignInScreen(RentInnerPage(rent: rents[index].uid,)));
                                },
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
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
