import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/common_pages/rent_driver_page.dart';
import 'package:ebuber/common_pages/rent_history_page.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/passenger/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import '../../../classes/rent.dart';
import '../../../main.dart';

class RentPage extends ConsumerStatefulWidget {
  const RentPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RentPage> createState() => _RentPageState();
}

class _RentPageState extends ConsumerState<RentPage> {
  String? cityDropDown;
  String? countyDropDown;
  List<String> counties = [];
  List dates = [];

  //DateTime startDate = DateTime.now();
  //DateTime endDate = DateTime.now().add(Duration(days: 1));

  bool searched = false;

  List<DateTime?> _dates = [DateTime.now(), DateTime.now().add(Duration(days: 1))];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final drivers = ref.watch(driversStreamProvider);

    final start = ref.watch(startDatee);
    final end = ref.watch(endDatee);

    final rentPrice = ref.watch(rentDaytreamProvider);


    return Scaffold(
      body: rentPrice.when(
        data: (rentprice) => SafeArea(
          child: searched ?
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 10, right: 10, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(

                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              searched = false;
                            });
                          },
                          child: Icon(Icons.keyboard_backspace, color: Colors.white, size: 20,),

                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(10),
                            primary: kDarkColors[2], // <-- Button color
                            onPrimary: kDarkColors[0], // <-- Splash color
                          ),
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: kLightColors[0],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Center(
                              child: Text(cityDropDown.toString(), style: TextStyle(fontWeight: FontWeight.bold,
                                  color: Colors.white, fontFamily: kFontFamily, fontSize: 12.5),),
                            ),
                          ),
                        ),
                        SizedBox(width: 5,),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: kLightColors[0],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Center(
                              child: Text(countyDropDown.toString(), style: TextStyle(fontWeight: FontWeight.bold,
                                  color: Colors.white, fontFamily: kFontFamily, fontSize: 12.5),),
                            ),
                          ),
                        ),

                      ],
                    ),

                    SizedBox(height: 10,),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: kLightColors[0],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month, size: 20, color: Colors.white,),
                              SizedBox(width: 5,),
                              Text("${_dates[0]!.day} ${months[_dates[0]!.month - 1]} - ${_dates[1]!.day} ${months[_dates[1]!.month - 1]}",
                                style: TextStyle(fontWeight: FontWeight.bold,
                                    color: Colors.white, fontFamily: kFontFamily, fontSize: 12.5),),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * .025,),
                    Text(MainScreen.english ? "Available drivers between these dates:" : "Bu tarihler arasında uygun sürücüler:",
                      style: TextStyle(fontSize: 17.5, fontFamily: kFontFamily, fontWeight: FontWeight.bold),),

                  ],
                ),
              ),
              drivers.when(
                loading: () => Center(child: CircularProgressIndicator(),),
                data: (drivers) {
                  return ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: height * .625, maxWidth: width),
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return FutureBuilder<bool>(
                            future: checkForOverlap(drivers[index].uid, _dates[0]!, _dates[1]!),
                            builder: (context, snapshot) {

                              try {

                                if(!snapshot.hasData) return Center(child: CircularProgressIndicator(),);
                                if(snapshot.data == true) {
                                  print("here1");
                                  return Container();
                                }
                                else if(snapshot.data == false) {
                                  print("here2");
                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundImage: CachedNetworkImageProvider(drivers[index].photo),
                                                    backgroundColor: kColor1,
                                                    radius: 25,
                                                  ),
                                                  SizedBox(width: 10,),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(drivers[index].name, style: TextStyle(
                                                          fontWeight: FontWeight.bold, fontFamily: kFontFamily, fontSize: 15
                                                      ),),
                                                      Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              for(int i = 0; i < drivers[index].point.toInt(); i++)
                                                                Icon(Icons.star, color: Colors.orangeAccent, size: 15,)
                                                            ],
                                                          ),
                                                          SizedBox(width: 5,),
                                                          Text("${drivers[index].point.toStringAsFixed(1)} - ", style: TextStyle(
                                                              fontFamily: kFontFamily, fontSize: 12.5
                                                          ),),

                                                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                                            stream: FirebaseFirestore.instance.collection("drivers").doc(drivers[index].uid)
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
                                                  Navigator.push(context, _routeToSignInScreen(RentDriverPage(rent: Rent(
                                                      amount: (_dates[1]!.difference(_dates[0]!).inDays * rentprice).toDouble(),
                                                      status: "sent", enddate: _dates[1]!, startdate: _dates[0]!, uid: "${FirebaseAuth.instance.currentUser!.uid}_${drivers[index].uid}_$start",
                                                      city: cityDropDown.toString(), county: countyDropDown.toString(), driver: drivers[index].uid,
                                                      passenger: FirebaseAuth.instance.currentUser!.uid
                                                  ),)));
                                                },
                                                child: Image.asset("images/icons/car.png", width: 20, color: Colors.white,),

                                                style: ElevatedButton.styleFrom(
                                                  shape: CircleBorder(),
                                                  padding: EdgeInsets.all(10),
                                                  primary: kLightColors[2], // <-- Button color
                                                  onPrimary: kLightColors[0], // <-- Splash color
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Container(
                                          width: width * .9, height: .75,
                                          color: Colors.blueGrey.shade100,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                else return Container();
                              }
                              catch(E) {
                                print(E);
                                return Container();
                              }
                            },
                          );
                        },
                        itemCount: drivers.length,
                      )
                  );
                },
                error: (error, stackTrace) {
                  print(error);
                  print(stackTrace);
                  return Container();
                },
              ),
            ],
          )
              : Container(
            padding: EdgeInsets.all(10),
            child:  Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(MainScreen.english ? "Rent a Driver" : "Sürücü Kirala", style: TextStyle(
                      fontSize: 25, fontFamily: kFontFamily, fontWeight: FontWeight.bold,
                    ),),

                    InkWell(
                      onTap: () => Navigator.push(context, _routeToSignInScreen(RentHistoryPage())),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300,
                                spreadRadius: 1,
                                blurRadius: 1
                            )
                          ],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset("images/icons/repeat.png", width: 25, color: Colors.black,),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: height * 0.06,
                      width: width * .45,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: kLightColors[0],

                      ),
                      child: DropdownButton<String>(
                        hint: Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Text('İl', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,
                              fontFamily: kFontFamily, fontSize: 15),),
                        ),
                        value: cityDropDown,
                        isExpanded: true,
                        elevation: 16,
                        onChanged: (String? newValue) {
                          setState(() {
                            cityDropDown = newValue!;
                            counties.clear();
                            for(var a in (item0.where((element) => element["il_adi"] == cityDropDown).first["ilceler"] as List)) {
                              counties.add(a["ilce_adi"]);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        dropdownColor: kLightColors[3],
                        underline: Container(),
                        items: items3.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(

                            value: value,
                            child: Container(
                              padding: EdgeInsets.only(left: 20),

                              child: Text(value, style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,
                                  fontFamily: kFontFamily, fontSize: 15),),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Container(
                      height: height * 0.06,
                      width: width * .45,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: kLightColors[0],

                      ),
                      child: DropdownButton<String>(
                        hint: Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Text('İlçe', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,
                              fontFamily: kFontFamily, fontSize: 15),),
                        ),
                        value: countyDropDown,
                        isExpanded: true,
                        elevation: 16,
                        onChanged: (String? newValue) async {
                          setState(() {
                            countyDropDown = newValue!;
                          });

                        },
                        borderRadius: BorderRadius.circular(10),
                        dropdownColor: kLightColors[6],
                        underline: Container(),
                        items: counties.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(

                            value: value,
                            child: Container(
                              padding: EdgeInsets.only(left: 20),

                              child: Text(value, style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,
                                  fontFamily: kFontFamily, fontSize: 15),),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer_outlined,),
                        SizedBox(width: 5,),
                        Text(MainScreen.english ? "Choose a range" : "Tarih Aralığı Belirle", style: TextStyle(
                            fontWeight: FontWeight.bold, fontFamily: kFontFamily, fontSize: 20
                        ),),

                      ],
                    ),
                    SizedBox(height: 10,),
                    CalendarDatePicker2(
                      config: CalendarDatePicker2Config(

                        calendarType: CalendarDatePicker2Type.range,
                      ),

                      value: _dates,
                      onValueChanged: (dates) => _dates = dates,
                    )
                  ],
                ),
                Container(
                  width: width, height: 45,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: MaterialButton(
                      onPressed: () {
                        if((cityDropDown != null && cityDropDown != "")
                            && (countyDropDown != null && countyDropDown != "")) {
                          setState(() {
                            searched = true;
                          });
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(MainScreen.english ? "You have to choose city-region!" : "Şehir ve ilçe seçilmedi.", style: TextStyle(
                                fontSize: 15, fontFamily: kFontFamily, color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),),
                            backgroundColor: Colors.redAccent,
                          ));
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(MainScreen.english ? "Search For Drivers" : "Sürücüleri Ara", style: TextStyle(
                                fontSize: 15, fontFamily: kFontFamily, fontWeight: FontWeight.bold, color: Colors.white
                            ),),
                            Icon(Icons.search, color: Colors.white, size: 22.5,)
                          ],
                        ),
                      ),
                      color: kLightColors[0],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        loading: () => Center(child: CircularProgressIndicator(),),
        error: (error, stackTrace) => Container(),
      )
    );
  }

  onDateChanged(List<DateTime?> dates) {
    setState(() {
      _dates = dates;
    });
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

  bool isOverlapping = false;

// Assuming you've initialized Firebase and have a Firestore instance
  final firestoreInstance = FirebaseFirestore.instance;

  Future<bool> checkForOverlap(String driverID, DateTime x_dateTime, DateTime y_dateTime) async {
    // Query rents whose start_date falls between x_dateTime and y_dateTime
    try {
      Query rents1 = firestoreInstance.collection('rents')
          .where("driver_uid", isEqualTo: driverID).where("status", isEqualTo: "accepted")
          .where('startdate', isGreaterThanOrEqualTo: x_dateTime).where('startdate', isLessThanOrEqualTo: y_dateTime);

      // Query rents whose end_date falls between x_dateTime and y_dateTime
      Query rents2 = firestoreInstance
          .collection('rents').where("driver_uid", isEqualTo: driverID).where("status", isEqualTo: "accepted")
          .where('enddate', isGreaterThanOrEqualTo: x_dateTime).where('enddate', isLessThanOrEqualTo: y_dateTime);

      // Execute the queries
      QuerySnapshot rents1Result = await rents1.get();
      QuerySnapshot rents2Result = await rents2.get();

      // If there are any documents returned by either query, then there's an overlap
      if (rents1Result.docs.isNotEmpty || rents2Result.docs.isNotEmpty) {
        isOverlapping = true;
        print('The range overlaps with some rent periods.');

        return true;
      } else {
        print('The range does not overlap with any rent periods.');
        return false;
      }
    }
    catch(E) {
      print(E);

      return false;
    }
  }
}

final startDatee = StateProvider<DateTime>((ref) {
  return DateTime.now(); // declared elsewhere
});

final endDatee = StateProvider<DateTime>((ref) {
  return DateTime.now().add(Duration(days: 1)); // declared elsewhere
});
