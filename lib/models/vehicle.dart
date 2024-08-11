import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wsmb_day2_try8_jam/services/firestore1.dart';



class Vehicle {
  final String car_model;
  final int capacity;
  final String driver_id;
  final String special_feature;
  String? image;
  String? id;

  Vehicle(
      {this.image,
      this.id,
      required this.car_model,
      required this.capacity,
      required this.driver_id,
      required this.special_feature});

      static Future<bool>registerVehicle(String model,
      int capacity,String feature, File?image)async{
        SharedPreferences pref= await SharedPreferences.getInstance();
        var token = pref.getString('token');
        if(token ==null){
          return false;
        }
        String imageLink = '';
        if(image!=null){
          String fileName = 'vehicle/${DateTime.now().microsecondsSinceEpoch}.jpg';
          UploadTask uploadTask =
          FirebaseStorage.instance.ref(fileName).putFile(image!);
          TaskSnapshot snapshot = await uploadTask;
          String downloadURL = await snapshot.ref.getDownloadURL();
          imageLink = downloadURL;
        }

        Vehicle vehicle = Vehicle(
          car_model: model, 
          capacity: capacity, 
          driver_id: token, 
          special_feature: feature,
          image:imageLink);

          var res = await FirestoreService11.addVehicle(vehicle);
          return res;
      }

      static Future<String> saveImage(File image)async{
        String fileName = 'vehicle/${DateTime.now().microsecondsSinceEpoch}.jpg';
        UploadTask uploadTask =
        FirebaseStorage.instance.ref(fileName).putFile(image);
        TaskSnapshot snapshot = await uploadTask;
        String downloadURL = await snapshot.ref.getDownloadURL();
        return downloadURL;
      }
      factory Vehicle.fromJson(Map<String,dynamic>json,String vid){
        return Vehicle(
          id: vid,
          car_model: json['car_model']??'',
           capacity: json['capacity']??0, 
           driver_id: json['driver_id']??'', 
           special_feature: json['special_feature']??'None',
           image: json['image']??'');
      }

      toJson(){
        return{
          'id':id,
          'car_model':car_model,
          'capacity':capacity,
          'driver_id':driver_id,
          'special_feature':special_feature,
          'image':image
        };
      }
}
