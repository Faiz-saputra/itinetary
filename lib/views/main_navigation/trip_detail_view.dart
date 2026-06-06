import 'package:flutter/material.dart';
import '../../models/trip_model.dart';
import 'edit_trip_view.dart';
import '../../services/trip_service.dart';

class TripDetailView extends StatelessWidget {
  final TripModel trip;

  const TripDetailView({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditTripView(trip: trip)),
              );

              if (result == true && context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Delete Trip'),
                    content: const Text(
                      'Are you sure you want to delete this trip?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                await TripService().deleteTrip(trip.tripId);

                if (!context.mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Trip deleted successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );

                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.destination,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            _InfoCard(
              title: 'Budget',
              value: 'Rp ${trip.budget.toStringAsFixed(0)}',
            ),

            const SizedBox(height: 16),

            _InfoCard(title: 'Start Date', value: _formatDate(trip.startDate)),

            const SizedBox(height: 16),

            _InfoCard(title: 'End Date', value: _formatDate(trip.endDate)),

            const SizedBox(height: 16),

            _InfoCard(
              title: 'Notes',
              value: trip.notes.isEmpty ? 'No notes' : trip.notes,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(title: Text(title), subtitle: Text(value)),
    );
  }
}
