import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/passenger/screens/main_screen.dart';

import '../classes/address.dart';
import '../classes/passenger.dart';

class FillOutPage extends StatefulWidget {
  const FillOutPage({Key? key}) : super(key: key);

  @override
  State<FillOutPage> createState() => _FillOutPageState();
}

class _FillOutPageState extends State<FillOutPage> {

  bool male = false;
  bool unspecified = false;
  bool femaleoption = false;

  String _email = "";
  String _name = "";
  String _phone = "";

  final TextEditingController phone = new TextEditingController();
  final TextEditingController email = new TextEditingController();
  final TextEditingController name = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(!MainScreen.english ? "Bilgilerini Gir" : "Complete",
                    style: TextStyle(fontFamily: kFontFamily, fontSize: 20, fontWeight: FontWeight.bold,),),
                  SizedBox(height: height * .05,),
                  _phone == "" ? Container(
                    height: height * .065,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Material(
                        child: TextField(
                          controller: phone,
                          keyboardType: TextInputType.phone,
                          maxLines: 1, maxLength: 13, style: TextStyle(fontFamily: kFontFamily, fontSize: 17.5, color: Colors.white),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10),
                            hintText: "553 987 65 56", hintStyle: TextStyle(fontFamily: kFontFamily, fontSize: 17.5, color: Colors.white),
                            counterText: "",
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                          ),
                        ),
                        color: kLightColors[2],
                      ),
                    ),
                  ) : Container(),
                  SizedBox(height: height * .025,),
                  _email == "" ? Container(
                    height: height * .065,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Material(
                        child: TextField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          maxLines: 1, style: TextStyle(fontFamily: kFontFamily, fontSize: 17.5, color: Colors.white),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            hintText: "Email", hintStyle: TextStyle(fontFamily: kFontFamily, fontSize: 17.5, color: Colors.white),
                            counterText: "",
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                          ),
                        ),
                        color: kLightColors[2],
                      ),
                    ),
                  ) : Container(),
                  SizedBox(height: height * .025,),
                  _name == "" ? Container(
                    height: height * .065,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Material(
                        child: TextField(
                          controller: name,
                          keyboardType: TextInputType.name,
                          maxLines: 1, style: TextStyle(fontFamily: kFontFamily, fontSize: 17.5, color: Colors.white),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10),
                            hintText: !MainScreen.english ? "Ad - Soyad" : "Name - Last name",
                            hintStyle: TextStyle(fontFamily: kFontFamily, fontSize: 17.5, color: Colors.white),
                            counterText: "",
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                          ),
                        ),
                        color: kLightColors[2],
                      ),
                    ),
                  ) : Container(),
                  SizedBox(height: height * .025,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 100, width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: MaterialButton(
                            color: male && !unspecified ? Colors.lightBlue : Colors.grey.shade300,
                            onPressed: () {
                              setState(() {
                                male = true;
                                unspecified = false;
                              });
                            },
                            child: Icon(Icons.male, color: Colors.white, size: 40),
                          ),
                        ),
                      ),
                      Container(
                        height: 100, width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: MaterialButton(
                            color:!male && !unspecified ? Colors.purpleAccent[100] : Colors.grey.shade300,
                            onPressed: () {
                              setState(() {
                                male = false;
                                unspecified = false;
                              });
                            },
                            child: Icon( Icons.female, color: Colors.white, size: 40),
                          ),
                        ),
                      ),
                      Container(
                        height: 100, width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: MaterialButton(
                            color: !unspecified ? Colors.grey.shade300 : Colors.redAccent,
                            onPressed: () {
                              setState(() {
                                unspecified = true;
                              });
                            },
                            child: Icon(Icons.block, color: Colors.white, size: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * .025,),
                  !male && !unspecified ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: height * .1, maxWidth: width * .8),
                        child: Text(!MainScreen.english ? "Sadece kadın sürücülerle iletişime geçmek istiyorum"
                            : "I only want to contact female drivers", style: TextStyle(
                          fontSize: 15, fontFamily: kFontFamily, fontWeight: FontWeight.bold
                        ), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                      Checkbox(
                        value: femaleoption,
                        onChanged: (a) {
                          setState(() {
                            femaleoption = a!;
                          });
                        },
                        activeColor: kDarkColors[4],

                      ),
                    ],
                  ) : Container(),
                ],
              ),
              Container(
                width: width,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: MaterialButton(
                      height: height * .065,
                      color: kLightColors[2],
                      onPressed: () async {
                        if(_email != "" || _name != "") {
                          if(phone.text != "") {
                            await setParametersForNewUser(FirebaseAuth.instance.currentUser!);
                            Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(MainScreen()), (route) => false,);
                          } else {
                            print(name.text + "\n");
                            print(email.text + "\n");
                            print(phone.text + "\n");
                            print(_phone + "\n");
                          }
                        }
                        else if(_phone != "") {
                          if(name.text != "" && email.text != "") {
                            await setParametersForNewUser(FirebaseAuth.instance.currentUser!);
                            Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(MainScreen()), (route) => false,);
                          } else {
                            print(name.text + "\n");
                            print(email.text + "\n");
                            print(phone.text + "\n");
                            print(_phone + "\n");
                          }
                        }
                        else {
                          print(name.text + "\n");
                          print(email.text + "\n");
                          print(_phone + "\n");
                        }
                      },
                      child: Text(!MainScreen.english ? "Tamamla" : "Complete",
                        style: TextStyle(color: Colors.white, fontSize: 17.5, fontFamily: kFontFamily, fontWeight: FontWeight.bold),),
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  getCurrentUserParameters() async {
    try {
      setState(() {
        _email = FirebaseAuth.instance.currentUser!.email!;
        _name = FirebaseAuth.instance.currentUser!.displayName!;
      });
    }

    catch(E) {
      setState(() {
        _phone = FirebaseAuth.instance.currentUser!.phoneNumber!;
      });
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

  sendEmail(String sendEmailTo, String  subject, String emailBody) async {
    await FirebaseFirestore.instance.collection("mail").add({
      "to" : "$sendEmailTo",
      "message" : {
        "subject" : "$subject",
        "text" : "$emailBody"
      }
    }).then((value) {
      print("Queued email for delivery!");
    });
    print("Email done");
  }


  setParametersForNewUser(User user) async {
    Passenger passenger = Passenger(
      money: 0.0,
      gender: male && !unspecified ? "male" : (!unspecified ? "female" : "unspecified"),
      emailapproved: true,
      photo: user.photoURL == null ? "" : user.photoURL.toString(),
      uid: user.uid,
      point: 0.0,
      phone: phone.text != "" ? phone.text : user.phoneNumber.toString(),
      email: email.text == "" ? user.email.toString() : email.text.toString(),
      name: name.text == "" ? user.displayName.toString() : name.text,
      banned: true,
      femaleoption: femaleoption,
      latlng: [0.0, 0.0],
      token: mtoken.toString()
    );

    Address home = Address(
      title: "Ev", latlng : [0.0,0.0], description: "", uid: "home", note: ""
    );

    Address work = Address(
        title: "İş", latlng : [0.0,0.0], description: "", uid: "work", note: ""
    );
    Address school = Address(
        title: "Okul", latlng : [0.0,0.0], description: "", uid: "school", note: ""
    );


    await FirebaseFirestore.instance.collection("passengers").doc(user.uid).set(passenger.toDocument());

    await FirebaseFirestore.instance.collection("passengers").doc(user.uid).collection("addresses").doc("home").set(
      home.toDocument()
    );

    await FirebaseFirestore.instance.collection("passengers").doc(user.uid).collection("addresses").doc("work").set(
      work.toDocument()
    );

    await FirebaseFirestore.instance.collection("passengers").doc(user.uid).collection("addresses").doc("school").set(
      school.toDocument()
    );

    await sendEmail("${email.text}", appName, "$appName'e hoşgeldiniz!");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserParameters();
    getToken();
  }

  String? mtoken = " ";

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
      });
    });
  }
}
