import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Driver extends Equatable {

  final bool approved;
  final Map<String, dynamic> car;
  final String email;
  final bool emailapproved;
  final bool busy;
  final bool femaleoption;
  final String gender;
  final List latlng;
  final String name;
  final String phone;
  final double point;
  final String uid;
  final String token;
  final String photo;
  final double money;

  Driver({required this.busy, required this.car,
    required this.approved, required this.email, required this.point,
    required this.latlng, required this.name, required this.phone, required this.emailapproved,
    required this.uid, required this.femaleoption, required this.gender, required this.money,
  required this.token, required this.photo});


  @override
  List<Object?> get props => [approved, email, token, busy, car, money,
    latlng, name, phone, point, uid, emailapproved, femaleoption, gender, photo];

  static Driver fromSnapshot(DocumentSnapshot snapshot) {
    Driver driver = Driver(approved: snapshot["approved"], email: snapshot["email"],
        busy: snapshot["busy"], car: snapshot["car"],
        latlng: snapshot["latlng"], name: snapshot["name"],
        phone: snapshot["phone"], point: double.parse(snapshot["point"].toString()),
        token: snapshot["token"], uid: snapshot["uid"],
       emailapproved: snapshot["emailapproved"],money: double.parse(snapshot["money"].toString()),
      femaleoption: snapshot["femaleoption"], gender: snapshot["gender"], photo: snapshot["photo"]
    );
    return driver;
  }

  Map<String, Object> toDocument() {
    return {
      "approved" : approved, "email" : email,
      "latlng" : latlng, "name" : name, "car" : car,
      "phone" : phone, "point" : point, "token" : token, "uid" : uid,
      "emailapproved" : emailapproved, "busy" : busy, "money" : money,
      "femaleoption" : femaleoption, "gender" : gender, "photo" : photo,
    };
  }

}