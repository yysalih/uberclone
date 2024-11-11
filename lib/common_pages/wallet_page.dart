
import 'dart:convert';
import 'package:ebuber/common_pages/add_to_wallet_page.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:credit_card_type_detector/models.dart';
import 'package:ebuber/common_pages/add_wallet_page.dart';
import 'package:ebuber/main.dart';
import 'package:ebuber/utils/encryption_decryption.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ebuber/constant.dart';
import 'package:ebuber/passenger/screens/main_screen.dart';
import 'package:iyzico/iyzico.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';


class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {

  Map<String, dynamic> cards = {
    "types" : ["mastercard", "visa", "paypal", "add"], "numbers" : ["**** 9810", "**** 1604", "**** 3007", "add"]
  };

  int wallet = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final user = ref.watch(passengerStreamProvider(FirebaseAuth.instance.currentUser!.uid));
    final cards = ref.watch(cardsStreamProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: user.when(
            data: (passenger) => Container(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: width, height: height * .25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                          tileMode: TileMode.repeated,
                          colors: [kLightColors[8], kLightColors[2], kDarkColors[2]],
                          begin: Alignment.bottomRight, end: Alignment.topLeft
                      ),
                    ),
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(!MainScreen.english ? "Bakiyen:\n${passenger.money} TL" : "Your Balance:\n${passenger.money} \TL", style: TextStyle(
                                color: Colors.white, fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.bold
                            ),),
                            Text("${passenger.name}", style: TextStyle(color: Colors.white, fontFamily: kFontFamily, fontSize: 15),)
                          ],
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image.asset(!MainScreen.english ? "images/app/iyzicotr.png" : "images/app/iyzicoen.png",
                                fit: BoxFit.contain, width: width * .2,),
                              SizedBox(height: 0,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset("images/icons/mastercard.png", fit: BoxFit.contain,
                                    width: width * .075,),
                                  SizedBox(width: 0,),
                                  Image.asset("images/icons/visa.png", fit: BoxFit.contain, width: width * .075,),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: height * .05,),
                  Text(!MainScreen.english ? "Cüzdana Para Ekle" : "Add Money with", style: TextStyle(
                      color: kDarkColors[9], fontFamily: kFontFamily, fontSize: 17.5, fontWeight: FontWeight.bold
                  ),),
                  SizedBox(height: height * .025,),
                  CreditCard(width: width, height: height, type: "add", number: "", onTap: () {}),
                  cards.when(
                    loading: () => Center(child: CircularProgressIndicator(),),
                    error: (error, stackTrace) => Container(),
                    data: (cards) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: width, maxHeight: height * .48),
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            List<CreditCardType> cardType = detectCCType(EncryptionDecryption.decryptMessage(encrypt.Encrypted.fromBase64(cards[index].cardNumber)));



                            return CreditCard(width: width, height: height,
                                type: cardType.first.type, number: cards[index].cardAlias, onTap: () {
                              pay2();
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddToWalletPage(creditCard: cards[index]),));
                                });
                          },
                          itemCount: cards.length,
                        ),
                      );
                    }
                  ),

                ],
              ),
            ),
            error: (error, stackTrace) => Container(),
            loading: () => Center(child: CircularProgressIndicator(),),
          )
        ),
      ),
    );
  }

  pay() async {
    const iyziConfig = IyziConfig(
        'sandbox-6jbxQoyzLh8PehdsHRQ53tUVMVY1HMdP',
        'sandbox-SgOajkryxkWzfEw2YTmr97muhdf27eYy',
        'https://sandbox-api.iyzipay.com');

    //Create an iyzico object
    final iyzico = Iyzico.fromConfig(configuration: iyziConfig);

    // //requesting bin number
    // final binResult = await iyzico.retrieveBinNumberRequest(binNumber: '542119');
    // print(binResult);

    // //requesting Installment Info

    // final installmentResult =
    //     await iyzico.retrieveInstallmentInfoRequest(price: 10);
    // print(installmentResult);

    // final installmentResult2 = await iyzico.retrieveInstallmentInfoRequest(
    //     price: 10, binNumber: '542119');
    // print(installmentResult2);

    //Create Payment Request

    // ignore: omit_local_variable_types
    final double price = 100;
    // ignore: omit_local_variable_types
    final double paidPrice = 110;

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
          price: '0.3',
          name: 'Binocular',
          category1: 'Collectibles',
          category2: 'Accessories',
          itemType: BasketItemType.PHYSICAL),
      BasketItem(
          id: 'BI102',
          price: '0.5',
          name: 'Game code',
          category1: 'Game',
          category2: 'Online Game Items',
          itemType: BasketItemType.VIRTUAL),
      BasketItem(
          id: 'BI103',
          price: '0.2',
          name: 'Usb',
          category1: 'Electronics',
          category2: 'Usb / Cable',
          itemType: BasketItemType.PHYSICAL),
    ];
    final paymentResult = await iyzico.CreatePaymentRequest(
        price: 1.0,
        paidPrice: 1.1,
        paymentCard: paymentCard,
        buyer: buyer,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
        basketItems: basketItems);

    print(paymentResult);

    final initializeThreeds = await iyzico.initializeThreedsPaymentRequest(
      price: price,
      paidPrice: paidPrice,
      paymentCard: paymentCard,
      buyer: buyer,
      shippingAddress: shippingAddress,
      billingAddress: billingAddress,
      basketItems: basketItems,
      callbackUrl: 'www.marufmarket.com',
    );
    final createThreedsRequest = await iyzico.createThreedsPaymentRequest(
      conversationId: initializeThreeds.conversationId, locale: initializeThreeds.locale,
        paymentId: paymentResult.paymentId,
        paymentConversationId: paymentResult.conversationId);
    print(createThreedsRequest);

    final initChecoutForm = await iyzico.initializeCheoutForm(
        price: price,
        paidPrice: paidPrice,
        paymentCard: paymentCard,
        buyer: buyer,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
        basketItems: basketItems,
        callbackUrl: 'www.test.com',
        enabledInstallments: []);
    print(initChecoutForm);

    final retrieveCheckoutForm =
    await iyzico.retrieveCheckoutForm(token: 'token');
    print(retrieveCheckoutForm);

    // Initialize 3DS PAYMENT REQUEST

    /*final initializeThreeds = await iyzico.initializeThreedsPaymentRequest(
      price: price,
      paidPrice: paidPrice,
      paymentCard: paymentCard,
      buyer: buyer,
      shippingAddress: shippingAddress,
      billingAddress: billingAddress,
      currency: Currency.TRY,
      basketItems: basketItems,
      callbackUrl: 'www.marufmarket.com',
    ).then((value) {
      print(value.errorMessage);
    });

    print(initializeThreeds);*/
  }

  pay2() async {
    const iyziConfig = IyziConfig(
        'sandbox-6jbxQoyzLh8PehdsHRQ53tUVMVY1HMdP',
        'sandbox-SgOajkryxkWzfEw2YTmr97muhdf27eYy',
        'https://sandbox-api.iyzipay.com');

    //Create an iyzico object
    final iyzico = Iyzico.fromConfig(configuration: iyziConfig);

    final binResult = await iyzico.retrieveBinNumberRequest(binNumber: '542119');
    //print(binResult);

    final installmentResult = await iyzico.retrieveInstallmentInfoRequest(price: 10);
    //print(installmentResult);
    // OR
    final installmentResult2 = await iyzico.retrieveInstallmentInfoRequest(price: 10, binNumber: '542119');
    //print(installmentResult2);

    final double price = 1;
    final double paidPrice = 1.1;

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
          price: '0.3',
          name: 'Binocular',
          category1: 'Collectibles',
          category2: 'Accessories',
          itemType: BasketItemType.PHYSICAL),
      BasketItem(
          id: 'BI102',
          price: '0.5',
          name: 'Game code',
          category1: 'Game',
          category2: 'Online Game Items',
          itemType: BasketItemType.VIRTUAL),
      BasketItem(
          id: 'BI103',
          price: '0.2',
          name: 'Usb',
          category1: 'Electronics',
          category2: 'Usb / Cable',
          itemType: BasketItemType.PHYSICAL),
    ];


    final paymentResult = await iyzico.CreatePaymentRequest(
        price: 1.0,
        paidPrice: 1.1,
        paymentCard: paymentCard,
        buyer: buyer,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
        basketItems: basketItems);

    if (paymentResult.status == "success") {
      // Ödeme başarılı oldu.
      print("Ödeme başarılı. Ödeme ID: ${paymentResult.paymentId}");
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

  Future<void> makePayment(String token) async {
    final url = "https://sandbox-api.iyzipay.com/payment/auth"; // Test API URL
    String authorizationHeader = generateAuthorizationHeader("sandbox-6jbxQoyzLh8PehdsHRQ53tUVMVY1HMdP", "sandbox-SgOajkryxkWzfEw2YTmr97muhdf27eYy", token);

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "$authorizationHeader"
    };

    final body = json.encode({
      "paymentBody": {
        "paidPrice": "50.19",
        "enabledInstallments": [2, 3, 6, 9],
        "price": "50.19",
        "paymentGroup": "PRODUCT",
        "paymentSource": "MOBILE_SDK",
        "callbackUrl": "https://www.merchant.com/callback",
        "currency": "TRY",
        "basketId": "B67832",
        "buyer": {
          "id": "BY789",
          "name": "John",
          "surname": "Buyer",
          "identityNumber": "74300864791",
          "email": "john.buyer@mail.com",
          "gsmNumber": "+905555555555",
          "registrationAddress": "Adres",
          "city": "Istanbul",
          "country": "Turkey",
          "ip": "buyer Ip"
        },
        "shippingAddress": {
          "address": "Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1",
          "contactName": "John Buyer",
          "city": "Istanbul",
          "country": "Turkey"
        },
        "billingAddress": {
          "address": "Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1",
          "contactName": "John Buyer",
          "city": "Istanbul",
          "country": "Turkey"
        },
        "basketItems": [
          {
            "id": "BI101",
            "price": "50.19",
            "name": "Binocular",
            "category1": "Collectibles",
            "itemType": "PHYSICAL"
          }
        ],
        "mobileDeviceInfoDto": {
          "sdkVersion": "v1.0.1",
          "operatingSystemVersion": "iOS - 13",
          "model": "iPhone 10",
          "brand": "Apple"
        }
      },
      "thirdPartyClientId": "iyzico",
      "thirdPartyClientSecret": "iyzicoSecret",
      "merchantApiKey": "sandbox-6jbxQoyzLh8PehdsHRQ53tUVMVY1HMdP",
      "merchantSecretKey": "sandbox-SgOajkryxkWzfEw2YTmr97muhdf27eYy",
      "sdkType": "pwi"
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(responseData);
    } else {
      print("hata");
    }
  }

  String generateAuthorizationHeader(String apiKey, String secretKey, String requestDetails) {
    // İsteğinizin detaylarını birleştirin
    String rawData = apiKey + requestDetails;

    // Bu birleşik string üzerinde bir SHA-256 hash oluşturun
    var digest = sha256.convert(utf8.encode(rawData));

    // Bu hash'i API gizli anahtarınızla birleştirin
    String signature = "$digest$secretKey";

    // Nihai imzayı oluşturun
    var finalSignature = sha256.convert(utf8.encode(signature));

    return finalSignature.toString();
  }
}

class CreditCard extends StatelessWidget {
  const CreditCard({
    Key? key,
    required this.width,
    required this.height, required this.type, required this.number, required this.onTap,
  }) : super(key: key);

  final double width;
  final double height;
  final String type;
  final String number;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, height: height * .09,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: MaterialButton(
          color: kLightColors[7],
          onPressed: () {
            if(type == "add" ) Navigator.push(context, MaterialPageRoute(builder: (context) => AddWalletPage(),));
            else onTap();

          },

          child: type == "add" ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.add, color: Colors.black54, size: 17.5,),
                  SizedBox(width: 20,),
                  Text(!MainScreen.english ? "Yeni Kart Ekle" : "Add New Card", style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.bold,
                      fontFamily: kFontFamily, fontSize: 15),),
                ],
              ),

              Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 15,),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset("images/icons/$type.png", fit: BoxFit.contain, width: width * .075,),
                  SizedBox(width: 15,),
                  Text("$number", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold,
                      fontFamily: kFontFamily, fontSize: 15),),
                ],
              ),

              Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 15,),
            ],
          ),
        ),
      ),
      padding: EdgeInsets.only(bottom: 10),
    );
  }
}
