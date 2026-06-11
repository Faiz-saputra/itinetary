import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/formatters/currency_input_formatter.dart';
import '../../models/activity_model.dart';
import '../../services/activity_service.dart';

class EditActivityView extends StatefulWidget {
  final ActivityModel activity;
  final DateTime startDate;
  final DateTime endDate;

  const EditActivityView({
    super.key,
    required this.activity,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<EditActivityView> createState() => _EditActivityViewState();
}

class _EditActivityViewState extends State<EditActivityView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _costController;

  final ActivityService _activityService = ActivityService();

  late DateTime _activityDate;
  TimeOfDay? _activityTime;

  String _selectedCategory = 'Transportasi';

  final List<String> categories = [
    'Transportasi',
    'Akomodasi',
    'Makanan',
    'Wisata',
    'Belanja',
    'Hiburan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(text: widget.activity.title);

    _descriptionController =
        TextEditingController(text: widget.activity.description);

    _costController = TextEditingController(
      text: widget.activity.cost.toInt().toString(),
    );

    _selectedCategory = widget.activity.category;

    _activityDate = widget.activity.activityDate;

    final timeParts =
        widget.activity.activityTime.replaceAll(' WIB', '').split(':');

    if (timeParts.length == 2) {
      _activityTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: widget.startDate,
      lastDate: widget.endDate,
      initialDate: _activityDate,
    );

    if (date != null) {
      setState(() {
        _activityDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _activityTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _activityTime = time;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute WIB';
  }

  Future<void> _updateActivity() async {
    if (!_formKey.currentState!.validate()) return;

    if (_activityTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jam aktivitas'),
        ),
      );
      return;
    }

    final cost = double.tryParse(
          _costController.text.replaceAll('.', ''),
        ) ??
        0;

    await _activityService.updateActivity(
      tripId: widget.activity.tripId,
      activityId: widget.activity.activityId,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      cost: cost,
      activityDate: _activityDate,
      activityTime: _formatTime(_activityTime!),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aktivitas berhasil diperbarui'),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Aktivitas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama Aktivitas',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                ),
                items: categories
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Biaya',
                  prefixText: 'Rp ',
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: Text(
                    '${_activityDate.day}/${_activityDate.month}/${_activityDate.year}',
                  ),
                  onTap: _pickDate,
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    _activityTime == null
                        ? 'Pilih Jam Aktivitas'
                        : _formatTime(_activityTime!),
                  ),
                  onTap: _pickTime,
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _updateActivity,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}