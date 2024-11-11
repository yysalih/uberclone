import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/address.dart';
import 'package:ebuber/classes/driver.dart';
import 'package:ebuber/classes/passenger.dart';
import 'package:ebuber/classes/sentrequest.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SentRequestRepository {
  final FirebaseFirestore _firebaseFirestore;
  final String _uid;

  SentRequestRepository({FirebaseFirestore? firebaseFirestore, String? uid})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance, _uid = uid ?? "";

  @override
  Stream<SentRequest> getSentRequest() {
    return _firebaseFirestore.collection("passengers").doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("sentrequests").doc(_uid).snapshots()
        .map((event) => SentRequest.fromSnapshot(event));
  }

  @override
  Stream<List<SentRequest>> getSentRequests() {
    return _firebaseFirestore.collection("passengers")
        .doc(FirebaseAuth.instance.currentUser!.uid).collection("sentrequests").snapshots().map((snapshot) {
      return snapshot.docs.map((e) => SentRequest.fromSnapshot(e)).toList();
    });
  }



}