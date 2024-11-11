import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/passenger/screens/main_screen.dart';
import 'package:ebuber/welcome_pages/fill_out_page.dart';
import 'package:ebuber/welcome_pages/phone_login_page.dart';
import 'package:ebuber/welcome_pages/sms_pin_page.dart';

import '../utils/authentication.dart';

class LoginRegisterPage extends StatefulWidget {

  final bool driver;

  LoginRegisterPage({this.driver = false});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool _isSigningIn = false;

  String phone = "";

  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              Image.asset("images/app/logotext.png", width: width * .75, fit: BoxFit.cover,),
              Column(
                children: [
                  //Image.asset("images/app/4.png", width: width * .85, fit: BoxFit.contain, color: kDarkColors[1],),
                  SizedBox(height: 40,),
                  Column(
                    children: [
                      FutureBuilder(
                        future: Authentication.initializeFirebase(context: context),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error initializing Firebase ${snapshot.error}');
                          } else if (snapshot.connectionState == ConnectionState.done) {
                            return Container(
                              height: height * .1, width: width,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: MaterialButton(
                                  onPressed: () async {

                                    Navigator.push(context, _routeToSignInScreen(PhoneLoginPage()));

                                  },
                                  color: kDarkColors[9],
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(!MainScreen.english ? "Telefon Numarası İle Devam Et"
                                        : "Log In With Your Phone Number", style: TextStyle(
                                        color: Colors.white,fontSize: 20,
                                        fontFamily: kFontFamily, fontWeight: FontWeight.bold),),
                                  ),
                                ),
                              ),
                            );
                          }
                          return CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.orangeAccent
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 15,),
                      FutureBuilder(
                        future: Authentication.initializeFirebase(context: context),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error initializing Firebase ${snapshot.error}');
                          }
                          else if (snapshot.connectionState == ConnectionState.done) {
                            return Container(
                              height: height * .1, width: width,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: MaterialButton(
                                  onPressed: () async {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();

                                    // setState(() {
                                    //   _isSigningIn = true;
                                    // });

                                    User? user = await Authentication.signInWithGoogle(context: context);


                                    // setState(() {
                                    //   _isSigningIn = false;
                                    // });

                                    if (user != null) {
                                      await prefs.setString("email", user.email!);
                                      await prefs.setString("uid", user.uid);
                                      await prefs.setString("app", "passenger");

                                      await checkIfUserExistInFirebase(user);

                                    }
                                  },
                                  color: kDarkColors[9],
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(!MainScreen.english ? "Google ile Devam et" :
                                        "Log in with Google",
                                        style: TextStyle(color: Colors.white,fontSize: 20,
                                          fontFamily: kFontFamily, fontWeight: FontWeight.bold),),
                                      Image.asset("images/icons/google.png", fit: BoxFit.contain, width: width * .1,)
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          return CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.orangeAccent
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 50, width: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: MaterialButton(
                        onPressed: () {
                          setState(() {
                            MainScreen.english = false;
                          });
                        },
                        child: Text("TR", style: TextStyle(fontFamily: kFontFamily, fontSize: 12.5,
                        fontWeight: FontWeight.bold, color: Colors.white)),
                        color: kDarkColors[0],
                      ),
                    ),
                  ),
                  SizedBox(width: 20,),
                  Container(
                    height: 50, width: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: MaterialButton(
                        onPressed: () {
                          setState(() {
                            MainScreen.english = true;
                          });
                        },
                        child: Text("EN", style: TextStyle(fontFamily: kFontFamily, fontSize: 12.5,
                        fontWeight: FontWeight.bold, color: Colors.white)),
                        color: kDarkColors[0],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          /*Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text("Telefon Numarası İle Giriş Yap", style: TextStyle(color: kBottomBarIconsColor, fontSize: 30,
                      fontFamily: kFontFamily, fontWeight: FontWeight.bold),),
                  SizedBox(height: height * .05,),
                  TextField(
                    keyboardType: TextInputType.phone,
                    maxLines: 1, maxLength: 13, style: TextStyle(fontFamily: kFontFamily, fontSize: 20),
                    controller: phoneController,
                    onChanged: (a) {
                      setState(() {
                        phone = a;
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        padding: EdgeInsets.only(top: 12, left: 10),
                        child: Text("+90 ", style: TextStyle(fontFamily: kFontFamily, fontSize: 20),),
                      ),
                      hintText: "553 987 65 56", hintStyle: TextStyle(fontFamily: kFontFamily, fontSize: 20),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                      counterText: ""
                    ),
                  ),
                  SizedBox(height: height * .035,),

                  /*FutureBuilder(
                    future: Authentication.initializeFirebase(context: context),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error initializing Firebase ${snapshot.error}');
                      } else if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          height: height * .075, width: width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: MaterialButton(
                              onPressed: () async {
                                if(phone != "")
                                  Navigator.push(context, _routeToSignInScreen(SMSPinPage(phone: phone,)));

                              },
                              color: kBottomBarIconsColor,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Devam et", style: TextStyle(color: Colors.white,fontSize: 25,
                                      fontFamily: kFontFamily, fontWeight: FontWeight.bold),),
                                  Image.asset("images/icons/racing.png", fit: BoxFit.contain, width: width * .1, color: Colors.white,)
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orangeAccent
                        ),
                      );
                    },
                  ),*/
                  SizedBox(height: height * .05,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        color: Colors.grey,
                        width: width * .375,
                        height: 2,
                      ),
                      Text("ve ya", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontFamily: kFontFamily, fontSize: 20),),
                      Container(
                        color: Colors.grey,
                        width: width * .375,
                        height: 2,
                      ),
                    ],
                  ),

                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset("images/ills/car2.png", width: width * .5, fit: BoxFit.contain,),
                  Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Ana Menüye Dön", style: TextStyle(fontFamily: kFontFamily, color: Colors.black)),
                      ),
                      SizedBox(height: 10,),
                      FutureBuilder(
                        future: Authentication.initializeFirebase(context: context),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error initializing Firebase ${snapshot.error}');
                          } else if (snapshot.connectionState == ConnectionState.done) {
                            return Container(
                              height: height * .075, width: width,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: MaterialButton(
                                  onPressed: () async {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();

                                    setState(() {
                                      _isSigningIn = true;
                                    });

                                    User? user = await Authentication.signInWithGoogle(context: context);


                                    setState(() {
                                      _isSigningIn = false;
                                    });

                                    if (user != null) {
                                      await prefs.setString("email", user.email!);
                                      await prefs.setString("uid", user.uid);

                                      await checkIfUserExistInFirebase(user);

                                    }
                                  },
                                  color: kBottomBarIconsColor,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Google ile Devam et", style: TextStyle(color: Colors.white,fontSize: 25,
                                          fontFamily: kFontFamily, fontWeight: FontWeight.bold),),
                                      Image.asset("images/icons/google.png", fit: BoxFit.contain, width: width * .1,)
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          return CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.orangeAccent
                            ),
                          );
                        },
                      ),

                    ],
                  ),
                ],
              )
            ],
          ),*/
        ),
      ),
    );
  }

  Route _routeToSignInScreen(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
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

  checkIfUserExistInFirebase(User user) async {
    try {

      await FirebaseFirestore.instance.collection("passengers").doc(user.uid).get().then((value) {
        print('Name of The Passenger: ${value["name"]}');
      });
      Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(MainScreen()), (route) => false);

    }

    catch (E) {
      Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(FillOutPage()), (route) => false);

      /*await FirebaseFirestore.instance.collection("passengers").doc(user.uid).set({
        "name" : user.displayName,
        "phone" : user.phoneNumber,
        "email" : user.email,
        "uid" : user.uid,
        "photo" : user.photoURL,
        "point" : 0.0,
        "latlng" : [0.0, 0.0],

      });*/

      print("Succesfully registered");
    }
  }


}
