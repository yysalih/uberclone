import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constant.dart';
import '../main_screen.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(

      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              child: Row(
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
                  Text(!MainScreen.english ? "Bize Ulaşın" : "Contact Us", style: TextStyle(
                      fontSize: 25, fontFamily: kFontFamily, color: kDarkColors[8], fontWeight: FontWeight.bold
                  ),),
                ],
              ),
            ),
            ContactUsItem(title: "Facebook", width: width, height: height, icon: "facebook", url: "https://www.facebook.com/profile.php?id=100086236787093"),
            ContactUsItem(title: "Instagram", width: width, height: height, icon: "instagram", url: "https://www.instagram.com/tosbaago"),
            ContactUsItem(title: "Twitter", width: width, height: height, icon: "twitter", url: "https://twitter.com/TosbaaGo"),
            ContactUsItem(title: "Linkedin", width: width, height: height, icon: "linkedin", url: "https://www.linkedin.com/company/tosbaago/"),
            ContactUsItem(title: "Email", width: width, height: height, icon: "gmail", url: "destek@tosbaago.com"),
            //ContactUsItem(title: "Telefon", width: width, height: height, icon: "phone", ),
            ContactUsItem(title: "Website", width: width, height: height, icon: "web", url: "https://tosbaago.com/"),
          ],
        ),
      ),
    );
  }
}

class ContactUsItem extends StatelessWidget {
  const ContactUsItem({
    Key? key, required this.width, required this.height, required this.icon, required this.title, required this.url,
  }) : super(key: key);
  final double width;
  final double height;
  final String icon;
  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      child: MaterialButton(
        height: height * .1,
        onPressed: () => _launchURL(url),
        child: Row(
          children: [
            Image.asset("images/icons/$icon.png", width: width * .1, fit: BoxFit.contain,),
            SizedBox(width: 20,),
            Text("$title", style: TextStyle(fontFamily: kFontFamily,fontSize: 20),)
          ],
        ),
      ),
    );
  }

  _launchURL(String url) async {
    await launchUrl(Uri.parse(url));
  }
}
