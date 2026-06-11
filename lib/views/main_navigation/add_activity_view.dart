import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;

import '../../services/activity_service.dart';
import '../../core/formatters/currency_input_formatter.dart';

class AddActivityView extends StatefulWidget {
  final String tripId;
  final DateTime startDate;
  final DateTime endDate;

  const AddActivityView({
    super.key,
    required this.tripId,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<AddActivityView> createState() => _AddActivityViewState();
}

class _AddActivityViewState extends State<AddActivityView> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();

  final ActivityService _activityService = ActivityService();

  DateTime? _activityDate;
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

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: widget.startDate,
      lastDate: widget.endDate,
      initialDate: widget.startDate,
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
      initialTime: TimeOfDay.now(),
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

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_activityDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih tanggal aktivitas')));
      return;
    }

    if (_activityTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih jam aktivitas')));
      return;
    }

    await _activityService.addActivity(
      tripId: widget.tripId,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      cost: double.tryParse(_costController.text.trim()) ?? 0,
      activityDate: _activityDate!,
      activityTime: _formatTime(_activityTime!),
    );

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Aktivitas')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Nama Aktivitas'),
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
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: categories
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Biaya wajib diisi';
                  }

                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Biaya',
                  prefixText: 'Rp ',
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Catatan'),
              ),

              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: Text(
                    _activityDate == null
                        ? 'Pilih Tanggal Aktivitas'
                        : '${_activityDate!.day}/${_activityDate!.month}/${_activityDate!.year}',
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
                onPressed: _saveActivity,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Aktivitas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
