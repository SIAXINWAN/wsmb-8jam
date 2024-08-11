import 'package:flutter/material.dart';
import 'package:wsmb_day2_try8_jam/models/driver.dart';
import 'package:wsmb_day2_try8_jam/models/ride.dart';
import 'package:wsmb_day2_try8_jam/models/rider.dart';
import 'package:wsmb_day2_try8_jam/pages/detail/rideListPage.dart';
import 'package:wsmb_day2_try8_jam/pages/profilePage.dart';
import 'package:wsmb_day2_try8_jam/services/firestoreService.dart';

class RideDetailPage extends StatefulWidget {
  const RideDetailPage(
      {super.key,
      required this.ride,
      required this.rider,
      required this.driver});
  final Ride ride;
  final Rider rider;
  final Driver driver;

  @override
  State<RideDetailPage> createState() => _RideDetailPageState();
}

class _RideDetailPageState extends State<RideDetailPage> {
  bool isJoined = false;
  String? _selectedPaymentMethod;
  final List<String> _paymentMethods = ['Cash', 'DuitNow', 'TNG Wallet'];

  @override
  void initState() {
    super.initState();
    _checkJoinStatus();
  }

  Future<void> _checkJoinStatus() async {
    var result =
        await FirestoreService.getRiderJoinStatus(widget.ride, widget.rider);
    setState(() {
      isJoined = result.isJoined;
      _selectedPaymentMethod = result.paymentMethod;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kongsi Kereta'),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ProfilePage(rider: widget.rider),
                ));
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.rider.photo.toString()),
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              'Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(widget.driver.photo!),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Driver Photo',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Driver',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Gender',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Phone Number',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Origin',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Destination',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Date Time',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                SizedBox(
                  width: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      ': ${widget.driver.name}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      ': ${(widget.driver.gender ? 'Male' : 'Female')}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      ': ${widget.driver.phone}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      ': ${widget.ride.origin}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      ': ${widget.ride.destination}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      ': ${widget.ride.date}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              value: _selectedPaymentMethod,
              items: _paymentMethods.map((String method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: isJoined
                  ? null
                  : (String? newValue) {
                      setState(() {
                        _selectedPaymentMethod = newValue;
                      });
                    },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Return'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (isJoined) {
                      var res = await FirestoreService.cancelRide(
                          widget.ride, widget.rider);
                      if (res) {
                        setState(() {
                          isJoined = false;
                          _selectedPaymentMethod = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Your join is cancelled')),
                        );
                      }
                    } else {
                      if (_selectedPaymentMethod == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Please select a payment method')),
                        );
                        return;
                      }
                      var res = await FirestoreService.joinRide(
                          widget.ride, widget.rider, _selectedPaymentMethod!);
                      if (res) {
                        setState(() {
                          isJoined = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('You successfully joined the ride')),
                        );
                      }
                    }
                  },
                  child: Text(isJoined ? 'Cancel' : 'Join'),
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RideListPage(rider: widget.rider),
          ));
        },
        child: Text('Activity'),
      ),
    );
  }
}
