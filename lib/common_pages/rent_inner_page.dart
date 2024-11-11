import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/passenger.dart';
import 'package:ebuber/passenger/screens/message_pages/messages_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../classes/driver.dart';
import '../classes/rent.dart';
import '../constant.dart';
import '../main.dart';
import '../passenger/screens/main_screen.dart';

class RentInnerPage extends ConsumerStatefulWidget {
  final String rent;

  const RentInnerPage({Key? key, required this.rent}) : super(key: key);

  @override
  ConsumerState<RentInnerPage> createState() => _RentDriverPageState();
}

class _RentDriverPageState extends ConsumerState<RentInnerPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final rent = ref.watch(rentStreamProvider(widget.rent));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
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
                    Text(MainScreen.english ? "Rent" : "Kiralama", style: TextStyle(
                        fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.bold
                    ),),
                  ],
                ),
                SizedBox(height: 20,),
                rent.when(
                  loading: () => Center(child: CircularProgressIndicator(),),
                  error: (error, stackTrace) => Container(),
                  data: (rent) {
                    final driver = ref.watch(driverStreamProvider(rent.driver));
                    final passenger = ref.watch(passengerStreamProvider(rent.passenger));

                    return passenger.when(
                      error: (error, stackTrace) => Container(),
                      data: (passenger) => driver.when(
                        data: (driver) =>  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
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
                                            Text("${rent.city}, ${rent.county}", style: TextStyle(
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
                                                Text("${rent.startdate.day} ${months[rent.startdate.month - 1]}", style: TextStyle(
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
                                                Text("${rent.enddate.day} ${months[rent.enddate.month - 1]}", style: TextStyle(
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

                            SizedBox(height: 20,),

                            Column(
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
                                        Navigator.push(context, _routeToSignInScreen(MessagesPage(chatID: rent.driver)));
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
                            SizedBox(height: 20,),

                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: kLightColors[0],
                                          child: CircleAvatar(
                                            radius: 23,
                                            backgroundColor: Colors.white,
                                            child: Image.asset("images/icons/clock.png", width: 20, color: kLightColors[4]),
                                          ),
                                        ),
                                        SizedBox(width: 5,),
                                        Container(
                                          height: 3, width: width * .1,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: rent.status != "sent" ? kLightColors[0] : kBottomBarIconsColor,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: rent.status != "sent"? kLightColors[0] : kBottomBarIconsColor,
                                          child: CircleAvatar(
                                            radius: 23,
                                            backgroundColor: Colors.white,
                                            child: Image.asset("images/icons/carrent.png", width: 20, color: rent.status != "sent"
                                                ? kLightColors[4] : kBottomBarIconsColor),
                                          ),
                                        ),
                                        SizedBox(width: 5,),
                                        Container(
                                          height: 3, width: width * .1,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: (rent.status != "sent" && DateTime.now().isAfter(rent.startdate)
                                                && DateTime.now().isBefore(rent.enddate)) ||
                                                (rent.status != "sent" && DateTime.now().isAfter(rent.startdate)
                                                    && DateTime.now().isAfter(rent.enddate))
                                                ? kLightColors[0] : kBottomBarIconsColor,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: (rent.status != "sent" && DateTime.now().isAfter(rent.startdate)
                                              && DateTime.now().isBefore(rent.enddate)) ||
                                              (rent.status != "sent" && DateTime.now().isAfter(rent.startdate)
                                                  && DateTime.now().isAfter(rent.enddate))

                                              ? kLightColors[0] : kBottomBarIconsColor,
                                          child: CircleAvatar(
                                            radius: 23,
                                            backgroundColor: Colors.white,
                                            child: Image.asset("images/icons/calendar3.png", width: 20,
                                              color: (rent.status != "sent" && DateTime.now().isAfter(rent.startdate)
                                                  && DateTime.now().isBefore(rent.enddate)) ||
                                                  (rent.status != "sent" && DateTime.now().isAfter(rent.startdate)
                                                      && DateTime.now().isAfter(rent.enddate))
                                                  ? kLightColors[0] : kBottomBarIconsColor,),
                                          ),
                                        ),
                                        SizedBox(width: 5,),
                                        Container(
                                          height: 3, width: width * .1,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: DateTime.now().isAfter(rent.enddate) && DateTime.now().isAfter(rent.startdate)
                                                && rent.status != "sent" ? kLightColors[0] : kBottomBarIconsColor,
                                          ),
                                        )
                                      ],
                                    ),
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: DateTime.now().isAfter(rent.enddate) && DateTime.now().isAfter(rent.startdate)
                                          && (rent.status != "sent") ? kLightColors[0] : kBottomBarIconsColor,
                                      child: CircleAvatar(
                                        radius: 23,
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.done, color: DateTime.now().isAfter(rent.enddate)
                                            && DateTime.now().isAfter(rent.startdate)
                                            && rent.status != "sent" ? kLightColors[4] : kBottomBarIconsColor,),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 30,),
                                rent.status == "canceled" ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [

                                    Image.asset("images/ills/canceled.png", width: width * .4, fit: BoxFit.contain,),
                                    SizedBox(height: 20,),
                                    Text(MainScreen.english ? "This rental has been canceled!"
                                        : "Bu kiralama iptal edildi!", style: TextStyle(
                                        fontWeight: FontWeight.bold, fontFamily: kFontFamily, fontSize: 20
                                    ), textAlign: TextAlign.center),
                                    SizedBox(height: 20,),
                                    Text(MainScreen.english ? "Your rental has been canceled. You can find another driver..."
                                        : "Kiralamanız iptal edildi. Başka bir sürücü bulabilirsin...", style: TextStyle(
                                        fontFamily: kFontFamily, fontSize: 15
                                    ), textAlign: TextAlign.center),
                                  ],
                                )
                                    : DateTime.now().isAfter(rent.startdate) && DateTime.now().isBefore(rent.enddate) && rent.status == "accepted" ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [

                                    Image.asset("images/ills/indates.png", width: width * .4, fit: BoxFit.contain,),
                                    SizedBox(height: 20,),
                                    Text(MainScreen.english ? "You should be with your driver nowadays."
                                        : "Bu günlerde sürücün ile buluşmuş olman lazım.", style: TextStyle(
                                        fontWeight: FontWeight.bold, fontFamily: kFontFamily, fontSize: 20
                                    ), textAlign: TextAlign.center),
                                    SizedBox(height: 20,),
                                    Text(MainScreen.english ? "Your rent has started!"
                                        : "Kiralama döneminiz başlamıştır!", style: TextStyle(
                                        fontFamily: kFontFamily, fontSize: 15
                                    ), textAlign: TextAlign.center),
                                  ],
                                ) :
                                DateTime.now().isAfter(rent.enddate) && DateTime.now().isAfter(rent.startdate) && rent.status == "accepted"
                                    ?
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [

                                    Image.asset("images/ills/afterdates.png", width: width * .25, fit: BoxFit.contain,),
                                    SizedBox(height: 20,),
                                    Text(MainScreen.english ? "Your rent is over anymore. Say goodbye!"
                                        : "Kiralama dönemin son buldu. El sallamayı unutma!", style: TextStyle(
                                        fontWeight: FontWeight.bold, fontFamily: kFontFamily, fontSize: 20
                                    ), textAlign: TextAlign.center),
                                    SizedBox(height: 10,),
                                    Text(MainScreen.english ? "Your rent is over with your driver. See you soon!"
                                        : "Sürücü ile olan kiralaman bitti. Tekrar görüşmek üzere!", style: TextStyle(
                                        fontFamily: kFontFamily, fontSize: 15
                                    ), textAlign: TextAlign.center),
                                  ],
                                ) : rent.status == "sent" ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [

                                    Image.asset("images/ills/sent.png", width: width * .4, fit: BoxFit.contain,),
                                    SizedBox(height: 20,),
                                    Text(MainScreen.english ? "Driver hasn't accepted the request yet"
                                        : "Sürücü kiralama isteğini henüz onaylamadı", style: TextStyle(
                                        fontWeight: FontWeight.bold, fontFamily: kFontFamily, fontSize: 20
                                    ), textAlign: TextAlign.center),
                                    SizedBox(height: 20,),
                                    Text(MainScreen.english ? "Waiting for driver to accept ther request..."
                                        : "Sürücünün kiralama isteğini onaylaması bekleniyor...", style: TextStyle(
                                        fontFamily: kFontFamily, fontSize: 15
                                    ), textAlign: TextAlign.center),
                                  ],
                                ) : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [

                                    Image.asset("images/ills/accepted.png", width: width * .4, fit: BoxFit.contain,),
                                    SizedBox(height: 20,),
                                    Text(MainScreen.english ? "Driver has accepted the request"
                                        : "Sürücü kiralama isteğini onayladı", style: TextStyle(
                                        fontWeight: FontWeight.bold, fontFamily: kFontFamily, fontSize: 20
                                    ), textAlign: TextAlign.center),
                                    SizedBox(height: 20,),
                                    Text(MainScreen.english ? "Waiting until the specified dates..."
                                        : "Belirtilen tarihlere kadar bekleniyor...", style: TextStyle(
                                        fontFamily: kFontFamily, fontSize: 15
                                    ), textAlign: TextAlign.center),
                                  ],
                                ),
                              ],
                            ),

                            //Center(child: Image.asset("images/ills/campaign.png", width: width * .7, fit: BoxFit.cover,)),
                            SizedBox(height: 20,),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(MainScreen.english ? "Total Amount: " : "Toplam Fiyat: ", style: TextStyle(
                                      fontFamily: kFontFamily, fontSize: 15,
                                    ),),

                                    Text("${rent.amount} TL", style: TextStyle(
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
                                        print("or here");
                                        if(rent.status == "canceled" || rent.status == "finished") {
                                          print("I'm here");
                                        }
                                        else handleButton(rent, passenger, driver);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 5),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              rent.status == "canceled" ? (MainScreen.english ? "Canceled" : "İptal Edildi") :
                                              rent.status == "finished" ? (MainScreen.english ? "Rental Finished" : "Kiralama Sona Erdi") :
                                              //rent.status == "sent" ? (MainScreen.english ? "Accept" : "Kabul Et") :
                                              DateTime.now().isAfter(rent.enddate) && DateTime.now().isAfter(rent.startdate)
                                                  && rent.status == "accepted" ? (MainScreen.english ? "Finish" : "Kiralamayı Bitir") :
                                              (MainScreen.english ? "Cancel" : "İptal Et"),


                                              style: TextStyle(
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
                            )
                          ],
                        ),
                        loading: () => Center(child: CircularProgressIndicator(),),
                        error: (error, stackTrace) => Container(),

                      ),
                      loading: () => Center(child: CircularProgressIndicator(),),
                    );
                  },
                )
              ],
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

  handleButton(Rent rent, Passenger passenger, Driver driver) async {

    print("here");

    if(DateTime.now().isBefore(rent.enddate) && DateTime.now().isBefore(rent.startdate)
        && rent.status == "accepted") {


      await showDialog(context: context, builder: (context) => AlertDialog(
        title: Text(MainScreen.english ? "Cancel this rental" : "Kiralamayı iptal et",
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: kFontFamily),),
        content: Text(MainScreen.english ? "Are you sure you want to cancel this rental\nThere will be no refund if you cancel 5 hours before the rental" : "Kiralamayı iptal etmek istediğine emin misiniz?\nKiralamadan 5 saat önce iptal ederseniz para iadesi yapılmayacaktır",
          style: TextStyle(fontFamily: kFontFamily),),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(MainScreen.english ? "No" : "Hayır", style: TextStyle(fontFamily: kFontFamily),),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection("rents").doc(rent.uid).update({
                "status" : "canceled",
              });
              if(DateTime.now().difference(rent.startdate).inHours < 5) {
                await FirebaseFirestore.instance.collection("passengers").doc(passenger.uid).update({
                  "money" : passenger.money + rent.amount
                });
              }


              Navigator.pop(context);
            },
            child: Text(MainScreen.english ? "Yes" : "Evet", style: TextStyle(fontFamily: kFontFamily),),
          ),
        ],
      ),);

    }

    else if(rent.status == "sent") {
      await showDialog(context: context, builder: (context) => AlertDialog(
        title: Text(MainScreen.english ? "Cancel this rental" : "Kiralamayı iptal et",
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: kFontFamily),),
        content: Text(MainScreen.english ? "Are you sure you want to cancel this rental" : "Kiralamayı iptal etmek istediğine emin misiniz?",
          style: TextStyle(fontFamily: kFontFamily),),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(MainScreen.english ? "No" : "Hayır", style: TextStyle(fontFamily: kFontFamily),),
          ),
          TextButton(
            onPressed: () async {

              await FirebaseFirestore.instance.collection("rents").doc(rent.uid).update({
                "status" : "canceled",
              });
              await FirebaseFirestore.instance.collection("passengers").doc(passenger.uid).update({
                "money" : passenger.money + rent.amount
              });

              Navigator.pop(context);
            },
            child: Text(MainScreen.english ? "Yes" : "Evet", style: TextStyle(fontFamily: kFontFamily),),
          ),
        ],
      ),);
    }

    else if(DateTime.now().isAfter(rent.enddate) && DateTime.now().isAfter(rent.startdate)
        && rent.status == "accepted" && rent.status != "finished") {

      await showDialog(context: context, builder: (context) => AlertDialog(
        title: Text(MainScreen.english ? "Complete this rental" : "Kiralamayı bitir",
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: kFontFamily),),
        content: Text(MainScreen.english ? "Are you sure you want to complete this rental?" : "Kiralamayı bitirmek istediğine emin misiniz?",
          style: TextStyle(fontFamily: kFontFamily),),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(MainScreen.english ? "No" : "Hayır", style: TextStyle(fontFamily: kFontFamily),),
          ),
          TextButton(
            onPressed: () async {
              print(rent.uid);
              await FirebaseFirestore.instance.collection("rents").doc(rent.uid).update({
                "status" : "finished",
              });
              await FirebaseFirestore.instance.collection("drivers").doc(driver.uid).update({
                "money" : driver.money + rent.amount
              });
              Navigator.pop(context);
            },
            child: Text(MainScreen.english ? "Yes" : "Evet", style: TextStyle(fontFamily: kFontFamily),),
          ),
        ],
      ),);




      /*await FirebaseFirestore.instance.collection("passengers").doc(rent.passenger).collection("rents").doc(rent.uid).update({
        "status" : "finished",
      });*/
    }

  }
}
