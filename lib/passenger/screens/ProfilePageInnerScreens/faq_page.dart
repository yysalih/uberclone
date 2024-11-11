import 'package:flutter/material.dart';
import 'package:folding_cell/folding_cell.dart';
import '../../../constant.dart';
import '../main_screen.dart';

class FAQPage extends StatelessWidget {
  FAQPage({Key? key}) : super(key: key);
  final _foldingCellKey = GlobalKey<SimpleFoldingCellState>();
  final _foldingCellKey2 = GlobalKey<SimpleFoldingCellState>();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(

      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(12),

          child: Column(
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
                  Text(!MainScreen.english ? "SSS" : "FAQ", style: TextStyle(
                      fontSize: 25, fontFamily: kFontFamily, color: kDarkColors[8], fontWeight: FontWeight.bold
                  ),),
                ],
              ),
              ExpansionTile(
                title: Text('Soru 1'),
                subtitle: Text('Cevabı görmek için tıkla'),
                children: <Widget>[
                  ListTile(title: Text('Cevap 1')),
                ],
              ),
              ExpansionTile(
                title: Text('Soru 2'),
                subtitle: Text('Cevabı görmek için tıkla'),
                children: <Widget>[
                  ListTile(title: Text('Cevap 2')),
                ],
              ),
              ExpansionTile(
                title: Text('Soru 3'),
                subtitle: Text('Cevabı görmek için tıkla'),
                children: <Widget>[
                  ListTile(title: Text('Cevap 3')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


}
