import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/utils/authentication.dart';
import 'package:ebuber/welcome_pages/fill_out_page.dart';
import 'package:flutter/services.dart';

import '../passenger/screens/main_screen.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({Key? key}) : super(key: key);

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {

  String phone = "";

  TextEditingController phoneController = TextEditingController();

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

              Column(
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
                      Text(!MainScreen.english ? "Telefon Numarası İle Giriş Yap" : "Log in with your phone number",
                        style: TextStyle(color: kBottomBarIconsColor, fontSize: 15,
                            fontFamily: kFontFamily, fontWeight: FontWeight.bold),),
                    ],
                  ),
                  SizedBox(height: height * .05,),
                  TextField(
                    keyboardType: TextInputType.phone,
                    maxLines: 1, maxLength: 13, style: TextStyle(fontFamily: kFontFamily, fontSize: 20),
                    controller: phoneController,
                    onChanged: (a) {
                      setState(() {
                        phoneNumber = a;
                      });
                    },
                    decoration: InputDecoration(
                      prefixIconConstraints: BoxConstraints(maxHeight: 20,maxWidth: 30),
                      prefixIcon: Container(alignment: Alignment.centerLeft,
                          child: Text("+90", style: TextStyle(fontFamily: kFontFamily))),
                        hintText: "5539876556", hintStyle: TextStyle(fontFamily: kFontFamily, fontSize: 20),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                        counterText: ""
                    ),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
//
              Container(),

              Container(
                height: height * .075, width: width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MaterialButton(
                    onPressed: () {
                      if(phoneNumber != null && phoneNumber.toString().startsWith("5")) verifyPhoneNumber(context);
                      else if(!phoneNumber.toString().startsWith("5")) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(MainScreen.english ? "Your number should start with 5" :
                            "Numaranız için ülke kodu girmenize gerek yok", style: TextStyle(fontFamily: kFontFamily,
                                fontWeight: FontWeight.bold, color: Colors.white),),
                          backgroundColor: Colors.redAccent,
                          )
                        );
                      }

                    },
                    color: kDarkColors[0],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Devam et", style: TextStyle(color: Colors.white,fontSize: 20,
                            fontFamily: kFontFamily, fontWeight: FontWeight.bold),),
                        Image.asset("images/app/logo2.png", fit: BoxFit.contain, width: width * .075, color: Colors.white,)
                      ],
                    ),
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

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  String? phoneNumber, verificationId;
  String otp = "", authStatus = "";


  Future<void> verifyPhoneNumber(BuildContext context) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 15),
      verificationCompleted: (AuthCredential authCredential) {
        setState(() {
          authStatus = "Your account is successfully verified";
        });
      },
      verificationFailed: (error) {
        setState(() {
          authStatus = "Authentication failed";
        });
      },
      codeSent: (String verId, int? forceCodeResent) {
        verificationId = verId;
        setState(() {
          authStatus = "OTP has been successfully send";
        });
        otpDialogBox(context).then((value) {});
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
        setState(() {
          authStatus = "TIMEOUT";
        });
      },
    );
  }
  Future<void> signIn(String otp) async {
    await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: otp,
    ));
    Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(FillOutPage()), (route) => false);
  }

  otpDialogBox(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text(!MainScreen.english ? "6 haneli kodu giriniz" : 'Enter your OTP'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(30),
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    otp = value;
                  });
                },
              ),
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  signIn(otp);
                },
                child: Text(
                  !MainScreen.english ? "Devam et" : 'Submit',
                ),
              ),
            ],
          );
        });
  }
}
