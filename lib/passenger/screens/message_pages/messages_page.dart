import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/driver.dart';
import 'package:ebuber/classes/passenger.dart';
import 'package:ebuber/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/driver_profile_screen.dart';
import 'package:ebuber/passenger/screens/main_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({Key? key, required this.chatID}) : super(key: key);

  final String chatID;

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  ScrollController _scrollController = ScrollController();
  final TextEditingController _message = TextEditingController();


  @override
  Widget build(BuildContext context) {

    final driver = ref.watch(driverStreamProvider(widget.chatID));
    final passenger = ref.watch(passengerStreamProvider(FirebaseAuth.instance.currentUser!.uid));
    final messages = ref.watch(messagesStreamProvider(widget.chatID));

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;


    return Scaffold(
      body: SafeArea(
        child: driver.when(
          data: (driver) => passenger.when(
            loading: () => Center(child: CircularProgressIndicator(),),
            error: (error, stackTrace) => Container(),
            data: (passenger) => SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            SizedBox(width: width * .01,),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, _routeToSignInScreen(DriverProfileScreen(driverUid: driver.uid,)));
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(driver.photo),
                                    radius: 17.5,
                                  ),
                                  SizedBox(width: 10,),
                                  Text(driver.name, style: TextStyle(
                                      fontSize: 17.5, fontFamily: kFontFamily, color: kDarkColors[8], fontWeight: FontWeight.bold
                                  ),),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // IconButton(
                        //   onPressed: () => Navigator.push(context, _routeToSignInScreen(CallScreen(driverUid: widget.chatID,))),
                        //   icon: Icon(Icons.call, color: kDarkColors[4]),
                        //   splashRadius: 25,
                        // ),

                      ],
                    ),
                  ),
                  Container(
                    width: width,
                    height: height * .8,
                    alignment: Alignment.bottomCenter,
                    child: messages.when(
                      data: (message) {
                        if (message.length != 0) {
                          return ListView.builder(
                            padding: EdgeInsets.only(top: 10),
                            physics: BouncingScrollPhysics(),
                            controller: _scrollController,
                            reverse: true,
                            itemCount: message.length != 0 ? message.length : 1, //TODO
                            itemBuilder: (context, index) {

                              return message.length != 0
                                  ?  messagess(MediaQuery.of(context).size, message[index].toDocument(), context) :
                              Center(child: Column(
                                children: [
                                  Text("Herhangi bir mesaj yok",
                                      style: TextStyle(fontSize: 17.5, color: kDarkColors[7], fontFamily: kFontFamily)),
                                  SizedBox(height: 10,),
                                ],
                              ),);
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                      loading: () => Center(child: CircularProgressIndicator(),),
                      error: (error, stackTrace) => Container(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 7.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: width * .8, height: height * .07,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Material(
                                color: kLightColors[0],
                                child: TextField(
                                  showCursor: true,
                                  controller: _message,
                                  style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: kFontFamily),
                                  cursorColor: Colors.pink,
                                  textAlign: TextAlign.start,
                                  onTap: () => _animateToLast(),
                                  decoration: InputDecoration(

                                    /*suffixIcon: IconButton(
                                  onPressed: () => onSendMessage(driver, passenger),
                                  icon: Icon(Icons.send, color: Colors.white, size: 20),
                                  splashRadius: 20,
                                ),*/
                                    contentPadding: EdgeInsets.all(10),
                                    hintStyle: TextStyle(color: Colors.white70, fontSize: 15, fontFamily: kFontFamily),
                                    hintText: !MainScreen.english ? "Mesaj Yaz" : "Type a message",

                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                  ),

                                ),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => onSendMessage(driver, passenger),
                          child: Icon(Icons.send, color: Colors.white, size: 20,),

                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(12),
                            primary: kDarkColors[2], // <-- Button color
                            onPrimary: kDarkColors[0], // <-- Splash color
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          error: (error, stackTrace) => Container(),
          loading: () => Center(child: CircularProgressIndicator(),),
        ),
      ),
    );
  }


  _animateToLast() {
    debugPrint('scroll down');
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
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

  onSendMessage(Driver driver, Passenger passenger) async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": FirebaseAuth.instance.currentUser!.uid,
        "message": _message.text,
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();

      await FirebaseFirestore.instance.collection('passengers').doc(FirebaseAuth.instance.currentUser!.uid).collection("messages")
          .doc(widget.chatID).set({"uid" : widget.chatID});


      await FirebaseFirestore.instance.collection('drivers').doc(widget.chatID)
          .collection("messages").doc(FirebaseAuth.instance.currentUser!.uid).set(
          {"uid" : FirebaseAuth.instance.currentUser!.uid});

      await FirebaseFirestore.instance.collection('passengers').doc(FirebaseAuth.instance.currentUser!.uid).collection("messages")
          .doc(widget.chatID).collection('chats').add(messages);

      await FirebaseFirestore.instance.collection('drivers').doc(widget.chatID)
          .collection("messages").doc(FirebaseAuth.instance.currentUser!.uid).collection('chats').add(messages);

      sendPushMessage(messages["message"], "${passenger.name} sana bir mesaj gönderdi", driver.token, passenger.uid);


    } else {
      print("Enter Some Text");
    }

    _animateToLast();
  }

  void sendPushMessage(String body, String title, String token, currentUid) async {
    try {
      await post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
          'key=your-key-here',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'rsvp',
              "uid" : currentUid,
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
      print('done');


    } catch (e) {
      print("error push notification");
    }
  }

  Widget messagess(Size size, Map<String, dynamic> map, BuildContext context) {

    return Container(
      width: size.width,
      padding: EdgeInsets.only(bottom: 5),
      alignment: map['sendby'] == FirebaseAuth.instance.currentUser!.uid
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: map['sendby'] == FirebaseAuth.instance.currentUser!.uid ?
          kDarkColors[0] : kDarkColors[4],
        ),
        child: Text(
          map['message'],
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );

  }

}
