import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wsmb_day2_try8_jam/models/rider.dart';
import 'package:wsmb_day2_try8_jam/pages/loginPage.dart';
import 'package:wsmb_day2_try8_jam/services/firestoreService.dart';
import 'package:wsmb_day2_try8_jam/widgets/riderCard.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.rider});
  final Rider rider;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> Logout() async {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Log Out'),
              content: Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('No')),
                TextButton(
                    onPressed: () async {
                      await Rider.signOut();
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Loginpage()));
                      ;
                    },
                    child: Text('Yes')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kongsi Kereta'),
        
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RiderCard(rider: widget.rider),
          SizedBox(
            height: 200,
          ),
          Center(
              child: ElevatedButton(onPressed: Logout, child: Text('Log Out')))
        ],
      ),
    );
  }
}
