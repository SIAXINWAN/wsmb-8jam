import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsmb_day2_try8_jam/services/firestoreService.dart';

class Rider {
  String? id;
  final String name;
  final String icno;
  final bool gender;
  final String phone;
  final String email;
  final String address;
  String? password;
  String? photo;

  Rider(
      {this.id,
      this.photo,
      this.password,
      required this.name,
      required this.icno,
      required this.gender,
      required this.phone,
      required this.email,
      required this.address});

  static Future<Rider?> register(
      Rider rider, String? password, File image) async {
    try {
      if (await FirestoreService.isDuplicated(rider)) {
        return null;
      }

      var byte = utf8.encode(password!);
      var hashedPassword = sha256.convert(byte).toString();

      rider.password = hashedPassword;

      String fileName = 'riders/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask =
          FirebaseStorage.instance.ref(fileName).putFile(image!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();
      rider.photo = downloadURL;

      var newRider = await FirestoreService.addRider(rider);
      if (newRider == null) {
        return null;
      }

      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString('token', rider.id.toString());
      return newRider;
    } catch (e) {
      print('Error${e}');
    }
  }

  static Future<Rider?> login(String ic, String password) async {
    var byte = utf8.encode(password);
    var hashedPassword = sha256.convert(byte).toString();

    var rider = await FirestoreService.loginRider(ic, hashedPassword);
    if (rider == null) {
      return null;
    }
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', rider.id.toString());
    return rider;
  }

  static Future<String> getToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('token');
    if (token == null) {
      return '';
    }
    return token;
  }

  static Future<Rider?>getRiderByToken()async{
    SharedPreferences pref  = await SharedPreferences.getInstance();
    var token = pref.getString('token');
    if(token ==null){
      return null;
    }

    var rider = await FirestoreService.validateTokenRider(token);
    return rider;
  }

  static Future<bool>signOut()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var logout = await pref.remove('token');

    return logout;
  }

   static Future<String> saveImage(File image) async {
    String fileName = 'images/${DateTime.now().microsecondsSinceEpoch}.jpg';
    UploadTask uploadTask =
        FirebaseStorage.instance.ref(fileName).putFile(image!);
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  }

  factory Rider.fromJson(Map<String, dynamic> json, [String? id,String? password]) {
    return Rider(
      password: password,
        id: id,
        name: json['name'] ?? '',
        icno: json['icno'] ?? '',
        gender: json['gender'] as bool,
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        address: json['address'] ?? '',
        photo: json['photo'] ?? '');
  }

  toJson() {
    return {
      'name': name,
      'icno': icno,
      'gender': gender,
      'phone': phone,
      'email': email,
      'address': address,
      'password': password,
      'photo': photo
    };
  }
}
