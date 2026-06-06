import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/trip_model.dart';

class TripService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createTrip({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required double budget,
    required String notes,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final docRef = _firestore.collection('trips').doc();

    final trip = TripModel(
      tripId: docRef.id,
      userId: user.uid,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      budget: budget,
      notes: notes,
      createdAt: Timestamp.now(),
    );

    await docRef.set(trip.toMap());
  }

  Future<void> updateTrip({
    required String tripId,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required double budget,
    required String notes,
  }) async {
    await _firestore.collection('trips').doc(tripId).update({
      'destination': destination,
      'startDate': startDate,
      'endDate': endDate,
      'budget': budget,
      'notes': notes,
    });
  }

  Future<void> deleteTrip(String tripId) async {
    await _firestore.collection('trips').doc(tripId).delete();
  }

  Stream<List<TripModel>> getTripsStream(String currentUserUid) {
    debugPrint('TripService.getTripsStream currentUserUid: $currentUserUid');

    final snapshots = _firestore
        .collection('trips')
        .where('userId', isEqualTo: currentUserUid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return snapshots.transform(
      StreamTransformer<
        QuerySnapshot<Map<String, dynamic>>,
        List<TripModel>
      >.fromHandlers(
        handleData: (snapshot, sink) {
          final docs = snapshot.docs;
          final trips = docs
              .map((doc) {
                try {
                  return TripModel.fromDocumentSnapshot(doc);
                } catch (error, stackTrace) {
                  debugPrint(
                    'TripService.getTripsStream invalid trip document ${doc.id}: $error',
                  );
                  debugPrint('$stackTrace');
                  return null;
                }
              })
              .whereType<TripModel>()
              .toList();

          debugPrint(
            'TripService.getTripsStream snapshot returned ${docs.length} docs, parsed ${trips.length} trips',
          );

          sink.add(trips);
        },
        handleError: (error, stackTrace, sink) {
          debugPrint('TripService.getTripsStream error: $error');
          debugPrint('$stackTrace');
          sink.addError(error, stackTrace);
        },
      ),
    );
  }
}
