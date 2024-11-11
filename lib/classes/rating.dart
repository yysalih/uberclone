import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Rating extends Equatable {

  final String by;
  final String $for;
  final DateTime date;
  final double point;
  final String comment;
  final String uid;

  Rating({ required this.uid, required this.by, required this.$for, required this.point,
    required this.date, required this.comment});


  @override
  List<Object?> get props => [comment, uid, date, $for, point, by];

  static Rating fromSnapshot(DocumentSnapshot snapshot) {
    Rating address = Rating(
        by: snapshot["by"], uid: snapshot["uid"], point: snapshot["point"],
        $for: snapshot["for"], comment: snapshot["comment"], date: (snapshot["date"] as Timestamp).toDate(),

    );
    return address;
  }

  Map<String, Object> toDocument() {
    return {
      "date" : date, "by" : by, "point" : point,
      "comment" : comment, "uid" : uid, "for" : $for
      
    };
  }

}