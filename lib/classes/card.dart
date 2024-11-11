import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Card extends Equatable {

  final String cardAlias;
  final String expire;
  final String cvc;
  final String uid;
  final String cardNumber;
  final String cardHolderName;

  Card({
    required this.uid, required this.cardAlias,
    required this.cvc, required this.expire, required this.cardHolderName, required this.cardNumber});


  @override
  List<Object?> get props => [uid, expire, cvc, cardAlias, cardHolderName, cardNumber];

  static Card fromSnapshot(DocumentSnapshot snapshot) {
    Card address = Card(
        uid: snapshot["uid"], expire: snapshot["expire"],
        cardAlias: snapshot["cardAlias"], cvc: snapshot["cvc"], cardHolderName: snapshot["cardHolderName"],
      cardNumber: snapshot["cardNumber"]
    );
    return address;
  }

  Map<String, Object> toDocument() {
    return {
      "cardAlias" : cardAlias, "cvc" : cvc, "expire" : expire,
      "uid" : uid, "cardHolderName" : cardHolderName,
      "cardNumber" : cardNumber

    };
  }

}