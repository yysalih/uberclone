import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/address.dart';
import 'package:ebuber/classes/driver.dart';
import 'package:ebuber/classes/passenger.dart';
import 'package:ebuber/classes/sentrequest.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../classes/rating.dart';

class RatingRepository {
  final FirebaseFirestore _firebaseFirestore;
  final String _uid;

  RatingRepository({FirebaseFirestore? firebaseFirestore, String? uid})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance, _uid = uid ?? "";

  @override
  Stream<Rating> getRating() {
    return _firebaseFirestore.collection("passengers").doc(_uid).snapshots()
        .map((event) => Rating.fromSnapshot(event));

  }

  @override
  Stream<List<Rating>> getRatings() {
    return _firebaseFirestore.collection("drivers")
        .doc(_uid).collection("ratings").snapshots().map((snapshot) {
      return snapshot.docs.map((e) => Rating.fromSnapshot(e)).toList();
    });
  }



}