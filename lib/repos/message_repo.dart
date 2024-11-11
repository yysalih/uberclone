import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/address.dart';
import 'package:ebuber/classes/driver.dart';
import 'package:ebuber/classes/message.dart';
import 'package:ebuber/classes/passenger.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageRepository {
  final FirebaseFirestore _firebaseFirestore;
  final String _uid;

  MessageRepository({FirebaseFirestore? firebaseFirestore, String? uid})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance, _uid = uid ?? "";


  @override
  Stream<List<Message>> getMessages() {
    return _firebaseFirestore.collection('passengers')
        .doc(FirebaseAuth.instance.currentUser!.uid).collection("messages").doc(_uid)
        .collection('chats')
        .orderBy("time", descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((e) => Message.fromSnapshot(e)).toList();
    });
  }



}