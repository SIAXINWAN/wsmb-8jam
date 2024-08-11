import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wsmb_day2_try8_jam/models/driver.dart';
import 'package:wsmb_day2_try8_jam/models/ride.dart';
import 'package:wsmb_day2_try8_jam/models/rider.dart';

class JoinStatus {
  final bool isJoined;
  final String? paymentMethod;

  JoinStatus(this.isJoined, this.paymentMethod);
}

class FirestoreService {
  static final firestore = FirebaseFirestore.instance;

  static Future<bool> isDuplicated(Rider rider) async {
    final queries = await Future.wait([
      firestore.collection('riders').where('icno', isEqualTo: rider.icno).get(),
      firestore.collection('riders').where('phone', isEqualTo: rider.phone).get(),
      firestore.collection('riders').where('email', isEqualTo: rider.email).get(),
    ]);

    return queries.any((querySnapshot) => querySnapshot.docs.isNotEmpty);
  }

  static Future<Rider?> addRider(Rider rider) async {
    try {
      var collection = await firestore.collection('riders').get();
      var id = 'R${collection.size + 1}';

      rider.id = id;

      await firestore.collection('riders').doc(rider.id).set(rider.toJson());

      var newDoc = await firestore.collection('riders').doc(rider.id).get();
      return newDoc.exists ? Rider.fromJson(newDoc.data()!, rider.id!) : null;
    } catch (e) {
      print('Error adding rider: $e');
      return null;
    }
  }

  static Future<Rider?> loginRider(String ic, String password) async {
    try {
      var querySnapshot = await firestore
          .collection('riders')
          .where('icno', isEqualTo: ic)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      var doc = querySnapshot.docs.first;
      return Rider.fromJson(doc.data(), doc.id);
    } catch (e) {
      print('Error logging in rider: $e');
      return null;
    }
  }

  static Future<Rider?> validateTokenRider(String id) async {
    try {
      var doc = await firestore.collection('riders').doc(id).get();
      return doc.exists ? Rider.fromJson(doc.data()!, doc.id) : null;
    } catch (e) {
      print('Error validating rider token: $e');
      return null;
    }
  }

  static Future<Rider> getRider(String id) async {
    try {
      var doc = await firestore.collection('riders').doc(id).get();
      if (!doc.exists) throw Exception('Rider not found');
      return Rider.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting rider: $e');
      rethrow;
    }
  }

  static Future<bool> updateRider(Rider rider, String id) async {
    try {
      await firestore.collection('riders').doc(id).update(rider.toJson());
      return true;
    } catch (e) {
      print('Error updating rider: $e');
      return false;
    }
  }

static Future<JoinStatus> getRiderJoinStatus(Ride ride, Rider rider) async {
    try {
      DocumentSnapshot rideDoc = await firestore
          .collection('rides')
          .doc(ride.id)
          .get();

      if (rideDoc.exists) {
        Map<String, dynamic> data = rideDoc.data() as Map<String, dynamic>;
        List<dynamic> joinedRiders = data['joinedRiders'] ?? [];
        List<dynamic> riderPaymentMethods = data['riderPaymentMethods'] ?? [];

        if (joinedRiders.contains(rider.id)) {
          var paymentInfo = riderPaymentMethods.firstWhere(
            (element) => element['riderId'] == rider.id,
            orElse: () => null,
          );
          return JoinStatus(true, paymentInfo?['paymentMethod']);
        }
      }
      return JoinStatus(false, null);
    } catch (e) {
      print('Error checking rider join status: $e');
      return JoinStatus(false, null);
    }
  }

  static Future<bool> cancelRide(Ride ride, Rider rider) async {
    try {
      var batch = firestore.batch();

      var rideRef = firestore.collection('rides').doc(ride.id);
      batch.update(rideRef, {
        'joinedRiders': FieldValue.arrayRemove([rider.id]),
        'riderPaymentMethods': FieldValue.arrayRemove([
          {
            'riderId': rider.id,
          }
        ]),
      });

      var riderRef = firestore.collection('riders').doc(rider.id);
      batch.update(riderRef, {
        'joinedRides': FieldValue.arrayRemove([ride.id]),
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('Error cancelling ride: $e');
      return false;
    }
  }

  static Future<Driver> getDriverById(String driverId) async {
    try {
      var doc = await firestore.collection('drivers').doc(driverId).get();
      if (!doc.exists) throw Exception('Driver not found');
      return Driver.fromJson(doc.data()!);
    } catch (e) {
      print('Error fetching driver: $e');
      rethrow;
    }
  }

  static Future<bool> addLikedRide(String riderId, String rideId) async {
    try {
      var batch = firestore.batch();

      var rideRef = firestore.collection('rides').doc(rideId);
      batch.update(rideRef, {
        'likedBy': FieldValue.arrayUnion([riderId]),
      });

      var riderRef = firestore.collection('riders').doc(riderId);
      batch.update(riderRef, {
        'likedRides': FieldValue.arrayUnion([rideId]),
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('Error adding liked ride: $e');
      return false;
    }
  }

  static Future<bool> removeLikedRide(String riderId, String rideId) async {
    try {
      var batch = firestore.batch();

      var rideRef = firestore.collection('rides').doc(rideId);
      batch.update(rideRef, {
        'likedBy': FieldValue.arrayRemove([riderId]),
      });

      var riderRef = firestore.collection('riders').doc(riderId);
      batch.update(riderRef, {
        'likedRides': FieldValue.arrayRemove([rideId]),
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('Error removing liked ride: $e');
      return false;
    }
  }

  static Future<List<Ride>> getLikedRidesForRider(String riderId) async {
    try {
      var snapshot = await firestore
          .collection('rides')
          .where('likedBy', arrayContains: riderId)
          .get();

      return snapshot.docs
          .map((doc) => Ride.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching liked rides: $e');
      return [];
    }
  }

  static Future<List<Ride>> getJoinedRidesForRider(String riderId) async {
    try {
      var snapshot = await firestore
          .collection('rides')
          .where('joinedRiders', arrayContains: riderId)
          .get();

      return snapshot.docs
          .map((doc) => Ride.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching joined rides: $e');
      return [];
    }
  }

  static Future<bool> joinRide(Ride ride, Rider rider, String paymentMethod) async {
  try {
    var batch = firestore.batch();

    var rideRef = firestore.collection('rides').doc(ride.id);
    batch.update(rideRef, {
      'joinedRiders': FieldValue.arrayUnion([rider.id]),
      'riderPaymentMethods': FieldValue.arrayUnion([
        {
          'riderId': rider.id,
          'paymentMethod': paymentMethod,
        }
      ]),
    });

    var riderRef = firestore.collection('riders').doc(rider.id);
    batch.update(riderRef, {
      'joinedRides': FieldValue.arrayUnion([ride.id]),
    });

    await batch.commit();
    return true;
  } catch (e) {
    print('Error joining ride: $e');
    return false;
  }
}

  static Future<List<Ride>> getRidesForRider(String riderId) async {
    try {
      var likedRides = await getLikedRidesForRider(riderId);
      var joinedRides = await getJoinedRidesForRider(riderId);

      var rideIds = {...likedRides.map((r) => r.id!), ...joinedRides.map((r) => r.id!)};

      var rides = await Future.wait(
        rideIds.map((id) => firestore.collection('rides').doc(id).get())
      );

      return rides
          .where((doc) => doc.exists)
          .map((doc) => Ride.fromJson(doc.data()!, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching rides: $e');
      return [];
    }
  }

  static Future<bool> addCommentToRide(String rideId, String riderId, String comment) async {
    try {
      await firestore.collection('rides').doc(rideId).update({
        'comments': FieldValue.arrayUnion([{
          'riderId': riderId,
          'comment': comment,
          'timestamp': FieldValue.serverTimestamp(),
        }]),
      });
      return true;
    } catch (e) {
      print('Error adding comment to ride: $e');
      return false;
    }
  }

  static Future<Ride> getRideWithComments(String rideId) async {
    try {
      var doc = await firestore.collection('rides').doc(rideId).get();
      if (!doc.exists) throw Exception('Ride not found');
      return Ride.fromJson(doc.data()!, rideId);
    } catch (e) {
      print('Error fetching ride with comments: $e');
      rethrow;
    }
  }
}