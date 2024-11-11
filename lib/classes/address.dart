import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Address extends Equatable {

  final String description;
  final List latlng;
  final String note;
  final String title;
  final String uid;

  Address({
    required this.latlng, required this.uid, required this.description,
  required this.title, required this.note});


  @override
  List<Object?> get props => [latlng, uid, note, title, description];

  static Address fromSnapshot(DocumentSnapshot snapshot) {
    Address address = Address(
        latlng: snapshot["latlng"], uid: snapshot["uid"], note: snapshot["note"],
      description: snapshot["description"], title: snapshot["title"]
    );
    return address;
  }

  Map<String, Object> toDocument() {
    return {
      "description" : description, "title" : title, "note" : note,
      "latlng" : latlng, "uid" : uid,
      
    };
  }

}