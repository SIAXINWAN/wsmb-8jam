import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wsmb_day2_try8_jam/models/rider.dart';
import 'package:wsmb_day2_try8_jam/pages/edit/editRiderPage.dart';

class RiderCard extends StatefulWidget {
  const RiderCard({super.key, required this.rider});
  final Rider rider;

  @override
  State<RiderCard> createState() => _RiderCardState();
}

class _RiderCardState extends State<RiderCard> {
  @override
  Widget build(BuildContext context) {
    var imageLink = widget.rider.photo == '' ? null : widget.rider.photo;
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
                'Rider Profile',
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
                      Text('Name: ${widget.rider.name}'),
                      Text(
                          'Gender: ${(widget.rider.gender ? 'Male' : 'Female')}'),
                      Text('Phone: ${widget.rider.phone}'),
                      Text('Address: ${widget.rider.address}'),
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
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EditRiderPage(
                            rider: widget.rider,
                          )));
                },
                child: Text('Edit')),
          ],
        ));
  }
}
