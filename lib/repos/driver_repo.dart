import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/driver.dart';
import 'package:ebuber/classes/passenger.dart';

class DriverRepository {
  final FirebaseFirestore _firebaseFirestore;
  final String _uid;

  DriverRepository({FirebaseFirestore? firebaseFirestore, String? uid})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance, _uid = uid ?? "";

  @override
  Stream<Driver> getDriver() {
    return _firebaseFirestore.collection("drivers").doc(_uid).snapshots()
        .map((event) => Driver.fromSnapshot(event));
  }

  @override
  Stream<List<Driver>> getDrivers() {
    return _firebaseFirestore.collection("drivers").snapshots().map((snapshot) {
      return snapshot.docs.map((e) => Driver.fromSnapshot(e)).toList();
    });
  }



}