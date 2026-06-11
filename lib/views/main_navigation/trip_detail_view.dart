import 'package:flutter/material.dart';

import '../../models/activity_model.dart';
import '../../models/trip_model.dart';
import '../../services/activity_service.dart';
import '../../services/trip_service.dart';
import 'add_activity_view.dart';
import 'edit_trip_view.dart';
import '../../core/utils/currency_helper.dart';
import 'edit_activity_view.dart';

class TripDetailView extends StatefulWidget {
  final TripModel trip;

  const TripDetailView({super.key, required this.trip});

  @override
  State<TripDetailView> createState() => _TripDetailViewState();
}

class _TripDetailViewState extends State<TripDetailView> {
  Stream<List<ActivityModel>> _activityStream() {
    return ActivityService().getActivities(widget.trip.tripId);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double value) {
    return CurrencyHelper.formatRupiah(value);
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Transportasi':
        return Icons.flight_takeoff;

      case 'Akomodasi':
        return Icons.hotel;

      case 'Makanan':
        return Icons.restaurant;

      case 'Wisata':
        return Icons.place;

      case 'Belanja':
        return Icons.shopping_bag;

      case 'Hiburan':
        return Icons.movie;

      default:
        return Icons.event;
    }
  }

  String _formatTimelineHeader(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Map<String, List<ActivityModel>> _groupActivitiesByDate(
    List<ActivityModel> activities,
  ) {
    final Map<String, List<ActivityModel>> grouped = {};

    for (final activity in activities) {
      final key =
          '${activity.activityDate.year}-${activity.activityDate.month}-${activity.activityDate.day}';

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }

      grouped[key]!.add(activity);
    }

    return grouped;
  }

  Future<void> _deleteActivity(ActivityModel activity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Aktivitas'),
          content: Text('Yakin ingin menghapus "${activity.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await ActivityService().deleteActivity(
      tripId: activity.tripId,
      activityId: activity.activityId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${activity.title} berhasil dihapus')),
    );
  }

  Widget _buildTripHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: Colors.white),
              SizedBox(width: 8),
              Text('Destinasi', style: TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.trip.destination,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${_formatDate(widget.trip.startDate)} - ${_formatDate(widget.trip.endDate)}',
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<ActivityModel> activities, double totalSpent) {
    final totalDays =
        widget.trip.endDate.difference(widget.trip.startDate).inDays + 1;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              icon: Icons.event_note,
              title: 'Aktivitas',
              value: '${activities.length}',
            ),

            _SummaryItem(
              icon: Icons.calendar_month,
              title: 'Durasi',
              value: '$totalDays Hari',
            ),

            _SummaryItem(
              icon: Icons.payments,
              title: 'Pengeluaran',
              value: _formatCurrency(totalSpent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(double totalSpent) {
    final remainingBudget = widget.trip.budget - totalSpent;

    final percentageUsed = widget.trip.budget <= 0
        ? 0.0
        : (totalSpent / widget.trip.budget);

    final progress = percentageUsed.clamp(0.0, 1.0);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.account_balance_wallet),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget Awal',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        _formatCurrency(widget.trip.budget),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Terpakai'),

                Text(
                  _formatCurrency(totalSpent),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sisa Budget'),

                Text(
                  _formatCurrency(remainingBudget),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: remainingBudget >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),

              color: percentageUsed < 0.5
                  ? Colors.green
                  : percentageUsed < 0.8
                  ? Colors.orange
                  : Colors.red,
            ),

            const SizedBox(height: 10),

            Center(
              child: Text(
                '${(percentageUsed * 100).toStringAsFixed(1)}% Budget Digunakan',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (remainingBudget < 0) ...[
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'Budget terlampaui sebesar ${_formatCurrency((-remainingBudget))}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notes),
                SizedBox(width: 8),
                Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.trip.notes.isEmpty
                  ? 'Tidak ada catatan'
                  : widget.trip.notes,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blue.shade50,
                child: Icon(
                  _getCategoryIcon(activity.category),
                  color: Colors.blue,
                ),
              ),

              Container(width: 2, height: 90, color: Colors.grey.shade300),
            ],
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${activity.activityTime} ',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditActivityView(
                                  activity: activity,
                                  startDate: widget.trip.startDate,
                                  endDate: widget.trip.endDate,
                                ),
                              ),
                            );
                          },
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () {
                            _deleteActivity(activity);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      activity.category,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.payments, size: 16),

                        const SizedBox(width: 6),

                        Text(
                          _formatCurrency(activity.cost),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    if (activity.description.isNotEmpty) ...[
                      const SizedBox(height: 10),

                      Text(activity.description),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTrip() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Trip'),
          content: const Text('Yakin ingin menghapus trip ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await TripService().deleteTrip(widget.trip.tripId);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Trip berhasil dihapus')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddActivityView(
                tripId: widget.trip.tripId,
                startDate: widget.trip.startDate,
                endDate: widget.trip.endDate,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Aktivitas'),
      ),

      appBar: AppBar(
        title: const Text('Trip Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditTripView(trip: widget.trip),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteTrip,
          ),
        ],
      ),

      body: StreamBuilder<List<ActivityModel>>(
        stream: _activityStream(),
        builder: (context, snapshot) {
          final activities = snapshot.data ?? [];
          final totalSpent = activities.fold<double>(
            0,
            (total, activity) => total + activity.cost,
          );

          final groupedActivities = _groupActivitiesByDate(activities);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTripHeader(),

                const SizedBox(height: 20),

                _buildSummaryCard(activities, totalSpent),

                const SizedBox(height: 20),

                _buildBudgetCard(totalSpent),

                const SizedBox(height: 20),

                _buildNotesCard(),

                const SizedBox(height: 30),

                const Text(
                  'Aktivitas Perjalanan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator()),

                if (activities.isEmpty &&
                    snapshot.connectionState != ConnectionState.waiting)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('Belum ada aktivitas')),
                    ),
                  ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Timeline Perjalanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),

                const Divider(),

                ...groupedActivities.entries.map((entry) {
                  final dateKey = entry.key;

                  final dayActivities = entry.value;

                  dayActivities.sort(
                    (a, b) => a.activityTime.compareTo(b.activityTime),
                  );

                  final dateParts = dateKey.split('-');

                  final date = DateTime(
                    int.parse(dateParts[0]),
                    int.parse(dateParts[1]),
                    int.parse(dateParts[2]),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      Text(
                        _formatTimelineHeader(date),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Divider(),

                      ...dayActivities.map(
                        (activity) => _buildActivityCard(activity),
                      ),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 22, child: Icon(icon)),

        const SizedBox(height: 8),

        Text(title, style: TextStyle(color: Colors.grey.shade600)),

        const SizedBox(height: 4),

        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
