import 'package:flutter/material.dart';

import '../../models/trip_model.dart';
import '../../services/trip_service.dart';

class EditTripView extends StatefulWidget {
  final TripModel trip;

  const EditTripView({
    super.key,
    required this.trip,
  });

  @override
  State<EditTripView> createState() => _EditTripViewState();
}

class _EditTripViewState extends State<EditTripView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController destinationController;
  late TextEditingController budgetController;
  late TextEditingController notesController;

  late DateTime startDate;
  late DateTime endDate;

  final TripService tripService = TripService();

  @override
  void initState() {
    super.initState();

    destinationController =
        TextEditingController(text: widget.trip.destination);

    budgetController =
        TextEditingController(text: widget.trip.budget.toString());

    notesController =
        TextEditingController(text: widget.trip.notes);

    startDate = widget.trip.startDate;
    endDate = widget.trip.endDate;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    await tripService.updateTrip(
      tripId: widget.trip.tripId,
      destination: destinationController.text.trim(),
      startDate: startDate,
      endDate: endDate,
      budget: double.parse(budgetController.text),
      notes: notesController.text.trim(),
    );

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Trip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Destination required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Budget',
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}