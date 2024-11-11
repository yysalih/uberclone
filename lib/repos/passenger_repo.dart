import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebuber/classes/passenger.dart';

class PassengerRepository {
  final FirebaseFirestore _firebaseFirestore;
  final String _uid;

  PassengerRepository({FirebaseFirestore? firebaseFirestore, String? uid})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance, _uid = uid ?? "";

  @override
  Stream<Passenger> getPassenger() {
    return _firebaseFirestore.collection("passengers").doc(_uid).snapshots()
        .map((event) => Passenger.fromSnapshot(event));
  }

  @override
  Stream<List<Passenger>> getPassengers() {
    return _firebaseFirestore.collection("passengers").snapshots().map((snapshot) {
      return snapshot.docs.map((e) => Passenger.fromSnapshot(e)).toList();
    });
  }



}