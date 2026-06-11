import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String activityId;
  final String tripId;

  final String title;
  final String category;
  final String description;

  final double cost;

  final DateTime activityDate;

  final String activityTime;

  final Timestamp createdAt;

  ActivityModel({
    required this.activityId,
    required this.tripId,
    required this.title,
    required this.category,
    required this.description,
    required this.cost,
    required this.activityDate,
    required this.activityTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'activityId': activityId,
      'tripId': tripId,
      'title': title,
      'category': category,
      'description': description,
      'cost': cost,
      'activityDate': activityDate,
      'activityTime': activityTime,
      'createdAt': createdAt,
    };
  }

  factory ActivityModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ActivityModel(
      activityId: map['activityId'] ?? '',
      tripId: map['tripId'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      cost: (map['cost'] ?? 0).toDouble(),
      activityDate:
          (map['activityDate'] as Timestamp).toDate(),
      activityTime:
          map['activityTime'] ?? '',
      createdAt:
          map['createdAt'] as Timestamp,
    );
  }
}