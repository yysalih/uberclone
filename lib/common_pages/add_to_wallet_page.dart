import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:credit_card_type_detector/models.dart';
import 'package:ebuber/common_pages/wallet_page.dart';
import 'package:ebuber/main.dart';
import 'package:ebuber/utils/encryption_decryption.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iyzico/iyzico.dart';


import '../classes/passenger.dart';
import '../constant.dart';
import '../passenger/screens/main_screen.dart';
import 'package:ebuber/classes/card.dart' as card;

class AddToWalletPage extends ConsumerStatefulWidget {
  const AddToWalletPage({Key? key, required this.creditCard}) : super(key: key);

  final card.Card creditCard;

  @override
  ConsumerState<AddToWalletPage> createState() => _AddToWalletPageState();
}

class _AddToWalletPageState extends ConsumerState<AddToWalletPage> {

  TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    List<CreditCardType> cardType = detectCCType(EncryptionDecryption.decryptMessage(encrypt.Encrypted.fromBase64(widget.creditCard.cardNumber)));

    final passenger = ref.watch(passengerStreamProvider(FirebaseAuth.instance.currentUser!.uid));


    return Scaffold(
      body: SafeArea(
        child: passenger.when(
          data: (passenger) => Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(MainScreen.english ? "Add to Wallet" : "Cüzdana Para Ekle", style: TextStyle(
                            fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.bold
                        ),),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(MainScreen.english ? "Selected Card" : "Seçili Kart", style: TextStyle(
                          fontWeight: FontWeight.bold, fontFamily: kFontFamily, fontSize: 15,
                        ),),
                        SizedBox(height: 10,),
                        CreditCard(width: width, height: height, type: cardType.first.type, number: widget.creditCard.cardAlias, onTap: () {

                        })
                      ],
                    ),
                    SizedBox(height: 20,),
                    Center(
                      child: Container(
                        width: width * .8,
                        child: TextField(
                          controller: amountController,
                          style: TextStyle(
                              fontFamily: kFontFamily
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                              labelText: MainScreen.english ? "Amount" : "Miktar",
                              labelStyle: TextStyle(
                                  fontFamily: kFontFamily
                              ),
                              suffixText: "TL"
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  width: width, height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: MaterialButton(
                      color: kDarkColors[7],
                      onPressed: () async {
                        if(amountController.text != "") {
                          await pay2(passenger);

                        }

                        else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(MainScreen.english ? "Please input an amount" : "Lütfen miktar belirtiniz", style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17.5, fontFamily: kFontFamily
                            ),),
                            backgroundColor: Colors.redAccent,
                          ));
                        }
                      },
                      child: Text(MainScreen.english ? "Complete" : "Onayla", style: TextStyle(
                          fontFamily: kFontFamily, fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white
                      ),),
                    ),
                  ),
                ),
              ],
            ),
          ),
          error: (error, stackTrace) => Container(),
          loading: () => Center(child: CircularProgressIndicator(),),
        )
      ),
    );
  }


  pay2(Passenger passenger) async {

    /*final paymentCard = PaymentCard(
      cardHolderName: EncryptionDecryption.decryptMessage(encrypt.Encrypted.fromBase64(widget.creditCard.cardHolderName)),
      cardNumber: EncryptionDecryption.decryptMessage(encrypt.Encrypted.fromBase64(widget.creditCard.cardNumber)),
      expireYear: EncryptionDecryption.decryptMessage(encrypt.Encrypted.fromBase64(widget.creditCard.expire)).split("/").last,
      expireMonth: EncryptionDecryption.decryptMessage(encrypt.Encrypted.fromBase64(widget.creditCard.expire)).split("/").first,
      cvc: '123',
    );*/
    const iyziConfig = IyziConfig(
        'sandbox-6jbxQoyzLh8PehdsHRQ53tUVMVY1HMdP',
        'sandbox-SgOajkryxkWzfEw2YTmr97muhdf27eYy',
        'https://sandbox-api.iyzipay.com');

    //Create an iyzico object
    final iyzico = Iyzico.fromConfig(configuration: iyziConfig);


    final double price = double.parse(amountController.text);
    final double paidPrice = double.parse(amountController.text) + (double.parse(amountController.text) * .1);

    final paymentCard = PaymentCard(
      cardHolderName: 'John Doe',
      cardNumber: '5528790000000008',
      expireYear: '2030',
      expireMonth: '12',
      cvc: '123',
    );

    final shippingAddress = Address(
        address: 'Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1',
        contactName: 'Jane Doe',
        zipCode: '34742',
        city: 'Istanbul',
        country: 'Turkey');
    final billingAddress = Address(
        address: 'Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1',
        contactName: 'Jane Doe',
        city: 'Istanbul',
        country: 'Turkey');

    final buyer = Buyer(
        id: 'BY789',
        name: 'John',
        surname: 'Doe',
        identityNumber: '74300864791',
        email: 'email@email.com',
        registrationAddress: 'Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1',
        city: 'Istanbul',
        country: 'Turkey',
        ip: '85.34.78.112');

    final basketItems = <BasketItem>[
      BasketItem(
          id: 'BI101',
          price: amountController.text,
          name: 'Binocular',
          category1: 'Collectibles',
          category2: 'Accessories',
          itemType: BasketItemType.PHYSICAL),
    ];


    final paymentResult = await iyzico.CreatePaymentRequest(
        price: price,
        paidPrice: paidPrice,
        paymentCard: paymentCard,
        buyer: buyer,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
        basketItems: basketItems);

    if (paymentResult.status == "success") {
      // Ödeme başarılı oldu.
      print("Ödeme başarılı. Ödeme ID: ${paymentResult.paymentId}");
      await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) async {
        await FirebaseFirestore.instance.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid).update({
          "money" : value["money"] + price,
          "by" : FirebaseAuth.instance.currentUser!.uid,
        });
      });
      await FirebaseFirestore.instance.collection("transactions").doc(paymentResult.paymentId).set(paymentResult.toJson());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(MainScreen.english ? "Succesfully added to your wallet" : "Cüzdana başarıyla eklendi", style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17.5, fontFamily: kFontFamily
        ),),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    } else {
      // Ödeme başarısız oldu.
      print("Ödeme başarısız oldu. Hata kodu: ${paymentResult.errorMessage}, ${paymentResult.errorCode}");


    }

    // final initializeThreeds = await iyzico.initializeThreedsPaymentRequest(
    //   price: price,
    //   paidPrice: paidPrice,
    //   paymentCard: paymentCard,
    //   buyer: buyer,
    //   shippingAddress: shippingAddress,
    //   billingAddress: billingAddress,
    //   basketItems: basketItems,
    //   callbackUrl: 'www.marufmarket.com',
    // );
    // //print(initializeThreeds);
    //
    // final createThreedsRequest = await iyzico.createThreedsPaymentRequest(
    //   paymentId: paymentResult.paymentId, locale: initializeThreeds.locale,
    //     conversationId: initializeThreeds.conversationId,
    //     paymentConversationId: paymentResult.conversationId);
    // //print(createThreedsRequest);

    // final initChecoutForm = await iyzico.initializeCheoutForm(
    //     price: price,
    //     paidPrice: paidPrice,
    //     paymentCard: paymentCard,
    //     buyer: buyer,
    //     shippingAddress: shippingAddress,
    //     billingAddress: billingAddress,
    //     basketItems: basketItems,
    //     callbackUrl: 'www.test.com',
    //     enabledInstallments: []);
    // //print(initChecoutForm);
    //
    // final retrieveCheckoutForm =
    // await iyzico.retrieveCheckoutForm(token: initChecoutForm.token);
    // print(retrieveCheckoutForm);

  }

}
