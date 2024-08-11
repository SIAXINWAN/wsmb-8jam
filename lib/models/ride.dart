import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsmb_day2_try8_jam/models/driver.dart';
import 'package:wsmb_day2_try8_jam/services/firestore1.dart';

class Ride {
  final DateTime date;
  final String origin;
  final String destination;
  final double fare;
  String? id;
  String? driver_id;
  List<String> riders;
  List<String> likedBy;
  List<String> joinedRiders;
  List<DocumentReference> vehicle;
  List<Comment>? comments;  // Make this nullable

  Ride({
    required this.date,
    required this.origin,
    required this.destination,
    required this.fare,
    this.id,
    this.driver_id,
    List<String>? riders,
    List<String>? likedBy,
    List<String>? joinedRiders,
    List<DocumentReference>? vehicle,
    this.comments,  // Add this line
  })  : riders = riders ?? [],
        likedBy = likedBy ?? [],
        joinedRiders = joinedRiders ?? [],
        vehicle = vehicle ?? [];


  static Future<bool> registerRide(
      DateTime masa, double duit, String tempat, String sampai, List<String> orang) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString('token');
    if (token == null) {
      return false;
    }
    Ride ride = Ride(
      driver_id: token,
      date: masa,
      origin: tempat,
      destination: sampai,
      fare: duit,
      riders: orang,
    );

    var res = await FirestoreService11.addRide(ride);
    return res;
  }

  factory Ride.fromJson(Map<String, dynamic> json, [String? rid]) {
    return Ride(
      id: rid,
      driver_id: json['driver_id'] ?? '',
      date: DateTime.parse(json['date']),
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      riders: (json['riders'] as List<dynamic>?)?.map((x) => x.toString()).toList() ?? [],
      likedBy: (json['likedBy'] as List<dynamic>?)?.map((x) => x.toString()).toList() ?? [],
      joinedRiders: (json['joinedRiders'] as List<dynamic>?)?.map((x) => x.toString()).toList() ?? [],
      vehicle: (json['vehicle'] as List<dynamic>?)?.map((x) => x as DocumentReference).toList() ?? [],
      fare: json['fare'] as double,
       comments: (json['comments'] as List<dynamic>?)
          ?.map((x) => Comment.fromJson(x as Map<String, dynamic>))
          .toList(), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driver_id,
      'date': date.toString(),
      'origin': origin,
      'destination': destination,
      'fare': fare,
      'riders': riders,
      'likedBy': likedBy,
      'joinedRiders': joinedRiders,
      'vehicle': vehicle,
      'comments': comments?.map((x) => x.toJson()).toList(), 
    };
  }

  Future<Driver?> getDriver() async {
    if (driver_id == null) {
      return null;
    }
    var driver = await FirestoreService11.getDriver(driver_id!);
    return driver;
  }

  
}

class Comment {
  final String riderId;
  final String comment;
  final DateTime? timestamp;  // Make this nullable

  Comment({required this.riderId, required this.comment, this.timestamp});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      riderId: json['riderId'],
      comment: json['comment'],
      timestamp: (json['timestamp'] as Timestamp?)?.toDate(),  // Handle nullable Timestamp
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'riderId': riderId,
      'comment': comment,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
    };
  }
}