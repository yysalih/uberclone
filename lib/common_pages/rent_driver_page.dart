import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/passenger/screens/message_pages/messages_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../classes/rent.dart';
import '../constant.dart';
import '../main.dart';
import '../passenger/screens/main_screen.dart';

class RentDriverPage extends ConsumerStatefulWidget {
  final Rent rent;

  const RentDriverPage({Key? key, required this.rent}) : super(key: key);

  @override
  ConsumerState<RentDriverPage> createState() => _RentDriverPageState();
}

class _RentDriverPageState extends ConsumerState<RentDriverPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final driver = ref.watch(driverStreamProvider(widget.rent.driver));
    final passenger = ref.watch(passengerStreamProvider(widget.rent.passenger));

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          child: passenger.when(
            loading: () => Center(child: CircularProgressIndicator(),),
            data: (passenger) => Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Text(MainScreen.english ? "Rent Driver" : "Sürücü Kirala", style: TextStyle(
                        fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.bold
                    ),),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(MainScreen.english ? "Location" : "Konum", style: TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 15, fontFamily: kFontFamily),),
                        SizedBox(height: 5,),
                        Container(
                          width: width, height: 40,
                          decoration: BoxDecoration(
                            color: kLightColors[8].withOpacity(.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, color: kBottomBarIconsColor, size: 20,),
                                SizedBox(width: 5,),
                                Text("${widget.rent.city}, ${widget.rent.county}", style: TextStyle(
                                    fontFamily: kFontFamily, fontSize: 15
                                ),),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(MainScreen.english ? "Start Date" : "Başlangıç", style: TextStyle(fontWeight: FontWeight.bold,
                                fontSize: 15, fontFamily: kFontFamily),),
                            SizedBox(height: 5,),
                            Container(
                              width: width * .45, height: 40,
                              decoration: BoxDecoration(
                                color: kLightColors[8].withOpacity(.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_month, color: kBottomBarIconsColor, size: 20,),
                                    SizedBox(width: 5,),
                                    Text("${widget.rent.startdate.day} ${months[widget.rent.startdate.month]}", style: TextStyle(
                                        fontFamily: kFontFamily, fontSize: 15
                                    ),),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(MainScreen.english ? "End Date" : "Bitiş", style: TextStyle(fontWeight: FontWeight.bold,
                                fontSize: 15, fontFamily: kFontFamily),),
                            SizedBox(height: 5,),
                            Container(
                              width: width * .45, height: 40,
                              decoration: BoxDecoration(
                                color: kLightColors[8].withOpacity(.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_month, color: kBottomBarIconsColor, size: 20,),
                                    SizedBox(width: 5,),
                                    Text("${widget.rent.enddate.day} ${months[widget.rent.enddate.month]}", style: TextStyle(
                                        fontFamily: kFontFamily, fontSize: 15
                                    ),),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                driver.when(
                  data: (driver) => Column(
                    children: [
                      Row(
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
                              Navigator.push(context, _routeToSignInScreen(MessagesPage(chatID: widget.rent.driver)));
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
                    ],
                  ),
                  error: (error, stackTrace) => Container(),
                  loading: () => Center(),
                ),
                Image.asset("images/ills/campaign.png", width: width * .7, fit: BoxFit.cover,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(MainScreen.english ? "Total Amount: " : "Toplam Fiyat: ", style: TextStyle(
                          fontFamily: kFontFamily, fontSize: 15,
                        ),),

                        Text("${widget.rent.amount} TL", style: TextStyle(
                            fontFamily: kFontFamily, fontSize: 20, fontWeight: FontWeight.bold
                        ),),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Container(
                      width: width, height: 45,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: MaterialButton(
                          color: kLightColors[0],
                          onPressed: () async {

                            if(passenger.money >= widget.rent.amount) {
                              await FirebaseFirestore.instance.collection("rents")
                                  .doc(widget.rent.uid).set(widget.rent.toDocument());
                              await FirebaseFirestore.instance.collection("passengers").doc(passenger.uid).update({
                                "money" : passenger.money - widget.rent.amount,
                              });
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(MainScreen.english ? "Sent a rent request" : "Kiralama isteği gönderildi", style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17.5, fontFamily: kFontFamily, color: Colors.white
                                ),),
                                backgroundColor: Colors.green,
                              ));
                              Navigator.pop(context);
                            }
                            else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(MainScreen.english ? "Insufficient balance" : "Yetersiz Bakiye", style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17.5, fontFamily: kFontFamily, color: Colors.white
                                ),),
                                backgroundColor: Colors.redAccent,
                              ));
                            }


                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(MainScreen.english ? "Complete" : "Tamamla", style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold, fontSize: 17.5, fontFamily: kFontFamily
                                ),),
                                Image.asset("images/icons/car.png", color: Colors.white, width: 20,)
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            error: (error, stackTrace) => Container(),
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
