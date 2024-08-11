import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wsmb_day2_try8_jam/models/rider.dart';

import 'package:wsmb_day2_try8_jam/pages/homePage.dart';
import 'package:wsmb_day2_try8_jam/pages/loginPage.dart';
import 'package:wsmb_day2_try8_jam/widgets/bottomSheet.dart';

class Personapage extends StatefulWidget {
  const Personapage({super.key});

  @override
  State<Personapage> createState() => _PersonapageState();
}

class _PersonapageState extends State<Personapage> {
  final nameController = TextEditingController();
  final icnoController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  File? photo;
  String gender = 'male';

  void genderChanged(String? value) {
    setState(() {
      gender = value!;
    });
  }

  

  Future<Rider?> submitForm() async {
    if (formKey.currentState!.validate()) {
      Rider tempRider = Rider(
          name: nameController.text,
          icno: icnoController.text,
          gender: gender == 'male',
          phone: phoneController.text,
          email: emailController.text,
          address: addressController.text,
          password: passwordController.text);

      return tempRider;
    }
  }

  Future<String?> takePhoto(BuildContext context) async {
    ImageSource? source = await showModalBottomSheet(
        context: context, builder: (context) => bottomSheet(context));

    if (source == null) {
      return null;
    }

    ImagePicker picker = ImagePicker();
    var file = await picker.pickImage(source: source);
    if (file == null) {
      return null;
    }

    photo = File(file.path);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register - Personal Information',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: Expanded(
          child: SingleChildScrollView(
        child: Column(
          children: [
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
                child: Column(
                  children: [
                    Container(
                        height: 100,
                        width: double.infinity,
                        child: (photo != null)
                            ? CircleAvatar(
                                backgroundImage: FileImage(
                                  photo!,
                                ),
                              )
                            : TextButton(
                                onPressed: () {
                                  takePhoto(context);
                                },
                                child: Center(child: Text('Take Photo')),
                              )),
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
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          label: Center(child: Text('Password'))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Please enter a strong password';
                        }

                        return null;
                      },
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                          onPressed: () async {
                            Rider? r = await submitForm();
                            if (r == null) {
                              return;
                            }
                            if (photo == null) {
                              return null;
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CaptchaTabPage(
                                          rider: r,
                                          image: photo!,
                                        )));
                          },
                          child: Text(
                            'Next >>',
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blue),
                          )),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}

bool init = true;

class CaptchaTabPage extends StatefulWidget {
  const CaptchaTabPage({super.key, required this.rider, required this.image});
  final Rider rider;
  final File image;
  @override
  State<CaptchaTabPage> createState() => _CaptchaTabPageState();
}

class _CaptchaTabPageState extends State<CaptchaTabPage> {
  late String _captchaText;
  final _captchaController = TextEditingController();
  bool _captchaVerified = false;
  late CaptchaPainter _captchaPainter;

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
    _captchaPainter = CaptchaPainter(_captchaText);
  }

  void _generateCaptcha() {
    final random = Random();
    _captchaText =
        List.generate(6, (_) => random.nextInt(10).toString()).join();
  }

  void _verifyCaptcha() {
    if (_captchaController.text == _captchaText) {
      setState(() {
        _captchaVerified = true;
      });
    } else {
      setState(() {
        _captchaVerified = false;
        _generateCaptcha();
        _captchaController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect. Please try again.')),
      );
    }
  }

  void submitForm() async {
    if (!_captchaVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete the captcha test first.')),
      );
      return;
    }

    var rider =
        await Rider.register(widget.rider, widget.rider.password, widget.image);

    if (rider == null) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Warning'),
          content: Text('Something went wrong'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Ok'),
            ),
          ],
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Your account has been created successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Loginpage()),
                );
              },
              child: Text('Ok'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register - Captcha Verification',
            style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please enter the numbers you see below:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Container(
              width: 200,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
              ),
              child: CustomPaint(
                painter: _captchaPainter,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _captchaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter the numbers',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _verifyCaptcha,
              child: Text('Verify Captcha'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _captchaVerified ? submitForm : null,
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _captchaVerified ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _captchaController.dispose();
    super.dispose();
  }
}

class CaptchaPainter extends CustomPainter {
  final String captchaText;

  CaptchaPainter(this.captchaText);

  @override
  void paint(Canvas canvas, Size size) {
    if (!init) return;
    final random = Random(1);
    final paint = Paint()..color = Colors.black;

    for (int i = 0; i < captchaText.length; i++) {
      final char = captchaText[i];
      final textPainter = TextPainter(
        text: TextSpan(
          text: char,
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      canvas.save();
      final x = size.width * (i + 0.5) / captchaText.length;
      final y = size.height / 2;
      canvas.translate(x, y);
      canvas.rotate(random.nextDouble() * 0.5 - 0.25);
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }

    // Add some random lines for noise
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(random.nextDouble() * size.width,
            random.nextDouble() * size.height),
        Offset(random.nextDouble() * size.width,
            random.nextDouble() * size.height),
        paint..strokeWidth = 1,
      );
    }
    // init = false;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
