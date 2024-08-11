import 'package:flutter/material.dart';

import 'package:wsmb_day2_try8_jam/models/driver.dart';

class DriverCard extends StatefulWidget {
  const DriverCard({super.key, required this.driver});
  final Driver driver;

  @override
  State<DriverCard> createState() => _DriverCardState();
}

class _DriverCardState extends State<DriverCard> {
  @override
  Widget build(BuildContext context) {
    var imageLink = widget.driver.photo == '' ? null : widget.driver.photo;
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        height: MediaQuery.of(context).size.height * 0.25,
        width: double.infinity,
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(4),
        child: Column(
          children: [
            Center(
              child: Text(
                'Profile',
                style: TextStyle(
                    fontSize: 24, decoration: TextDecoration.underline),
              ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${widget.driver.name}'),
                      Text(
                          'Gender: ${(widget.driver.gender ? 'Male' : 'Female')}'),
                      Text('Phone: ${widget.driver.phone}'),
                      Text('Address: ${widget.driver.address}'),
                    ],
                  )),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.width * 0.25,
                    child: Image.network(
                      imageLink ??
                          'https://firebasestorage.googleapis.com/v0/b/wsmb-try1.appspot.com/o/vehicle%2F1721706260095.jpg?alt=media&token=9b331ad6-2781-4ecc-9c04-be4884005184',
                      fit: BoxFit.fill,
                    ),
                  )
                ]),
            SizedBox(
              height: 10,
            ),
            
          ],
        ));
  }
}
