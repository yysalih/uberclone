import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Passenger extends Equatable {

  final bool banned;
  final String email;
  final bool emailapproved;
  final bool femaleoption;
  final String gender;
  final List latlng;
  final String name;
  final String phone;
  final double point;
  final double money;
  final String uid;
  final String token;
  final String photo;

  Passenger({
    required this.banned, required this.email, required this.point,
    required this.latlng, required this.name, required this.phone, required this.emailapproved,
    required this.uid, required this.femaleoption, required this.gender,
  required this.token, required this.photo, required this.money});


  @override
  List<Object?> get props => [banned, email, token, money,
    latlng, name, phone, point, uid, emailapproved, femaleoption, gender, photo];

  static Passenger fromSnapshot(DocumentSnapshot snapshot) {
    Passenger passenger = Passenger(banned: snapshot["banned"], email: snapshot["email"],
        latlng: snapshot["latlng"], name: snapshot["name"],
        phone: snapshot["phone"], point: double.parse(snapshot["point"].toString()),
        token: snapshot["token"], uid: snapshot["uid"],
       emailapproved: snapshot["emailapproved"], money: double.parse(snapshot["money"].toString()),
      femaleoption: snapshot["femaleoption"], gender: snapshot["gender"], photo: snapshot["photo"]
    );
    return passenger;
  }

  Map<String, Object> toDocument() {
    return {
      "banned" : banned, "email" : email,
      "latlng" : latlng, "name" : name,
      "phone" : phone, "point" : point, "token" : token, "uid" : uid,
      "emailapproved" : emailapproved, "money" : money,
      "femaleoption" : femaleoption, "gender" : gender, "photo" : photo,
    };
  }

}