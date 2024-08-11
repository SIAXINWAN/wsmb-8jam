import 'package:flutter/material.dart';
import 'package:wsmb_day2_try8_jam/models/ride.dart';
import 'package:wsmb_day2_try8_jam/models/rider.dart';
import 'package:wsmb_day2_try8_jam/pages/homePage.dart';
import 'package:wsmb_day2_try8_jam/pages/personaPage.dart';
import 'package:wsmb_day2_try8_jam/services/firestore1.dart';
import 'package:wsmb_day2_try8_jam/services/firestoreService.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final icnoController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    icnoController.text = '567890123456';
    passwordController.text = 'uuu111';
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      var token = await Rider.getToken();
      if (token != null && token.isNotEmpty) {
        Rider rider = await FirestoreService.getRider(token);
        if (rider != null) {
          // User is already logged in, navigate to HomePage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage(rider: rider)),
          );
        }
      }
    } catch (e) {
      // If there's an error, stay on the login page
      print("Error checking login status: $e");
    }
  }

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      var rider = await Rider.login(icnoController.text, passwordController.text);
      if (rider == null) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Warning'),
            content: Text('Invalid Login'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK')
              )
            ],
          )
        );
      } else {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Login Successfully'),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    var token = await Rider.getToken();
                    Rider rider = await FirestoreService.getRider(token);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => HomePage(rider: rider)),
                    );
                  } catch (e) {
                    print("Error navigating to HomePage: $e");
                    Navigator.of(context).pop(); // Close the dialog
                  }
                },
                child: Text('OK')
              )
            ],
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 200),
            Center(
              child: Text(
                'Hello\nWelcome to Kongsi Kereta',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: icnoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        label: Center(child: Text('IC No'))
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your ic number';
                        } else if (value.length != 12 || int.tryParse(value) == null) {
                          return 'Please enter a valid ic number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        label: Center(child: Text('Password'))
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        color: Colors.white
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          backgroundColor: Colors.blueAccent
                        ),
                        onPressed: login,
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        )
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Personapage()
                        ));
                      },
                      child: Text(
                        'Did not have account yet?\nClick me!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue
                        ),
                      )
                    )
                  ],
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}