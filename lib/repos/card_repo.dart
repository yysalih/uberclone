import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/address.dart';
import 'package:ebuber/classes/driver.dart';
import 'package:ebuber/classes/passenger.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../classes/card.dart';

class CardRepository {
  final FirebaseFirestore _firebaseFirestore;
  final String _uid;

  CardRepository({FirebaseFirestore? firebaseFirestore, String? uid})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance, _uid = uid ?? "";

  @override
  Stream<Card> getCard() {
    return _firebaseFirestore.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("cards").doc(_uid).snapshots()
        .map((event) => Card.fromSnapshot(event));
  }

  @override
  Stream<List<Card>> getCards() {
    return _firebaseFirestore.collection("passengers")
        .doc(FirebaseAuth.instance.currentUser!.uid).collection("cards").snapshots().map((snapshot) {
      return snapshot.docs.map((e) => Card.fromSnapshot(e)).toList();
    });
  }



}