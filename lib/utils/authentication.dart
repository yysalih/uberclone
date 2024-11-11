import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ebuber/welcome_pages/fill_out_page.dart';
import 'package:uberclone/passenger/screens/main_screen.dart' as driverMainScreen;

import '../passenger/screens/main_screen.dart';

class Authentication {
  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;


    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential = await auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content:
              'The account already exists with a different credential',
            ),
          );
        }
        else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content:
              'Error occurred while accessing credentials. Try again.',
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          Authentication.customSnackBar(
            content: 'Error occurred using Google Sign In. Try again.',
          ),
        );
      }
    }

    return user;
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static Future<void> signOut({required BuildContext context}) async {


    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();




    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }

  static Future<FirebaseApp> initializeFirebase({required BuildContext context,}) async {

    FirebaseApp firebaseApp = await Firebase.initializeApp();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {

      if(prefs.getString("app") == "passenger") {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainScreen(),), (route) => false);
      }
      else {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => driverMainScreen.MainScreen(),), (route) => false);
      }

      /*try {
        await FirebaseFirestore.instance.collection("passengers").doc(user.uid).get().then((value) {
          print('Name of The Passenger: ${value["name"]}');
        });
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainScreen(),), (route) => false);
      }
      
      catch(E) {
        print("No such user as ${user.uid}");
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => FillOutPage(),), (route) => false);
      }*/
    }

    return firebaseApp;



  }

  static Future<SharedPreferences> initializeEmail({required BuildContext context,}) async {


    try {
      User? user = FirebaseAuth.instance.currentUser;

      SharedPreferences prefs = await SharedPreferences.getInstance();

      if(prefs.containsKey("email") == true) {

        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainScreen(),), (route) => false);

      }
      return prefs;

    }

    catch (E) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => FillOutPage(),), (route) => false);

      return prefs;

    }


  }

  checkIfUserExistInFirebase(User user, BuildContext context) async {
    try {

      await FirebaseFirestore.instance.collection("passengers").doc(user.uid).get().then((value) {
        print('Name of The Passenger: ${value["name"]}');
      });
      Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(MainScreen()), (route) => false);

    }

    catch (E) {
      Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(FillOutPage()), (route) => false);
    }
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
}