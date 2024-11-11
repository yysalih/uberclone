import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/welcome_pages/login_register_page.dart';
import 'package:ebuber/welcome_pages/welcome_page.dart';
import '../../../utils/authentication.dart';
import '../main_screen.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool sms = true;
  bool _isSigningOut = false;
  bool email = true;

  bool femaleoption = false;
  String gender = "unspecified";

  bool english = false;
  bool turkish = true;

  Map<String, dynamic> currentUser = {};

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(

      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      Text(!MainScreen.english ? "Ayarlar" : "Settings", style: TextStyle(
                          fontSize: 17.5, fontFamily: kFontFamily, color: kDarkColors[8], fontWeight: FontWeight.bold
                      ),),
                    ],
                  ),
                  /*Text(!MainScreen.english ? "Kampanyalar" : "Campaign Settings",
                    style: TextStyle(fontFamily: kFontFamily, fontSize: 15, color: Colors.grey),),
                  SizedBox(height: 5,),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: height * .1, maxWidth: width * .75),
                            child: Text(!MainScreen.english ? "Kampanya bildirimlerini SMS olarak almak istiyorum"
                                : "I want to get notification by SMS",
                                style: TextStyle(fontFamily: kFontFamily),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),

                          Checkbox(
                            value: sms,
                            onChanged: (a) {
                              setState(() {
                                sms = a!;
                              });
                            },
                          ),

                        ],
                      ),
                      SizedBox(height: 5,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: height * .1, maxWidth: width * .75),
                            child: Text(!MainScreen.english ? "Kampanya bildirimlerini Email olarak almak istiyorum"
                                    : "I want to get notification by Email" , style: TextStyle(fontFamily: kFontFamily),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),

                          Checkbox(
                            value: email,
                            onChanged: (a) {
                              setState(() {
                                email = a!;
                              });
                            },
                          ),

                        ],
                      ),
                      SizedBox(height: 5,),

                    ],
                  ),*/
                  SizedBox(height: 20,),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(!MainScreen.english ? "Diller" : "Languages",
                        style: TextStyle(fontFamily: kFontFamily, fontSize: 15, color: Colors.grey),),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: height * .1, maxWidth: width * .75),
                            child: Text("Türkçe", style: TextStyle(fontFamily: kFontFamily),
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),

                          Checkbox(
                            value: turkish,
                            onChanged: (a) async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              setState(() {
                                turkish = a!;
                                english = !a;

                                MainScreen.english = english;
                              });

                              prefs.setBool("turkish", turkish);
                              print(prefs.getBool("turkish").toString());


                            },
                          ),

                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: height * .1, maxWidth: width * .75),
                            child: Text("English", style: TextStyle(fontFamily: kFontFamily),
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),

                          Checkbox(
                            value: english,
                            onChanged: (a) async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();

                              setState(() {
                                english = a!;
                                turkish = !a;
                                MainScreen.english = english;
                              });
                              prefs.setBool("turkish", turkish);

                              print(prefs.getBool("turkish").toString());
                            },
                          ),

                        ],
                      ),
                    ],
                  ),
                  gender == "female" ?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 0,),
                      Text(!MainScreen.english ? "Tercihler" : "Preferences",
                        style: TextStyle(fontFamily: kFontFamily, fontSize: 15, color: Colors.grey),),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: height * .1, maxWidth: width * .75),
                            child: Text(!MainScreen.english ? "Sadece kadın sürücülerle iletişime geçmek istiyorum"
                                : "I only want to contact female drivers", style: TextStyle(fontFamily: kFontFamily),
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),

                          Checkbox(
                            value: femaleoption,
                            onChanged: (a) {
                              setState(() {
                                femaleoption = a!;
                              });
                            },
                          ),

                        ],
                      ),
                    ],
                  ) : Container(),
                ],
              ),
              Container(
                width: width,
                height: height * .06,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MaterialButton(
                    color: Colors.redAccent,
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();

                      setState(() {
                        _isSigningOut = true;
                      });
                      await Authentication.signOut(context: context);
                      setState(() {
                        _isSigningOut = false;
                      });


                      prefs.remove("email");
                      prefs.remove("uid");

                      Navigator.of(context).pushAndRemoveUntil(_routeToSignInScreen(LoginRegisterPage()), (route) => false);
                    },
                    child: Text(!MainScreen.english ? "Çıkış Yap" : "Sign Out",
                        style: TextStyle(color: Colors.white, fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
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
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }


  getCurrentUser() async {
    await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
      setState(() {
        currentUser = value.data()!;
        gender = value["gender"];
        femaleoption = value["femaleoption"];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    getLanguage();
  }

  getLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      turkish = prefs.getBool("turkish")!;
      english = !prefs.getBool("turkish")!;
    });
  }
}
