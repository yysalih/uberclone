import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RecentDrive extends Equatable {

  final double amount;
  final String destinationFullAddress;
  final double distance;
  final String drive_uid;
  final String driver_uid;
  final DateTime enddate;
  final List from;
  final String note;
  final String passenger_uid;
  final int passengers_count;
  final String placeToGo;
  final double point;
  final DateTime startdate;
  final String status;
  final List to;
  final bool bookednow;


  RecentDrive({
    required this.amount, required this.destinationFullAddress, required this.distance,
    required this.drive_uid, required this.driver_uid, required this.enddate,
    required this.startdate,
    required this.from, required this.note, required this.passenger_uid, required this.passengers_count,
    required this.placeToGo, required this.point, required this.status, required this.to,
    required this.bookednow
  });


  @override
  List<Object?> get props => [
    amount, destinationFullAddress, distance, drive_uid, driver_uid, enddate, startdate, from,
    note, passenger_uid, passengers_count, placeToGo, point, status, to, bookednow
  ];

  static RecentDrive fromSnapshot(DocumentSnapshot snapshot) {
    RecentDrive passenger = RecentDrive(
      amount: snapshot["amount"], destinationFullAddress: snapshot["destinationFullAddress"],
      distance: snapshot["distance"], drive_uid: snapshot["drive_uid"], driver_uid: snapshot["driver_uid"],
      enddate: (snapshot["enddate"] as Timestamp).toDate(), startdate: (snapshot["startdate"] as Timestamp).toDate(),
      from: snapshot["from"], note: snapshot["note"], passenger_uid: snapshot["passenger_uid"],
      passengers_count: snapshot["passengers_count"], placeToGo: snapshot["placeToGo"],
      point: snapshot["point"], status: snapshot["status"], to: snapshot["to"],
        bookednow: snapshot["bookednow"]
    );
    return passenger;
  }

  Map<String, Object> toDocument() {
    return {
      "amount" : amount, "destinationFullAddress" : destinationFullAddress, "distance" : distance,
      "drive_uid" : drive_uid, "driver_uid" : driver_uid, "enddate" : enddate, "startdate" : startdate,
      "from" : from, "note" : note, "passenger_uid" : passenger_uid, "passengers_count" : passengers_count,
      "placeToGo" : placeToGo, "point" : point, "status" : status, "to" : to, "bookednow" : bookednow
    };
  }

}