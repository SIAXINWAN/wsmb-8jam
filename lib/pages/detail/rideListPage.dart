import 'package:flutter/material.dart';
import 'package:wsmb_day2_try8_jam/models/driver.dart';
import 'package:wsmb_day2_try8_jam/models/ride.dart';
import 'package:wsmb_day2_try8_jam/models/rider.dart';
import 'package:wsmb_day2_try8_jam/pages/detail/rideDetailPage.dart';
import 'package:wsmb_day2_try8_jam/pages/homePage.dart';
import 'package:wsmb_day2_try8_jam/pages/profilePage.dart';
import 'package:wsmb_day2_try8_jam/services/firestoreService.dart';

class RideListPage extends StatefulWidget {
  const RideListPage({
    Key? key,
    required this.rider,
  }) : super(key: key);
  final Rider rider;

  @override
  State<RideListPage> createState() => _RideListPageState();
}

class _RideListPageState extends State<RideListPage> {
  Set<String> _selectedOption = {'Liked'};
  List<Ride> _rides = [];
  Map<String, Driver> _drivers = {};

  @override
  void initState() {
    super.initState();
    _fetchRides();
  }

  Future<void> _fetchRides() async {
    if (widget.rider.id != null) {
      List<Ride> likedRides =
          await FirestoreService.getLikedRidesForRider(widget.rider.id!);
      List<Ride> joinedRides =
          await FirestoreService.getJoinedRidesForRider(widget.rider.id!);

      setState(() {
        _rides = [...likedRides, ...joinedRides];
      });
    } else {
      return;
    }
  }

  List<Ride> get _filteredRides {
    if (_selectedOption.first == 'Liked') {
      return _rides
          .where((ride) => ride.likedBy.contains(widget.rider.id))
          .toList();
    } else {
      return _rides
          .where((ride) => ride.joinedRiders.contains(widget.rider.id))
          .toList();
    }
  }

  Future<void> _unlikeRide(Ride ride) async {
    bool success =
        await FirestoreService.removeLikedRide(widget.rider.id!, ride.id!);
    if (success) {
      setState(() {
        ride.likedBy.remove(widget.rider.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ride unliked successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unlike ride')),
      );
    }
  }

  Future<void> _addComment(Ride ride) async {
    String? comment = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String commentText = '';
        return AlertDialog(
          title: Text('Add Comment'),
          content: TextField(
            onChanged: (value) {
              commentText = value;
            },
            decoration: InputDecoration(hintText: "Enter your comment"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop(commentText);
              },
            ),
          ],
        );
      },
    );

    if (comment != null && comment.isNotEmpty) {
      bool success = await FirestoreService.addCommentToRide(
          ride.id!, widget.rider.id!, comment);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comment added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kongsi Kereta'),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfilePage(
                          rider: widget.rider,
                        )));
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.rider.photo.toString()),
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SegmentedButton(
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedOption = newSelection;
                      });
                    },
                    segments: [
                      ButtonSegment(value: 'Liked', label: Text('Liked')),
                      ButtonSegment(value: 'Joined', label: Text('Joined'))
                    ],
                    selected: _selectedOption)
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredRides.length,
                itemBuilder: (context, index) {
                  return _buildRideCard(
                    _filteredRides[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HomePage(rider: widget.rider)));
          },
          child: Text('Home')),
    );
  }

  Widget _buildRideCard(Ride ride) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        // leading: CircleAvatar(
        //   backgroundImage: _drivers[ride.driver_id]?.photo != null
        //       ? NetworkImage(_drivers[ride.driver_id]!.photo!)
        //       : null,
        // child: _drivers[ride.driver_id]?.photo == null
        //     ? Icon(Icons.person)
        //     : null,
        // ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on),
                Text(
                  '${ride.origin}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.flag),
                Text(
                  '${ride.destination}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            )
          ],
        ),
        subtitle: Text('Date: ${ride.date}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(_selectedOption.first == 'Liked'
                  ? Icons.favorite
                  : Icons.check_circle),
              onPressed: _selectedOption.first == 'Liked'
                  ? () => _unlikeRide(ride)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.comment),
              onPressed: () => _addComment(ride),
            ),
          ],
        ),
        onTap: () async {
          Driver driver = await FirestoreService.getDriverById(ride.driver_id!);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RideDetailPage(
                ride: ride,
                rider: widget.rider,
                driver: driver,
              ),
            ),
          );
        },
      ),
    );
  }
}
