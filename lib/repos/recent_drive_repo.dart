import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/address.dart';
import 'package:ebuber/classes/driver.dart';
import 'package:ebuber/classes/passenger.dart';
import 'package:ebuber/classes/recentdrive.dart';
import 'package:ebuber/classes/sentrequest.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecentDriveRepository {
  final FirebaseFirestore _firebaseFirestore;
  final String _uid;

  RecentDriveRepository({FirebaseFirestore? firebaseFirestore, String? uid})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance, _uid = uid ?? "";

  @override
  Stream<RecentDrive> getRecentDrive() {
    return _firebaseFirestore.collection("recentdrives").doc(_uid).snapshots()
        .map((event) => RecentDrive.fromSnapshot(event));
  }

  @override
  Stream<List<RecentDrive>> getRecentDrives() {
    return _firebaseFirestore.collection("recentdrives").where("passenger_uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots().map((snapshot) {
      return snapshot.docs.map((e) => RecentDrive.fromSnapshot(e)).toList();
    });
  }



}