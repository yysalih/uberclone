import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:ebuber/common_pages/wallet_page.dart';
import 'package:ebuber/passenger/screens/main_pages/drive_page.dart';
import 'package:ebuber/passenger/screens/main_pages/home_page.dart';
import 'package:ebuber/passenger/screens/main_pages/more_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant.dart';
import '../../main.dart';
import '../../utils/authentication.dart';
import '../../welcome_pages/fill_out_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../welcome_pages/welcome_page.dart';
import 'main_pages/profile_page.dart';
import 'main_pages/rent_page.dart';
import 'message_pages/chats_page.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  static bool english = false;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    var begin = Offset(0.0, 1.0);
    var end = Offset.zero;
    var curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    Animation animation = CurvedAnimation(parent: ProxyAnimation(), curve: curve);

    List<Widget> pages = [DrivePage(), RentPage(), ChatsPage(), WalletPage(), ProfilePage()];

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final passenger = ref.watch(passengerStreamProvider(FirebaseAuth.instance.currentUser!.uid));

    return passenger.when(
      error: (error, stackTrace) => Container(),
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator(),),),
      data: (passenger) {
        if(!passenger.banned) return Scaffold(
          body: pages[_currentIndex],
          bottomNavigationBar: SalomonBottomBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: [
              /// Home
              /*SalomonBottomBarItem(
            icon: Image.asset("images/icons/home.png", color:  Colors.black,
              fit: BoxFit.contain, width: width * kBottomIconWidth, height: height * kBottomIconHeight,),
            title: Text("Ana Menü", style: TextStyle(
                fontFamily: kFontFamily
            ),),
            selectedColor: kColor1,
          ),*/

              /// Likes
              SalomonBottomBarItem(
                icon: Image.asset("images/icons/car.png", color: _currentIndex == 0 ? kDarkColors[4] : kBlack,
                  fit: BoxFit.contain, width: width * kBottomIconWidth, ),
                title: Text(!MainScreen.english ? "Yolculuk" : "Drive", style: TextStyle(
                    fontFamily: kFontFamily
                ),),
                selectedColor: kDarkColors[9],

              ),

              /// Search

              SalomonBottomBarItem(
                icon: Image.asset("images/icons/carrent.png",
                  color: _currentIndex == 1 ? kDarkColors[4] : kBlack,
                  fit: BoxFit.contain, width: width * kBottomIconWidth, ),
                title: Text(!MainScreen.english ? "Kirala" : "Rent", style: TextStyle(
                    fontFamily: kFontFamily
                ),),
                selectedColor: kDarkColors[9],
              ),

              SalomonBottomBarItem(
                icon: Image.asset("images/icons/email.png", color: _currentIndex == 2 ? kDarkColors[4] : kBlack,
                  fit: BoxFit.contain, width: width * kBottomIconWidth * .9,),//Image.asset("images/icons/user.png", color: Colors.black, fit: BoxFit.contain, width: width * kBottomIconWidth, height: height * kBottomIconHeight,),
                title: Text(!MainScreen.english ? "Mesajlar" : "Chats", style: TextStyle(
                    fontFamily: kFontFamily
                ),),
                selectedColor: kDarkColors[9],
              ),

              SalomonBottomBarItem(
                icon: Image.asset("images/icons/wallet.png",
                  color: _currentIndex == 3 ? kDarkColors[4] : kBlack,
                  fit: BoxFit.contain, width: width * kBottomIconWidth, ),
                title: Text(!MainScreen.english ? "Cüzdan" : "Wallet", style: TextStyle(
                    fontFamily: kFontFamily
                ),),
                selectedColor: kDarkColors[9],
              ),

              /// Profile
              SalomonBottomBarItem(
                icon: Image.asset("images/icons/user.png", color: _currentIndex == 4 ? kDarkColors[4] : kBlack,
                  fit: BoxFit.contain, width: width * kBottomIconWidth * .9,),
                title: Text(!MainScreen.english ? "Profil" : "Profile", style: TextStyle(
                    fontFamily: kFontFamily
                ),),
                selectedColor: kDarkColors[9],
              ),


            ],
          ),
        );
        else return Scaffold(
          body: SafeArea(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, color: Colors.redAccent, size: 60,),
                  SizedBox(height: 20,),
                  Text(MainScreen.english ? "You've been banned!" : "Bu platformdan engellendiniz!", style: TextStyle(
                    fontSize: 20, fontFamily: kFontFamily,
                  ), textAlign: TextAlign.center,),
                  SizedBox(height: 10,),
                  TextButton(
                    child: Text(MainScreen.english ? "Sign out" : "Çıkış yap", style: TextStyle(fontFamily: kFontFamily)),
                    onPressed: () async{

                      SharedPreferences prefs = await SharedPreferences.getInstance();

                      await Authentication.signOut(context: context);


                      prefs.remove("email");
                      prefs.remove("uid");

                      Navigator.of(context).pushAndRemoveUntil(_routeToSignInScreen(WelcomePage()), (route) => false);

                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String mtoken = "";

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token.toString();
      });
    });

    await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid).update({
      "token" : mtoken
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


  checkIfUserExistInFirebase(User user, BuildContext context) async {
    try {

      await FirebaseFirestore.instance.collection("passengers").doc(user.uid).get().then((value) {
        print('Name of The Passenger: ${value["name"]}');
      });
      //Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(MainScreen()), (route) => false);

    }

    catch (E) {
      Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(FillOutPage()), (route) => false);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfUserExistInFirebase(FirebaseAuth.instance.currentUser!, context);
    getToken();
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel channel = AndroidNotificationChannel("","");

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }


  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
          'high_importance_channel', // id
          'High Importance Notifications', // title
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
          showBadge: true
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }


  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }
}
