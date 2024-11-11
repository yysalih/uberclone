import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebuber/main.dart';
import 'package:email_auth/email_auth.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/passenger/screens/main_screen.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {

  FirebaseStorage storage = FirebaseStorage.instance;

  File? _photo;
  final ImagePicker _picker = ImagePicker();

  bool isCompleted = true;

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final currentuser = ref.watch(passengerStreamProvider(FirebaseAuth.instance.currentUser!.uid));

    return Scaffold(
      appBar: AppBar(
        title: Text(!MainScreen.english ? "Profili Düzenle" : "Edit Your Profile", style: TextStyle(fontFamily: kFontFamily),),
        backgroundColor: kColor1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(12),
            child: currentuser.when(
              error: (error, stackTrace) => Container(),
              loading: () => Center(child: CircularProgressIndicator(),),
              data: (currentuser) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _showPicker(context),
                    child: CircleAvatar(
                      radius: height * .065, backgroundImage: CachedNetworkImageProvider(currentuser.photo),
                      backgroundColor: kDarkColors[2],
                      child: isCompleted ? Icon(Icons.edit, color: Colors.white, size: height * .035,) : CircularProgressIndicator(),
                    ),
                  ),
                  SizedBox(height: height * .05,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      EditProfilePageItem(width: width, height: height,
                          title: !MainScreen.english ? "Ad - Soyad" : "Name - Last Name",
                          content: currentuser.name, type: "name"),
                      EditProfilePageItem(width: width, height: height, title: "Email",
                          content: currentuser.email, type: "email"),
                      EditProfilePageItem(width: width, height: height,
                        title: !MainScreen.english ? "Telefon" : "Phone", type: "phone",
                        content: currentuser.phone == "" ? "Ekle" : currentuser.phone,),
                    ]
                  ),
                  SizedBox(height: height * .05,),
                  Container(
                    width: width,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: MaterialButton(
                          height: height * .075,
                          color: kColor1,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(!MainScreen.english ? "Güncelle" : "Update",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: kFontFamily),),
                        )
                    ),
                  ),
                ],
              ),
            )
          ),
        ),
      ),
    );
  }



  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName = basename(_photo!.path);

    //String url = await storage.ref("files/$fileName/file").getDownloadURL();
    //print(url);



    final destination = 'files/$fileName';

    try {
      setState(() {
        isCompleted = false;
      });
      final ref = FirebaseStorage.instance.ref(destination);
      await ref.putFile(_photo!);
      var pathReference = storage.ref('files/$fileName');

      pathReference.getDownloadURL().then((value) async {
        await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid).update({
          "photo" : value
        });
        print(value);
      });

      setState(() {
        isCompleted = true;
      });
    } catch (e) {
      print('error occured');
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Gallery'),
                      onTap: () {
                        imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class EditProfilePageItem extends StatefulWidget {
  EditProfilePageItem({
    Key? key,
    required this.width,
    required this.height, required this.title, required this.content, required this.type,
  }) : super(key: key);

  final double width;
  final double height;
  final String title;
  final String content;
  final String type;

  @override
  State<EditProfilePageItem> createState() => _EditProfilePageItemState();
}

class _EditProfilePageItemState extends State<EditProfilePageItem> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailOTPController = TextEditingController();

  FirebaseAuth user = FirebaseAuth.instance;
  bool isEmailVerified = false;
  bool isEmailSent = false;

  Timer timer = Timer.periodic(Duration(seconds: 0), (_) {});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      alignment: Alignment.centerLeft,
      child: MaterialButton(
        onPressed: () async {
          if(!isEmailVerified) {
            sendVerificationEmail();
            timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified());
          }

          if(widget.type == "email") {
            //await sendEmail("balkisyazar04788@gmail.com", "TosbaaGo", "Bu email TosbaaGo uygulaması üzerinden gönderilmiştir...");
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(!MainScreen.english ? "Emailini Güncelle" : "Change your email", style: TextStyle(
                  fontFamily: kFontFamily, fontWeight: FontWeight.bold,
                ),),
                content: Column(
                  children: [
                    TextField(
                      controller: emailController,

                    ),
                    SizedBox(height: 20,),
                    TextField(
                      controller: emailOTPController,
                      decoration: InputDecoration(
                          suffixIcon: TextButton(
                            child: Text("Send OTP", style: TextStyle(color: Colors.black87),),
                            onPressed: () async {
                              //await sendOTP();
                              await send(context);
                            },
                          )
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await verifyOTP();

                      await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid).update({
                        "email" : emailController.text,
                      });
                      //Navigator.pop(context);
                    },
                    child: Text(!MainScreen.english ? "Kaydet" : "Save", style: TextStyle(fontFamily: kFontFamily),),
                  ),
                  TextButton(
                    onPressed: () async {
                      await sendOTP();

                    },
                    child: Text(!MainScreen.english ? "Gönder" : "Send", style: TextStyle(fontFamily: kFontFamily),),
                  ),
                ],
              ),
            );
          }
        },
        height: widget.height * .1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${widget.title}", style: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.start),
                widget.type == "email" || widget.type == "phone" ? Text(user.currentUser!.emailVerified ? "Doğrulandı" : "Doğrulanmadı",
                    style: TextStyle(fontFamily: kFontFamily, color:user.currentUser!.emailVerified ? Colors.lightGreen : Colors.redAccent, fontSize: 15))
                    : Container()
              ],
            ),
            SizedBox(height: 10,),
            Text("${widget.content}", style: TextStyle(fontFamily: kFontFamily, fontSize: 17.5,), textAlign: TextAlign.start),
          ],
        ),
      ),
    );
  }
  EmailAuth emailAuth = EmailAuth(sessionName: "Test Session");

  sendOTP() async {
    emailAuth.sessionName = "Test Session";

    var res = await emailAuth.sendOtp(recipientMail: emailController.text);
    if(res) {
      print("OTP Sent");
    } else {
      print("OTP couldn't be sent");
    }
  }

  verifyOTP() async {
    var res = emailAuth.validateOtp(recipientMail: emailController.text, userOtp: emailOTPController.text);
    if(res) {
      print("OTP Verified");
    } else {
      print("Invalid OTP");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isEmailVerified = user.currentUser!.emailVerified;

  }

  Future sendVerificationEmail() async {
    try{
      await user.currentUser!.sendEmailVerification();
      setState(() {
        isEmailSent = true;
      });
    }
    catch(e) {
      print(e);
    }
  }

  checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if(isEmailVerified) timer.cancel();

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




  List<String> attachments = [];
  bool isHTML = false;

  final _recipientController = TextEditingController(
    text: 'balkisyazar04788@gmail.com',
  );

  final _subjectController = TextEditingController(text: 'The subject');

  final _bodyController = TextEditingController(
    text: 'Mail body.',
  );

  Future<void> send(BuildContext context) async {
    final Email email = Email(
      body: _bodyController.text,
      subject: _subjectController.text,
      recipients: [_recipientController.text],
      attachmentPaths: attachments,
      isHTML: isHTML,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      print(error);
      platformResponse = error.toString();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(platformResponse),
      ),
    );
  }





  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    super.dispose();
  }
}
