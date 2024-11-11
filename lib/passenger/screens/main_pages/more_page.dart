import 'package:flutter/material.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/contact_us_page.dart';
import 'package:ebuber/passenger/screens/ProfilePageInnerScreens/faq_page.dart';
import 'package:ebuber/passenger/screens/main_screen.dart';

class MorePage extends StatelessWidget {
  MorePage({Key? key}) : super(key: key);

  List titles = [
    !MainScreen.english ? "Kullanım Koşulları" : "Terms of Use",
    !MainScreen.english ? "Üyelik Sözleşmesi" : "Membership Agreement",
    "KVKK",
    !MainScreen.english ? "Gizlilik Politikası" : "Privacy Policy",
    !MainScreen.english ? "Çerez Politikası" : "Cookies",
    !MainScreen.english ? "Kullanıcı/Sürücü Aydınlatma Açık Rıza Metinleri" : "User/Driver Lighting Explicit Consent Texts",
    !MainScreen.english ? "İptal ve Cayma Koşulları" : "Cancellation and Withdrawal Conditions",
    !MainScreen.english ? "Mesafeli Satış Sözleşmesi" : "Distance Sales Contract",
    !MainScreen.english ? "Sıkça Sorulan Sorular" : "Frequently Asked Questions",
    !MainScreen.english ? "Bize Ulaşın" : "Contact Us",
    !MainScreen.english ? "Uygulamayı Paylaşın" : "Share the App",
  ];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10,),
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
                Text(!MainScreen.english ? "Daha Fazla" : "More", style: TextStyle(
                    fontSize: 17.5, fontFamily: kFontFamily, color: kDarkColors[8], fontWeight: FontWeight.bold
                ),),
              ],
            ),
            SizedBox(height: 10,),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width, maxHeight: height * .85),
                child: ListView.builder(
                  itemBuilder: (context, i) => Container(
                    width: width, height: height * .085,
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: MaterialButton(
                        color: kDarkColors[2],
                        onPressed: () {
                          if(i == 9) {
                            Navigator.push(context, _routeToSignInScreen(FAQPage()));
                          }

                          else if(i == 10) {
                            Navigator.push(context, _routeToSignInScreen(ContactUsScreen()));
                          }
                        },
                        child: Text(titles[i], style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15, fontFamily: kFontFamily
                        ), textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                  itemCount: titles.length,
                  physics: BouncingScrollPhysics(),
                ),
              )
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
