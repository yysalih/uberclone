import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/main.dart';
import 'package:ebuber/welcome_pages/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/address_page.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/contact_us_page.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/edit_profile_page.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/faq_page.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/recent_drives_page.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/settings_page.dart';
import 'package:ebuber/passenger/screens/message_pages/chats_page.dart';

import '../../../utils/authentication.dart';
import '../../../welcome_pages/login_register_page.dart';
import '../main_screen.dart';
import 'more_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    final currentuser = ref.watch(passengerStreamProvider(FirebaseAuth.instance.currentUser!.uid));
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              currentuser.when(
                error: (error, stackTrace) {
                  print("An error: $error\n$stackTrace");
                  return Container();
                },
                loading: () => Center(child: CircularProgressIndicator(),),
                data: (currentuser) => Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: CircleAvatar(
                        backgroundColor: kColor1, radius: height * .08,
                        backgroundImage: CachedNetworkImageProvider(currentuser.photo),
                        //child: Icon(Icons.edit, color: Colors.white, size: height * .025,),
                      ),
                      onTap: () => Navigator.push(context, _routeToSignInScreen(EditProfilePage())),
                    ),
                    SizedBox(height: 10,),
                    Text(currentuser.name, style: TextStyle(
                        color: Colors.black, fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.bold
                    ),),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.orangeAccent, size: height * 0.03,),
                        SizedBox(width: 5,),
                        Text("${currentuser.point}", style: TextStyle(fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.bold),),
                      ],
                    )
                  ],
                ),
              ),
              //SizedBox(height: height * .05,),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ProfilePageItem(width: width, height: height, color: kColor1,
                      title: !MainScreen.english ? "Geçmiş Yolculuklarım" : "Recent Drives", icon: "distance"),
                  SizedBox(height: 10,),
                  ProfilePageItem(width: width, height: height, color: kColor1,
                      title: !MainScreen.english ? "Adreslerim" : "Addresses", icon: "heart"),
                  SizedBox(height: 10,),
                  ProfilePageItem(width: width, height: height, color: kColor1,
                    title: !MainScreen.english ? "Daha Fazla" : "More", icon: "info",),

                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Container(
                width: width * .75,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), color: Colors.redAccent.withOpacity(.9)),
                child: ClipRRect(
                  child: MaterialButton(
                    height: 50,
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

                        Navigator.of(context).pushAndRemoveUntil(_routeToSignInScreen(WelcomePage()), (route) => false);
                      },
                    child: Text(!MainScreen.english ? "Çıkış Yap" : "Log Out", style: TextStyle(fontFamily: kFontFamily, fontSize: 17.5,
                        color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start, maxLines: 1,)
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
                Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), gradient: LinearGradient(
                    colors: [kLightColors[0], kDarkColors[4]], begin: Alignment.topLeft, end: Alignment.bottomRight
                )
                ),
                child: ClipRRect(
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.push(context, _routeToSignInScreen(SettingsPage()));
                    },
                    child: Icon(Icons.settings, color: Colors.white, size: 20),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
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
        var begin = Offset(0.0, 1.0);
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

class ProfilePageItem2 extends StatelessWidget {
  const ProfilePageItem2({
    Key? key,
    required this.height,
    required this.width, required this.color, required this.icon, required this.title,
  }) : super(key: key);

  final double height;
  final double width;
  final Color color;
  final String icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: MaterialButton(
        height: height * .1,
        onPressed: () {
          if(title == "Bize Ulaşın") Navigator.push(context, _routeToSignInScreen(ContactUsScreen()));
          else if(title == "Sıkça Sorulan Sorular") Navigator.push(context, _routeToSignInScreen(FAQPage()));
          else if(title == "Bize Ulaşın") Navigator.push(context, _routeToSignInScreen(ContactUsScreen()));
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 25, backgroundColor: color, child: Image.asset("images/icons/$icon.png",
              width: width * .075, fit: BoxFit.contain, color: Colors.white),
            ),
            SizedBox(width: 20,),
            Text("$title", style: TextStyle(fontSize: 20, fontFamily: kFontFamily, color: kBottomBarIconsColor),)
          ],
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

class ProfilePageItem extends StatelessWidget {
  const ProfilePageItem({
    Key? key,
    required this.width,
    required this.height, required this.color, required this.icon, required this.title,
  }) : super(key: key);

  final double width;
  final double height;
  final Color color;
  final String icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), gradient: LinearGradient(
          colors: [kLightColors[0], kDarkColors[4]], begin: Alignment.topLeft, end: Alignment.bottomRight
        )
      ),
      child: ClipRRect(
        child: MaterialButton(
          height: height * .08,
          onPressed: () {
            if(icon == "distance") Navigator.push(context, _routeToSignInScreen(RecentDrivesPage()));
            else if(icon == "heart") Navigator.push(context, _routeToSignInScreen(AddressPage()));
            else if(icon == "setting") Navigator.push(context, _routeToSignInScreen(SettingsPage()));
            else if(icon == "email") Navigator.push(context, _routeToSignInScreen(ChatsPage()));
            else if(icon == "info") Navigator.push(context, _routeToSignInScreen(MorePage()));
          },
          child: Row(
            children: [
              Image.asset("images/icons/$icon.png", width: width * .05, fit: BoxFit.contain,color: Colors.white),
              SizedBox(width: 15,),
              Text("$title", style: TextStyle(fontFamily: kFontFamily, fontSize: 15,
                color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.start, maxLines: 1,)
            ],
          ),
        ),
        borderRadius: BorderRadius.circular(10),
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
