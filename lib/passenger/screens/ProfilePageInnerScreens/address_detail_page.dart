import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/select_address_on_map_page.dart';

import '../../../constant.dart';
import '../main_screen.dart';

class AddresDetailPage extends ConsumerStatefulWidget {

  const AddresDetailPage({Key? key, required this.addressMap}) : super(key: key);

  final Map<String, dynamic> addressMap;


  @override
  ConsumerState<AddresDetailPage> createState() => _AddresDetailPageState();
}

class _AddresDetailPageState extends ConsumerState<AddresDetailPage> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);
  final LatLng _destination = const LatLng(45.56752541455082, -122.64465091440553);


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  final homeScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setParameters();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final address = ref.watch(addressStreamProvider(widget.addressMap["uid"]));

    return Scaffold(
      key: homeScaffoldKey,
      resizeToAvoidBottomInset: false,
      body: address.when(
        data: (address) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                          Text(!MainScreen.english ? "Adresi Düzenle" : "Edit Address", style: TextStyle(
                              fontSize: 17.5, fontFamily: kFontFamily, color: kDarkColors[8], fontWeight: FontWeight.bold
                          ),),
                        ],
                      ),
                      SizedBox(height: height * .025),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(!MainScreen.english ? "Başlık" : "Title", style: TextStyle(
                                  fontSize: 15, fontFamily: kFontFamily, color: Colors.black87
                              ),),
                              SizedBox(height: 5,),
                              Container(
                                width: width, height: height * .075,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Material(
                                    color: kLightColors[8],
                                    child: TextField(
                                      controller: titleController,

                                      style: TextStyle(color: Colors.black54, fontFamily: kFontFamily, fontSize: 12.5,),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(20),
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * .05,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(!MainScreen.english ? "Adres" : "Address", style: TextStyle(
                                  fontSize: 15, fontFamily: kFontFamily, color: Colors.black87
                              ),),
                              SizedBox(height: 5,),
                              Container(
                                width: width, height: height * .2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Material(
                                    color: kLightColors[8],
                                    child: TextField(
                                      enabled: false,
                                      controller: descriptionController..text = address.description,
                                      style: TextStyle(color: Colors.black54, fontFamily: kFontFamily, fontSize: 12.5,),
                                      maxLines: 6,
                                      decoration: InputDecoration(
                                        enabled: false,
                                        hintText: !MainScreen.english ? "Harita üzerinden adresi belirle" :
                                        "Select the address on the map",
                                        contentPadding: EdgeInsets.all(20),
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * .05,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(!MainScreen.english ? "Not" : "Note", style: TextStyle(
                                  fontSize: 15, fontFamily: kFontFamily, color: Colors.black87
                              ),),
                              SizedBox(height: 5,),
                              Container(
                                width: width, height: height * .2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Material(
                                    color: kLightColors[8],
                                    child: TextField(
                                      controller: noteController,
                                      style: TextStyle(color: Colors.black54, fontFamily: kFontFamily, fontSize: 12.5,),
                                      maxLines: 6,
                                      decoration: InputDecoration(
                                        hintText: !MainScreen.english ? "Kendin ve sürücüler için açıklayıcı bir not ekle" :
                                        "Add a descriptive note for you and drivers",
                                        contentPadding: EdgeInsets.all(20),
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, _routeToSignInScreen(SelectAddressOnMapPage(addressUid: widget.addressMap["uid"],)));
                            },

                            child: Text(!MainScreen.english ? "Haritadan Seç" : "Select On The Map", style: TextStyle(
                              fontSize: 12.5, fontFamily: kFontFamily
                            ),),
                          ),
                          Container(
                            width: width, height: height * .25,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),

                              child: GoogleMap(
                                scrollGesturesEnabled: false,
                                zoomGesturesEnabled: false,
                                mapToolbarEnabled: false,
                                onMapCreated: _onMapCreated,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(address.latlng[0], address.latlng[1]),
                                  zoom: 11.0,
                                ),

                                markers: {
                                  Marker(
                                    markerId: MarkerId("source"),
                                    position: LatLng(address.latlng[0], address.latlng[1]),
                                  ),
                                },
                                zoomControlsEnabled: false,
                              ),
                            ),

                          ),
                        ],
                      ),
                      SizedBox(height: height * .02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextButton(
                            child: Text(!MainScreen.english ? "Adresi Sil" : "Delete the Address", style: TextStyle(
                                fontSize: 12.5, fontFamily: kFontFamily, color: Colors.redAccent, fontWeight: FontWeight.bold
                            ),),
                            onPressed: () async {
                              if(widget.addressMap["uid"] != "home" || widget.addressMap["uid"] != "work" || widget.addressMap["uid"] != "school")
                                await showDialog(context: context, builder: (context) => AlertDialog(
                                  title: Text(!MainScreen.english ? "Adresi Sil" : "Delete the Address", style: TextStyle(fontWeight: FontWeight.bold,
                                      fontSize: 15, fontFamily: kFontFamily),),

                                  content: Text(!MainScreen.english ? "Adresi silmek istediğinize emin misiniz?"
                                      : "Are you sure that you want to delete the address?", style: TextStyle(
                                      fontSize: 12.5, fontFamily: kFontFamily),),

                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(MainScreen()), (route) => false);

                                        await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid)
                                            .collection("addresses").doc(widget.addressMap["uid"]).delete();

                                      },

                                      child: Text(!MainScreen.english ? "Evet" : "Yes", style: TextStyle(fontFamily: kFontFamily),),
                                    ),
                                    TextButton(
                                      onPressed: () async {

                                        Navigator.pop(context);
                                      },

                                      child: Text(!MainScreen.english ? "Hayır" : "No", style: TextStyle(fontFamily: kFontFamily),),
                                    ),
                                  ],
                                ));
                            },
                          ) ,
                          Container(
                            width: width, height: height * .07,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: MaterialButton(
                                color: kDarkColors[2],
                                onPressed: () async {
                                  await updateSavedAddress();

                                  Navigator.pop(context);
                                  //Navigator.pushAndRemoveUntil(context, _routeToSignInScreen(MainScreen()), (route) => false);
                                },
                                child: Text(!MainScreen.english ? "Adresi Güncelle" : "Update the Address", style: TextStyle(
                                    color: Colors.white, fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.bold
                                ),),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  )
              ),
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(),),
        error: (error, stackTrace) => Container(),
      )
    );
  }


  setParameters() async {
    await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("addresses").doc(widget.addressMap["uid"]).get().then((value) {
      setState(() {
        titleController.text = value["title"];
        descriptionController.text = value["description"];
        noteController.text = value["note"];
      });
    });
  }



  updateSavedAddress() async {
    await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("addresses").doc(widget.addressMap["uid"]).update({
      "title" : titleController.text, "description" : descriptionController.text, "note" : noteController.text
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
}
