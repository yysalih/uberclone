import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/address.dart';
import 'package:ebuber/classes/driver.dart';
import 'package:ebuber/classes/passenger.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressRepository {
  final FirebaseFirestore _firebaseFirestore;
  final String _uid;

  AddressRepository({FirebaseFirestore? firebaseFirestore, String? uid})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance, _uid = uid ?? "";

  @override
  Stream<Address> getAddress() {
    return _firebaseFirestore.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("addresses").doc(_uid).snapshots()
        .map((event) => Address.fromSnapshot(event));
  }

  @override
  Stream<List<Address>> getAddresses() {
    return _firebaseFirestore.collection("passengers")
        .doc(FirebaseAuth.instance.currentUser!.uid).collection("addresses").snapshots().map((snapshot) {
      return snapshot.docs.map((e) => Address.fromSnapshot(e)).toList();
    });
  }



}