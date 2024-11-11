import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/passenger/screens/message_pages/messages_page.dart';

import '../main_screen.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.all(10),
              child: Text(!MainScreen.english ? "Mesajlar" : "Messages", style: TextStyle(
                fontWeight: FontWeight.bold, fontFamily: kFontFamily, fontSize: 17.5
              ),),
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('passengers')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection("messages").snapshots(),
              builder: (context, snapshot) {



                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator(),);
                }

                try {
                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width, maxHeight: height * .8),
                    child: snapshot.data!.docs.length == 0 ? Center(child: Column(
                      children: [
                        Image.asset("images/ills/message.png", width: width * .5, fit: BoxFit.contain,),
                        SizedBox(height: 20,),
                        Text(!MainScreen.english ?
                        "Herhangi bir mesajın yok" : "You have no messages", style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15, fontFamily: kFontFamily
                        ),),
                      ],
                    ),) :

                    ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return MaterialButton(
                          onPressed: () async {
                            Navigator.push(context, _routeToSignInScreen(MessagesPage(chatID: snapshot.data!.docs[index]["uid"])));
                          },
                          child: Container(
                            padding: EdgeInsets.only(bottom: 10, top: 10),

                            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance.collection("drivers")
                                  .doc(snapshot.data!.docs[index].id).snapshots(),
                              builder: (context, snapshot2) {
                                if(!snapshot2.hasData) return Center(child: CircularProgressIndicator(),);

                                try {
                                  return Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: CachedNetworkImageProvider(snapshot2.data!.data()!["photo"]),
                                        backgroundColor: kColor1,

                                      ),
                                      SizedBox(width: 10,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,

                                        children: [
                                          ConstrainedBox(
                                            child: Text(snapshot2.data!.data()!["name"], textAlign: TextAlign.left,maxLines: 1,
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,
                                                    fontFamily: kFontFamily, fontSize: 15),
                                                textDirection: TextDirection.ltr, overflow: TextOverflow.clip),
                                            constraints: BoxConstraints(
                                                maxWidth: width * 0.4
                                            ),
                                          ),


                                          SizedBox(height: 5,),
                                          StreamBuilder(
                                              stream: FirebaseFirestore.instance.collection('passengers')
                                                  .doc(FirebaseAuth.instance.currentUser!.uid).collection("messages")
                                                  .doc(snapshot2.data!.data()!["uid"]).collection("chats").orderBy("time").snapshots(),
                                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot3) {
                                                if (!snapshot3.hasData) {
                                                  return Center(
                                                    child: Text(""),
                                                  );
                                                }

                                                try {
                                                  return ConstrainedBox(
                                                      child: Text("${snapshot3.data!.docs.last["message"]}",
                                                          textAlign: TextAlign.left,maxLines: 1,
                                                          style: TextStyle(fontSize: 12.5, color: Colors.black54, fontWeight: FontWeight.normal),
                                                          textDirection: TextDirection.ltr, overflow: TextOverflow.ellipsis),
                                                      constraints: BoxConstraints(
                                                          maxWidth: width * 0.6
                                                      ));
                                                }
                                                catch(E) {
                                                  return Container();
                                                }
                                              }
                                          ),

                                        ],
                                      ),
                                    ],
                                  );
                                }
                                catch(E) {
                                  return Container();
                                }
                              },
                            ),
                          ),
                        );
                      },
                      itemCount: snapshot.data!.docs.length,
                    ),
                  );
                }

                catch(E) {
                  return Container();
                }


              },
            ),
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

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
