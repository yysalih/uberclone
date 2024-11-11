import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/address.dart';
import 'package:ebuber/classes/driver.dart';
import 'package:ebuber/classes/passenger.dart';
import 'package:ebuber/classes/recentdrive.dart';
import 'package:ebuber/classes/sentrequest.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../classes/rent.dart';

class RentRepository {
  final FirebaseFirestore _firebaseFirestore;
  final String _uid;

  RentRepository({FirebaseFirestore? firebaseFirestore, String? uid})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance, _uid = uid ?? "";

  @override
  Stream<Rent> getRent() {
    return _firebaseFirestore.collection("rents").doc(_uid).snapshots()
        .map((event) => Rent.fromSnapshot(event));
  }

  @override
  Stream<List<Rent>> getRents() {
    return _firebaseFirestore.collection("rents").where("passenger_uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots().map((snapshot) {
      return snapshot.docs.map((e) => Rent.fromSnapshot(e)).toList();
    });
  }



}