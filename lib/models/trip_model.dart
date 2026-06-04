import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String tripId;
  final String userId;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final String notes;
  final Timestamp createdAt;

  TripModel({
    required this.tripId,
    required this.userId,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'userId': userId,
      'destination': destination,
      'startDate': startDate,
      'endDate': endDate,
      'budget': budget,
      'notes': notes,
      'createdAt': createdAt,
    };
  }

  factory TripModel.fromDocumentSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return TripModel.fromMap(
      snapshot.data() ?? <String, dynamic>{},
      fallbackTripId: snapshot.id,
    );
  }

  factory TripModel.fromMap(
    Map<String, dynamic> map, {
    String? fallbackTripId,
  }) {
    return TripModel(
      tripId: _parseString(map['tripId'], fallbackTripId ?? ''),
      userId: _parseString(map['userId'], ''),
      destination: _parseString(map['destination'], 'Unknown destination'),
      startDate: _parseDateTime(map['startDate']),
      endDate: _parseDateTime(map['endDate']),
      budget: _parseBudget(map['budget']),
      notes: _parseString(map['notes'], ''),
      createdAt: _parseTimestamp(map['createdAt']),
    );
  }

  static String _parseString(Object? value, String fallback) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    if (value != null) {
      return value.toString();
    }
    return fallback;
  }

  static double _parseBudget(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static DateTime _parseDateTime(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  static Timestamp _parseTimestamp(Object? value) {
    if (value is Timestamp) {
      return value;
    }
    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return Timestamp.fromDate(parsed);
      }
    }
    if (value is int) {
      return Timestamp.fromMillisecondsSinceEpoch(value);
    }
    return Timestamp.now();
  }
}
