import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/address.dart';
import 'package:ebuber/classes/driver.dart';
import 'package:ebuber/classes/passenger.dart';
import 'package:ebuber/classes/sentrequest.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../classes/activedriver.dart';

class ActiveDriveRepository {
  final String _driver_uid;
  final String _uid;

  ActiveDriveRepository({String? driveruid, String? uid})
      : _driver_uid = driveruid ?? "", _uid = uid ?? "";

  @override
  Stream<ActiveDrive> getActiveDrive() {
    return FirebaseFirestore.instance.collection("drivers").doc(_driver_uid)
        .collection("activedrive").doc(_uid).snapshots()
        .map((event) => ActiveDrive.fromSnapshot(event));
  }

  @override
  Stream<List<ActiveDrive>> getActiveDrives() {
    return FirebaseFirestore.instance.collection("drivers")
        .doc(_driver_uid).collection("activedrive").snapshots().map((snapshot) {
      return snapshot.docs.map((e) => ActiveDrive.fromSnapshot(e)).toList();
    });
  }



}