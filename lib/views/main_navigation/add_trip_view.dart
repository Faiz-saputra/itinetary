import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/trip_service.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AddTripView extends StatefulWidget {
  const AddTripView({super.key});

  @override
  State<AddTripView> createState() => _AddTripViewState();
}

class _AddTripViewState extends State<AddTripView> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();

  final TripService _tripService = TripService();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _destinationController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = DateTime(now.year + 5);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          if (_endDate != null && _endDate!.isBefore(pickedDate)) {
            _endDate = null;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String? _validateDestination(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a destination';
    }
    if (value.length < 2) {
      return 'Destination must be at least 2 characters';
    }
    return null;
  }

  String? _validateBudget(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a budget';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  Future<void> _handleSaveTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
      return;
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an end date')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      await _tripService.createTrip(
        destination: _destinationController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        budget: double.tryParse(_budgetController.text.trim()) ?? 0,
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip created successfully!')),
      );

      _clearForm();

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _destinationController.clear();
    _budgetController.clear();
    _notesController.clear();
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Add New Trip'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                _buildSectionHeader(
                  theme,
                  'Trip Details',
                  'Create a new trip and start planning your journey',
                ),
                const SizedBox(height: 28),

                // Trip Image Placeholder
                _buildImageUploadCard(theme, colorScheme),
                const SizedBox(height: 28),

                // Destination Field
                _buildSectionTitle(theme, 'Destination'),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _destinationController,
                  labelText: 'Destination',
                  hintText: 'Enter your destination (e.g., Paris, Bangkok)',
                  prefixIcon: Icon(
                    Icons.location_on_rounded,
                    color: colorScheme.primary,
                  ),
                  validator: _validateDestination,
                ),
                const SizedBox(height: 24),

                // Date Selection Row
                _buildSectionTitle(theme, 'Travel Dates'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePickerButton(
                        context,
                        theme,
                        colorScheme,
                        'Start Date',
                        _startDate,
                        () => _selectDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDatePickerButton(
                        context,
                        theme,
                        colorScheme,
                        'End Date',
                        _endDate,
                        () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Budget Field
                _buildSectionTitle(theme, 'Budget'),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _budgetController,
                  labelText: 'Budget',
                  hintText: 'Enter total budget',
                  prefixIcon: Icon(
                    Icons.wallet_rounded,
                    color: colorScheme.primary,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _validateBudget,
                ),
                const SizedBox(height: 24),

                // Notes Field
                _buildSectionTitle(theme, 'Notes'),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _notesController,
                  labelText: 'Notes',
                  hintText: 'Add notes about your trip (optional)',
                  prefixIcon: Icon(
                    Icons.note_rounded,
                    color: colorScheme.primary,
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 32),

                // Save Button
                CustomButton(
                  title: 'Create Trip',
                  isLoading: _isLoading,
                  onPressed: _handleSaveTrip,
                  icon: Icon(Icons.check_rounded, color: colorScheme.onPrimary),
                ),
                const SizedBox(height: 12),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      side: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String subtitle) {
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withAlpha(191),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildImageUploadCard(ThemeData theme, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        // Future: Image picker implementation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload coming soon')),
        );
      },
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary.withAlpha(76),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_rounded,
              size: 48,
              color: colorScheme.primary.withAlpha(127),
            ),
            const SizedBox(height: 12),
            Text(
              'Add Trip Image',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to upload a photo',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withAlpha(127),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    DateTime? selectedDate,
    VoidCallback onPressed,
  ) {
    final isSelected = selectedDate != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withAlpha(153),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _formatDate(selectedDate),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withAlpha(127),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
