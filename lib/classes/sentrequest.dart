import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SentRequest extends Equatable {

  final String destinationFullAddress;
  final double distance;
  final double money;

  final String drive_uid;
  final String driver_uid;
  final DateTime date;
  final List from;
  final String note;
  final String passenger_uid;
  final int passengers_count;
  final String placeToGo;
  final double point;
  final String status;
  final List to;
  final bool hasfinished;
  final bool hasmet;
  final bool bookednow;


  SentRequest({ required this.destinationFullAddress, required this.distance,
    required this.drive_uid, required this.driver_uid, required this.date,
    required this.hasfinished, required this.hasmet,
    required this.from, required this.note, required this.passenger_uid, required this.passengers_count,
    required this.placeToGo, required this.point, required this.status, required this.to,
    required this.bookednow, required this.money
  });


  @override
  List<Object?> get props => [
    destinationFullAddress, distance, drive_uid, driver_uid, date, hasfinished, hasmet,from,
    note, passenger_uid, passengers_count, placeToGo, point, status, to, bookednow, money
  ];

  static SentRequest fromSnapshot(DocumentSnapshot snapshot) {
    SentRequest sentRequest = SentRequest(
        hasfinished: snapshot["hasfinished"], hasmet: snapshot["hasmet"],
        destinationFullAddress: snapshot["destinationFullAddress"],
        distance: snapshot["distance"], drive_uid: snapshot["drive_uid"], driver_uid: snapshot["driver_uid"],
        date: (snapshot["date"] as Timestamp).toDate(),
        from: snapshot["from"], note: snapshot["note"], passenger_uid: snapshot["passenger_uid"],
        passengers_count: snapshot["passengers_count"], placeToGo: snapshot["placeToGo"],
        point: snapshot["point"], status: snapshot["status"], to: snapshot["to"],
        bookednow: snapshot["bookednow"], money: double.parse(snapshot["money"].toString())
    );
    return sentRequest;
  }

  Map<String, Object> toDocument() {
    return {
      "hasfinished" : hasfinished, "hasmet" : hasmet,
      "destinationFullAddress" : destinationFullAddress, "distance" : distance,
      "drive_uid" : drive_uid, "driver_uid" : driver_uid, "date" : date,
      "from" : from, "note" : note, "passenger_uid" : passenger_uid, "passengers_count" : passengers_count,
      "placeToGo" : placeToGo, "point" : point, "status" : status, "to" : to,
      "bookednow" : bookednow, "money" : money
    };
  }

}