import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_model.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addActivity({
    required String tripId,
    required String title,
    required String category,
    required String description,
    required double cost,
    required DateTime activityDate,
    required String activityTime,
  }) async {
    final docRef = _firestore
        .collection('trips')
        .doc(tripId)
        .collection('activities')
        .doc();

    final activity = ActivityModel(
      activityId: docRef.id,
      tripId: tripId,
      title: title,
      category: category,
      description: description,
      cost: cost,
      activityDate: activityDate,
      activityTime: activityTime,
      createdAt: Timestamp.now(),
    );

    await docRef.set(activity.toMap());
  }

  Stream<List<ActivityModel>> getActivities(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('activities')
        .orderBy('activityDate', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ActivityModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> updateActivity({
    required String tripId,
    required String activityId,
    required String title,
    required String category,
    required String description,
    required double cost,
    required DateTime activityDate,
    required String activityTime,
  }) async {
    await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('activities')
        .doc(activityId)
        .update({
          'title': title,
          'category': category,
          'description': description,
          'cost': cost,
          'activityDate': activityDate,
          'activityTime': activityTime,
        });
  }

  Future<void> deleteActivity({
    required String tripId,
    required String activityId,
  }) async {
    await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('activities')
        .doc(activityId)
        .delete();
  }
}
