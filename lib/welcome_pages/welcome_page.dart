import 'package:flutter/material.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/welcome_pages/login_register_page.dart';
import 'package:uberclone/welcome_pages/login_register_page.dart' as driver;

import '../utils/authentication.dart';

class WelcomePage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: height * .175),
                  child: Image.asset("images/app/logotext.png", width: width * .75, fit: BoxFit.contain,)),
              Column(
                children: [
                  Text("Sen Götür", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,
                      color: kBottomBarIconsColor, fontFamily: kFontFamily),),

                  SizedBox(height: 10,),

                  Text("Sürücü ya da yolcu olarak giriş yap", style: TextStyle(fontSize: 17.5, color: Colors.grey, fontFamily: kFontFamily),),
                  SizedBox(height: height * .1,),



                ],
              ),

              Column(
                children: [
                  FutureBuilder(
                    future: Authentication.initializeFirebase(context: context),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error initializing Firebase ${snapshot.error}');
                      }
                      else if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          padding: EdgeInsets.all(12),
                          height: height * .115,
                          width: width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: MaterialButton(
                              color: kDarkColors[1],
                              onPressed: () {
                                Navigator.push(context, _routeToSignInScreen(LoginRegisterPage()));
                              },

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Yolcu Olarak Giriş Yap", style: TextStyle(color: Colors.white,
                                      fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.bold),),
                                  Image.asset("images/icons/passenger.png", fit: BoxFit.contain, width: width * .1,)
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
                  FutureBuilder(
                    future: Authentication.initializeFirebase(context: context),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error initializing Firebase ${snapshot.error}');
                      }
                      else if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          padding: EdgeInsets.all(12),
                          height: height * .115,
                          width: width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: MaterialButton(
                              color: kDarkColors[1],
                              onPressed: () {
                                Navigator.push(context, _routeToSignInScreen(driver.LoginRegisterPage()));
                              },

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Sürücü Olarak Giriş Yap", style: TextStyle(color: Colors.white,
                                      fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.bold),),
                                  Image.asset("images/icons/driver.png", fit: BoxFit.contain, width: width * .1, color: Colors.white,)
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
}
