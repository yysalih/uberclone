import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/add_new_address_page.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/address_detail_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main_screen.dart';

class AddressPage extends ConsumerStatefulWidget {
  AddressPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends ConsumerState<AddressPage> {
  List list = ["Ev", "İş"];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final addresses = ref.watch(addressesStreamProvider);

    return Scaffold(

      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            padding: EdgeInsets.only(top: 12, left: 12, right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Text(!MainScreen.english ? "Kayıtlı Adreslerin" : "Saved Addresses", style: TextStyle(
                        fontSize: 17.5, fontFamily: kFontFamily, color: kDarkColors[8], fontWeight: FontWeight.bold
                    ),),
                  ],
                ),
                Center(child: Image.asset("images/ills/map.png", width: width * .5, fit: BoxFit.contain)),
                //SizedBox(height: height * 0.01,),
                addresses.when(
                  error: (error, stackTrace) => Container(),
                  loading: () => Center(child: CircularProgressIndicator(),),
                  data: (addresses) => Column(

                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      for(int i = 0; i < addresses.length; i++) Column(
                        children: [
                          Container(
                            width: width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: kLightColors[7]
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: MaterialButton(
                                onPressed: () {
                                  Navigator.push(context, _routeToSignInScreen(AddresDetailPage(addressMap: addresses[i].toDocument(),)));
                                },
                                child: Container(
                                  padding: EdgeInsets.all(7.5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            Icon(Icons.location_on_rounded, color: kDarkColors[4], size: 15,),
                                            SizedBox(width: 5,),
                                            Text("${addresses[i].title}", style: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.bold,
                                                color: kBottomBarIconsColor, fontSize: 12.5),),
                                          ],),
                                          Text(!MainScreen.english ? "Düzenle" : "Edit", style:
                                          TextStyle(color: kDarkColors[9], fontFamily: kFontFamily, fontSize: 10),)
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: width, maxHeight: height * .1),
                                        child: Text("${addresses[i].description}",
                                            textAlign: TextAlign.start, overflow: TextOverflow.ellipsis, maxLines: 2, style: TextStyle(
                                                fontSize: 10, color: Colors.black54, fontFamily: kFontFamily, fontWeight: FontWeight.bold
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15,)
                        ],
                      )


                    ],
                  ),
                )


              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, _routeToSignInScreen(AddNewAddressPage()));
        },
        child: Icon(Icons.add),
        backgroundColor: kDarkColors[2],
      )
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
