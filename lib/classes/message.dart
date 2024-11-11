import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Message extends Equatable {

  final String message;
  final String sendby;
  final DateTime time;

  Message({required this.sendby, required this.message, required this.time});


  @override
  List<Object?> get props => [sendby, message, time];

  static Message fromSnapshot(DocumentSnapshot snapshot) {
    Message message = Message(
        sendby: snapshot["sendby"], time: (snapshot["time"] as Timestamp).toDate(),
      message: snapshot["message"],
    );
    return message;
  }

  Map<String, Object> toDocument() {
    return {
      "message" : message, "sendby" : sendby, "time" : time
      
    };
  }

}