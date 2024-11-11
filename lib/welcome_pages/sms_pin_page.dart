
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ebuber/constant.dart';
import 'fill_out_page.dart';

class SMSPinPage extends StatefulWidget {
  SMSPinPage({Key? key, required this.phone}) : super(key: key);

  final String phone;

  @override
  State<SMSPinPage> createState() => _SMSPinPageState();
}

class _SMSPinPageState extends State<SMSPinPage> {
  TextEditingController pinController = TextEditingController();

  String verificationCode = "";
  bool _isSigningIn = false;

  //GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  //FocusNode pinPutFocus = FocusNode();

  String pin = "";

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
            children: [
              Text("Lütfen ${widget.phone} numaralı telefonunuza gönderilen 4 haneli kodu giriniz",
              style: TextStyle(color: kBottomBarIconsColor, fontFamily: kFontFamily,fontSize: 30, fontWeight: FontWeight.w500),),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Pinput(
                    length: 6, controller: pinController,
                    onCompleted: (pin) async{
                      setState(() {
                        pin = pin.toString();
                      });
                      await signInWithPhone(pin, context);
                    },

                  ),
                  SizedBox(height: 5,),
                  Container(

                    child: TextButton(
                      onPressed: () {

                      },
                      child: Text("Kod gelmedi mi?", style: TextStyle(fontSize: 12.5, fontFamily: kFontFamily)),
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Geri Dön", style: TextStyle(fontFamily: kFontFamily, color: Colors.black, fontSize: 20)),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    height: height * .075, width: width,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: MaterialButton(
                        onPressed: () async {
                          await signInWithPhone(pin, context);
                        },
                        color: kDarkColors[0],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Devam et", style: TextStyle(color: Colors.white,fontSize: 25,
                                fontFamily: kFontFamily, fontWeight: FontWeight.bold),),
                            Image.asset("images/app/logo2.png", fit: BoxFit.contain, width: width * .125,
                              color: Colors.white,)
                          ],
                        ),
                      ),
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

  Future<void> signInWithPhone(String pin, BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(
          smsCode: pin, verificationId: verificationCode
      )).then((value) async {
        if(value.user != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();


          await prefs.setString("email", value.user!.email!);
          await prefs.setString("uid", value.user!.uid);

          //await checkIfUserExistInFirebase(value.user!);

        } else print("Something's wrong");
      });
    }

    catch(E) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid OTP", style: TextStyle(
        fontWeight: FontWeight.bold, fontFamily: kFontFamily, fontSize: 17, color: Colors.white
      ),), backgroundColor: kDarkColors[6],));
    }
  }

  checkIfUserExistInFirebase(User user) async {
    //Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(FillOutPage()), (route) => false);

    /*try {

      await FirebaseFirestore.instance.collection("passengers").doc(user.uid).get().then((value) {
        print('Name of The Passenger: ${value["name"]}');
      });
      Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(FillOutPage()), (route) => false);

    }

    catch (E) {
      Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(FillOutPage()), (route) => false);

      *//*await FirebaseFirestore.instance.collection("passengers").doc(user.uid).set({
        "name" : user.displayName,
        "phone" : user.phoneNumber,
        "email" : user.email,
        "uid" : user.uid,
        "photo" : user.photoURL,
        "point" : 0.0,
        "latlng" : [0.0, 0.0],

      });*//*

      print("Succesfully registered");
    }*/
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

  verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+90${widget.phone}",
        codeSent: (verificationId, resendToken) {
          setState(() {
            verificationCode = verificationId;
          });
        },

        verificationFailed: (FirebaseAuthException error) {
          print("Hata: $error");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            verificationCode = verificationId;
          });
        },
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential).then((value) async {
            if(value.user != null) {
              print("user logged in");
            }
          });
        },
        timeout: Duration(seconds: 60)
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    verifyPhone();
  }



}
