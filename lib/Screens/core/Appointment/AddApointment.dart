import 'package:flutter/material.dart';
import 'package:health_chain/services/user_service.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:intl/intl.dart';

class AddAppointmentForm extends StatefulWidget {
  final String doctorId;
  final ScrollController scrollController;

  const AddAppointmentForm({
    super.key,
    required this.doctorId,
    required this.scrollController,
  });

  @override
  State<AddAppointmentForm> createState() => _AddAppointmentFormState();
}

class _AddAppointmentFormState extends State<AddAppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  String? _selectedType; // Store the selected type
  final UserService userService = UserService();

  DateTime? _startDateTime;
  DateTime? _endDateTime;

  final List<String> _typeOptions = ['appointment', 'consultation', 'checkup'];

  Future<void> _pickDateTime({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(minutes: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 30))),
    );
    if (time == null) return;

    final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _startDateTime = dateTime;
      } else {
        _endDateTime = dateTime;
      }
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() &&
        _startDateTime != null &&
        _endDateTime != null &&
        _selectedType != null) {
      final appointmentData = {
        "doctorId": widget.doctorId,
        "startDateTime": _startDateTime!.toIso8601String(),
        "endDateTime": _endDateTime!.toIso8601String(),
        "reason": _reasonController.text.trim(),
        "type": _selectedType!.toLowerCase(),
      };

      try {
        final response = await userService.createAppointment(appointmentData);
        print("Appointment created: $response");
        if (mounted) Navigator.pop(context);
      } catch (e) {
        print("Error details: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create appointment: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd – kk:mm');
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.secondaryColor,
            ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          controller: widget.scrollController,
          children: [
            const Text("Ajouter un rendez-vous", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(labelText: "Reason"),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Requis";
                      return null;
                    },
                    cursorColor: AppColors.secondaryColor,
                    style: const TextStyle(color: AppColors.block),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Type"),
                    value: _selectedType,
                    items: _typeOptions.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type.capitalize()),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) return "Requis";
                      return null;
                    },
                    style: const TextStyle(color: AppColors.block),
                    dropdownColor: Colors.white,
                    iconEnabledColor: AppColors.secondaryColor,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(_startDateTime == null
                        ? "Sélectionner la date et heure de début"
                        : "Début : ${dateFormat.format(_startDateTime!)}"),
                    trailing: const Icon(Icons.access_time),
                    onTap: () => _pickDateTime(isStart: true),
                  ),
                  ListTile(
                    title: Text(_endDateTime == null
                        ? "Sélectionner la date et heure de fin"
                        : "Fin : ${dateFormat.format(_endDateTime!)}"),
                    trailing: const Icon(Icons.access_time),
                    onTap: () => _pickDateTime(isStart: false),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Créer le rendez-vous"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}