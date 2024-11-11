import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/driver.dart';
import 'package:ebuber/classes/passenger.dart';

class AppRepository {
  final FirebaseFirestore _firebaseFirestore;
  final String _uid;

  AppRepository({FirebaseFirestore? firebaseFirestore, String? uid})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance, _uid = uid ?? "";

  @override
  Stream<int> getStartHour() {
    return _firebaseFirestore.collection("app").doc("hours").snapshots()
        .map((event) => event.data()!["start"]);
  }
  @override
  Stream<int> getEndHour() {
    return _firebaseFirestore.collection("app").doc("hours").snapshots()
        .map((event) => event.data()!["end"]);
  }

  @override
  Stream<int> getDriveKm() {
    return _firebaseFirestore.collection("app").doc("prices").snapshots()
        .map((event) => event.data()!["drivekm"]);
  }
  @override
  Stream<int> getRentDayPrice() {
    return _firebaseFirestore.collection("app").doc("prices").snapshots()
        .map((event) => event.data()!["rentday"]);
  }



}