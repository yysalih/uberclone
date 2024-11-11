import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Rent extends Equatable {


  final String uid;
  final String driver;
  final DateTime startdate;
  final DateTime enddate;
  final String passenger;
  final String city;
  final String county;
  final String status;
  final double amount;


  Rent({
    required this.uid, required this.driver,required this.passenger,
    required this.city, required this.status, required this.county,
    required this.startdate, required this.enddate, required this.amount
  });


  @override
  List<Object?> get props => [
     uid, driver, startdate, enddate, county,
     passenger, city, status, amount
  ];

  static Rent fromSnapshot(DocumentSnapshot snapshot) {
    Rent sentRequest = Rent(
      uid: snapshot["drive_uid"], driver: snapshot["driver_uid"],
      enddate: (snapshot["enddate"] as Timestamp).toDate(),
      startdate: (snapshot["startdate"] as Timestamp).toDate(),
      passenger: snapshot["passenger_uid"],
      city: snapshot["city"],
      county: snapshot["county"],
      status: snapshot["status"], amount: double.parse(snapshot["amount"].toString())
    );
    return sentRequest;
  }

  Map<String, Object> toDocument() {
    return {

      "drive_uid" : uid, "driver_uid" : driver, "enddate" : enddate, "startdate" : startdate,
      "passenger_uid" : passenger,
      "city" : city, "status" : status, "county" : county, "amount" : amount
    };
  }

}