import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:overflow_text_animated/overflow_text_animated.dart';
import 'package:shake_gesture/shake_gesture.dart';
import 'package:wsmb_day2_try8_jam/models/driver.dart';
import 'package:wsmb_day2_try8_jam/models/ride.dart';
import 'package:wsmb_day2_try8_jam/models/rider.dart';
import 'package:wsmb_day2_try8_jam/pages/detail/rideDetailPage.dart';
import 'package:wsmb_day2_try8_jam/pages/detail/rideListPage.dart';
import 'package:wsmb_day2_try8_jam/pages/profilePage.dart';
import 'package:wsmb_day2_try8_jam/services/firestore1.dart';
import 'package:wsmb_day2_try8_jam/services/firestoreService.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.rider}) : super(key: key);
  final Rider rider;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final originController = TextEditingController();
  final destController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  int _currentIndex = 0;
  CarouselController _carouselController = CarouselController();
  bool _isShaking = false;

  List<Ride> rideList = [];
  List<Driver> driverList = [];
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String originFilter = '';
  String destinationFilter = '';

  Ride? lastLikedRide;

  @override
  void initState() {
    super.initState();
    getRideList();
  }

  void getRideList() async {
    rideList = await FirestoreService11.getRide();
    for (var r in rideList) {
      var d = await r.getDriver();
      driverList.add(d!);
    }
    setState(() {});
  }

  void likeRide(Ride ride) async {
    print("Liking ride: ${ride.id}"); // Debug print
    setState(() {
      lastLikedRide = ride;
    });

    await FirestoreService.addLikedRide(widget.rider.id!, ride.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ride liked! Shake detected.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            undoLikeRide();
          },
        ),
        duration: Duration(seconds: 5),
      ),
    );
  }

  void undoLikeRide() async {
    if (lastLikedRide != null) {
      await FirestoreService.removeLikedRide(
          widget.rider.id!, lastLikedRide!.id!);

      setState(() {
        lastLikedRide = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Like undone.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void takeDate() async {
    final tempDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      initialDate: selectedDate ?? DateTime.now(),
    );
    if (tempDate != null) {
      setState(() {
        selectedDate = tempDate;
      });
    }
  }

  void takeTime() async {
    final tempTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (tempTime != null) {
      setState(() {
        selectedTime = tempTime;
      });
    }
  }

  void clearDate() {
    setState(() {
      selectedDate = null;
    });
  }

  void clearTime() {
    setState(() {
      selectedTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    var filterList = rideList.where((e) {
      bool originMatch =
          e.origin.toLowerCase().contains(originFilter.toLowerCase());
      bool destinationMatch =
          e.destination.toLowerCase().contains(destinationFilter.toLowerCase());
      bool dateMatch = selectedDate == null ||
          (e.date.year == selectedDate!.year &&
              e.date.month == selectedDate!.month &&
              e.date.day == selectedDate!.day);
      bool timeMatch = selectedTime == null ||
          (e.date.hour == selectedTime!.hour &&
              e.date.minute == selectedTime!.minute);
      return originMatch && destinationMatch && dateMatch && timeMatch;
    }).toList();

    return ShakeGesture(
      onShake: () {
        if (_currentIndex < filterList.length) {
          likeRide(filterList[_currentIndex]);
        }
      },
      child: Scaffold(
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
                      builder: (context) => ProfilePage(rider: widget.rider)));
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.rider.photo.toString()),
                ),
              )
            ],
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_isShaking)
                  Container(
                    color: Colors.yellow,
                    padding: EdgeInsets.all(8),
                    child: Text("Shaking detected!"),
                  ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(color: Colors.lightGreen),
                  child: OverflowTextAnimated(
                    text:
                        'Welcome to Kongsi Kereta  Welcome to Kongsi Kereta  Welcome to Kongsi Kereta',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    animation: OverFlowTextAnimations.infiniteLoop,
                    loopSpace: 30,
                  ),
                ),
                SizedBox(height: 8),
                Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: originController,
                            decoration: InputDecoration(
                                hintText: 'Origin',
                                prefixIcon: Icon(Icons.search),
                                label: Center(child: Text('Search Origin'))),
                            onChanged: (value) {
                              setState(() {
                                originFilter = value.trim();
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: destController,
                            decoration: InputDecoration(
                                hintText: 'Destination',
                                prefixIcon: Icon(Icons.search),
                                label:
                                    Center(child: Text('Search Destination'))),
                            onChanged: (value) {
                              setState(() {
                                destinationFilter = value.trim();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: takeDate,
                      child: Text(selectedDate == null
                          ? 'Select Date'
                          : 'Date: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
                    ),
                    ElevatedButton(
                      onPressed: takeTime,
                      child: Text(selectedTime == null
                          ? 'Select Time'
                          : 'Time: ${selectedTime!.format(context)}'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  height: 40,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => RideListPage(
                            rider: widget.rider,
                          ),
                        ));
                      },
                      child: Text('Liked'),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CarouselSlider(
                      carouselController: _carouselController,
                      options: CarouselOptions(
                        height: 250.0,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) async {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                      ),
                      items: filterList.map((ride) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(driverList[
                                                filterList.indexOf(ride)]
                                            ?.photo ??
                                        'https://firebasestorage.googleapis.com/v0/b/wsmb-6jam.appspot.com/o/images%2F1722391321299833.jpg?alt=media&token=84953954-c612-4399-a479-1a285d776f67'),
                                    radius: 30,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                      'Driver: ${driverList[filterList.indexOf(ride)].name ?? 'empty'}'),
                                  Text('Origin: ${ride.origin} '),
                                  Text('Destination: ${ride.destination}'),
                                  Text('Date Time: ${ride.date}'),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RideDetailPage(
                                            ride: ride,
                                            rider: widget.rider,
                                            driver: driverList[
                                                filterList.indexOf(ride)],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text('Detail'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    Positioned(
                      left: 10,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          _carouselController.previousPage();
                        },
                      ),
                    ),
                    Positioned(
                      right: 7,
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          _carouselController.nextPage();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => RideListPage(
                rider: widget.rider,
              ),
            ));
          },
          child: Text('Activity'),
        ),
      ),
    );
  }
}
