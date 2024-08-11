import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsmb_day2_try8_jam/services/firestore1.dart';

class Driver {
  String? id;
  final String name;
  final String icno;
  final bool gender;
  final String phone;
  final String email;
  final String address;
  String? password;
  String? photo;

  Driver(
      {this.id,
      required this.name,
      required this.icno,
      required this.gender,
      required this.phone,
      required this.email,
      required this.address,
      this.photo});

  static Future<Driver?> register(
      Driver driver, String password, File image) async {
    if (await FirestoreService11.isDuplicated(driver)) {
      return null;
    }

    var byte = utf8.encode(password);
    var hashedPassword = sha256.convert(byte).toString();

    driver.password = hashedPassword;

    String fileName = 'images/${DateTime.now().microsecondsSinceEpoch}.jpg';
    UploadTask uploadTask =
        FirebaseStorage.instance.ref(fileName).putFile(image!);
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();
    driver.photo = downloadURL;

    var newDriver = await FirestoreService11.addDriver(driver);
    if (newDriver == null) {
      return null;
    }
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', driver.id.toString());
    return newDriver;
  }

  static Future<Driver?> login(String ic, String password) async {
    var byte = utf8.encode(password);
    var hashedPassword = sha256.convert(byte).toString();

    var driver = await FirestoreService11.loginDriver(ic, hashedPassword);
    if (driver == null) {
      return null;
    }

    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', driver.id.toString());
    return driver;
  }

  static Future<String> getToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString('token');
    if (token == null) {
      return '';
    }
    return token;
  }

  static Future<Driver?> getDriverByToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var token = pref.getString('token');
    if (token == null) {
      return null;
    }

    var driver = await FirestoreService11.validateTokenDriver(token);
    return driver;
  }

  static Future<bool> signOut() async {
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

  factory Driver.fromJson(Map<String, dynamic> json, [String? id]) {
    return Driver(
      id: id ?? json['id'] ?? '',
      name: json['name'] ?? '',
      icno: json['icno'] ?? '',
      gender: json['gender'] as bool,
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      photo: json['photo'],
    );
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
