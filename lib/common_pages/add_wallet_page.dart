import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/utils/encryption_decryption.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import '../constant.dart';
import '../passenger/screens/main_screen.dart';
import 'package:ebuber/classes/card.dart' as card;

class AddWalletPage extends StatefulWidget {
  const AddWalletPage({Key? key}) : super(key: key);

  @override
  State<AddWalletPage> createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage> {

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = true;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(MainScreen.english ? "Add Card" : "Kart Ekle", style: TextStyle(
                      fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.bold
                  ),),
                ],
              ),
              CreditCardWidget(
                glassmorphismConfig:
                useGlassMorphism ? Glassmorphism.defaultConfig() : null,
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,

                bankName: 'Iyzico',
                frontCardBorder:
                !useGlassMorphism ? Border.all(color: Colors.grey) : null,
                backCardBorder:
                !useGlassMorphism ? Border.all(color: Colors.grey) : null,
                showBackView: isCvvFocused,
                obscureCardNumber: true,
                obscureCardCvv: true,
                isHolderNameVisible: true,
                cardBgColor: kDarkColors[9],

                isSwipeGestureEnabled: true,
                onCreditCardWidgetChange:
                    (CreditCardBrand creditCardBrand) {},
                customCardTypeIcons: <CustomCardTypeIcon>[
                  CustomCardTypeIcon(
                    cardType: CardType.mastercard,
                    cardImage: Image.asset(
                      "images/icons/mastercard.png",
                      height: 48,
                      width: 48,
                    ),
                  ),
                ],
              ),
              CreditCardForm(
                formKey: formKey,
                obscureCvv: true,
                obscureNumber: true,
                cardNumber: cardNumber,
                cvvCode: cvvCode,
                isHolderNameVisible: true,
                isCardNumberVisible: true,
                isExpiryDateVisible: true,
                cardHolderName: cardHolderName,
                expiryDate: expiryDate,
                themeColor: Colors.blue,
                textColor: Colors.black,
                cardNumberDecoration: InputDecoration(
                  hintStyle: const TextStyle(fontFamily: kFontFamily),
                  labelStyle: const TextStyle(fontFamily: kFontFamily),
                  labelText: MainScreen.english ? 'Number' : "Kart Numarası",
                  hintText: 'XXXX XXXX XXXX XXXX',
                  focusedBorder: border,
                  enabledBorder: border,
                ),
                expiryDateDecoration: InputDecoration(
                  hintStyle: const TextStyle(fontFamily: kFontFamily),
                  labelStyle: const TextStyle(fontFamily: kFontFamily),
                  focusedBorder: border,
                  enabledBorder: border,
                  labelText: MainScreen.english ? 'Expired Date' : "Son Kullanma Tarihi",
                  hintText: 'XX/XX',
                ),
                cvvCodeDecoration: InputDecoration(
                  hintStyle: const TextStyle(fontFamily: kFontFamily),
                  labelStyle: const TextStyle(fontFamily: kFontFamily),
                  focusedBorder: border,
                  enabledBorder: border,
                  labelText: 'CVV',
                  hintText: 'XXX',
                ),
                cardHolderDecoration: InputDecoration(
                  hintStyle: const TextStyle(fontFamily: kFontFamily),
                  labelStyle: const TextStyle(fontFamily: kFontFamily),
                  focusedBorder: border,
                  enabledBorder: border,
                  labelText: MainScreen.english ? 'Card Holder' : "Kart Sahibi",
                ),

                onCreditCardModelChange: onCreditCardModelChange,
              ),

              GestureDetector(
                onTap: _onValidate,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        kDarkColors[5],
                        kDarkColors[6],
                        kDarkColors[7],
                        kDarkColors[8],
                        kDarkColors[9],
                        kLightColors[0],
                        kLightColors[1],
                        kLightColors[2],
                        kLightColors[3],
                        kLightColors[4],
                        kLightColors[5],
                      ],
                      begin: Alignment(-1, -4),
                      end: Alignment(1, 4),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    MainScreen.english ? 'Validate' : "Onayla",
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: kFontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.bold
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
  void _onValidate() async {
    if (formKey.currentState!.validate()) {
      card.Card creditCard = card.Card(
        cardNumber: EncryptionDecryption.encryptMessage(cardNumber),
        cardHolderName: EncryptionDecryption.encryptMessage(cardHolderName),
        uid: "",
        cardAlias: "**** ${cardNumber.substring(cardNumber.length - 4, cardNumber.length)}",
        cvc: EncryptionDecryption.encryptMessage(cvvCode),
        expire: EncryptionDecryption.encryptMessage(expiryDate),
      );



      await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("cards").add(creditCard.toDocument()).then((value) async {
        await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("cards").doc(value.id).update({"uid" : value.id});
      });
      Navigator.pop(context);
      print('valid!');
    } else {
      print('invalid!');
    }
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

}
