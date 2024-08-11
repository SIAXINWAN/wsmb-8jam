import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wsmb_day2_try8_jam/models/rider.dart';
import 'package:wsmb_day2_try8_jam/services/firestoreService.dart';
import 'package:wsmb_day2_try8_jam/widgets/bottomSheet.dart';

class EditRiderPage extends StatefulWidget {
  const EditRiderPage({super.key, required this.rider});
  final Rider rider;

  @override
  State<EditRiderPage> createState() => _EditRiderPageState();
}

class _EditRiderPageState extends State<EditRiderPage> {
  final nameController = TextEditingController();
  final icnoController = TextEditingController();
  String gender = 'male';
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  File? photo;
  bool changePassword = false;

  void genderChanged(String? value) {
    setState(() {
      gender = value!;
    });
  }

  void submitForm() async {
    if (photo != null) {
      widget.rider.photo = await Rider.saveImage(photo!);
    }
    if (formKey.currentState!.validate()) {
      Rider r = Rider(
          name: nameController.text,
          icno: widget.rider.icno,
          gender: gender == 'male',
          phone: widget.rider.phone,
          email: widget.rider.email,
          address: addressController.text,
          photo: widget.rider.photo);

      bool res;
      if (changePassword) {
        res = await changePasswordAndUpdateRider(r);
      } else {
        res = await FirestoreService.updateRider(r, widget.rider.id!);
      }

      if (res) {
        await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Success'),
                  content: Text('Your profile is edited successfully'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'))
                  ],
                ));
        Navigator.of(context).pop();
      } else {
        await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Warning'),
                  content: Text('Something went wrong'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'))
                  ],
                ));
      }
    }
  }

  Future<bool> changePasswordAndUpdateRider(Rider r) async {
    // Here you would typically verify the current password with your backend
    // For this example, we'll assume it's correct if it matches the placeholder
    if (currentPasswordController.text != 'placeholder_current_password') {
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Error'),
                content: Text('Current password is incorrect'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'))
                ],
              ));
      return false;
    }

    if (newPasswordController.text != confirmNewPasswordController.text) {
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Error'),
                content: Text('New passwords do not match'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'))
                ],
              ));
      return false;
    }

    // Update the rider's password in your authentication system here
    // For this example, we'll just assume it's successful
    bool passwordUpdateSuccess = true;

    if (passwordUpdateSuccess) {
      return await FirestoreService.updateRider(r, widget.rider.id!);
    } else {
      return false;
    }
  }

  Future<void> takePhoto(BuildContext context) async {
    ImageSource? source = await showModalBottomSheet(
        context: context, builder: (context) => bottomSheet(context));

    if (source == null) {
      return;
    }

    ImagePicker picker = ImagePicker();
    var file = await picker.pickImage(source: source);
    if (file == null) {
      return;
    }

    photo = File(file.path);
    setState(() {});
  }

  Widget displayImage() {
    if (photo != null) {
      return Image.file(
        photo!,
        fit: BoxFit.cover,
        height: 100,
        width: double.infinity,
      );
    } else if (widget.rider.photo != null && widget.rider.photo!.isNotEmpty) {
      return Image.network(
        widget.rider.photo!,
        fit: BoxFit.cover,
        height: 100,
        width: double.infinity,
      );
    } else {
      return Container(
        height: 100,
        width: double.infinity,
        color: Colors.grey[300],
        child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.rider.name;
    icnoController.text = widget.rider.icno;
    phoneController.text = widget.rider.phone;
    emailController.text = widget.rider.email;
    addressController.text = widget.rider.address;
    gender = widget.rider.gender ? 'male' : 'female';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Expanded(
            child: SingleChildScrollView(
                child: Column(children: [
          SizedBox(
            height: 40,
          ),
          Center(
            child: Text(
              'Rider Information',
              style: TextStyle(
                  fontSize: 24,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: formKey,
                  child: Column(children: [
                    CircleAvatar(
                      radius: 50,
                      child: ClipOval(child: displayImage()),
                    ),
                    OutlinedButton(
                        onPressed: () {
                          takePhoto(context);
                        },
                        child: Container(
                            width: double.infinity,
                            child: Center(child: Text('Change Photo')))),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      controller: nameController,
                      decoration:
                          InputDecoration(label: Center(child: Text('Name'))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: icnoController,
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      decoration:
                          InputDecoration(label: Center(child: Text('IC NO'))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your ic number';
                        } else if (value.length != 12 ||
                            int.tryParse(value) == null) {
                          return 'Please enter a valid ic number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Gender : '),
                        Radio(
                            value: 'male',
                            groupValue: gender,
                            onChanged: genderChanged),
                        Text('Male'),
                        Radio(
                            value: 'female',
                            groupValue: gender,
                            onChanged: genderChanged),
                        Text('Female'),
                      ],
                    ),
                    TextFormField(
                      controller: phoneController,
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          label: Center(child: Text('Phone Number'))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        } else if (int.tryParse(value) == null) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: emailController,
                      readOnly: true,
                      decoration:
                          InputDecoration(label: Center(child: Text('Email'))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                          label: Center(child: Text('Address'))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }

                        return null;
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    CheckboxListTile(
                      title: Text("Change Password"),
                      value: changePassword,
                      onChanged: (newValue) {
                        setState(() {
                          changePassword = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    if (changePassword) ...[
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            label: Center(child: Text('Current Password'))),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            label: Center(child: Text('New Password'))),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your new password';
                          } else if (value.length < 6) {
                            return 'Please enter a strong password';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: confirmNewPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            label: Center(child: Text('Confirm New Password'))),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          } else if (value != newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                    SizedBox(
                      height: 40,
                    ),
                    ElevatedButton(onPressed: submitForm, child: Text('Save'))
                  ])))
        ]))));
  }
}
