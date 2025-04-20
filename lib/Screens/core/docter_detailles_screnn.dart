import 'package:flutter/material.dart';
import 'package:health_chain/services/document_service.dart';
import 'package:provider/provider.dart';
import 'package:health_chain/Screens/core/doctor_details_view_model.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailsScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DoctorDetailsViewModel(doctor: doctor),
      child: _DoctorDetailsView(),
    );
  }
}

class _DoctorDetailsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DoctorDetailsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'doctor_photo_${viewModel.doctor['_id']}',
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(viewModel.doctorPhoto),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.doctorName,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.doctorEmail,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      viewModel.doctorPhone,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      context,
                      'Bio',
                      viewModel.doctorBio,
                      Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      context,
                      'Address',
                      viewModel.doctorAddress,
                      Icons.location_on,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      context,
                      'Schedules',
                      viewModel.doctorSchedules,
                      Icons.schedule,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AppointmentFormDialog();
                            },
                          );
                          // viewModel.navigateToCreateAppointment(context)
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Book Appointment'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, String title, String content, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentFormDialog extends StatefulWidget {
  const AppointmentFormDialog({
    super.key,
  });

  @override
  _AppointmentFormDialogState createState() => _AppointmentFormDialogState();
}

class _AppointmentFormDialogState extends State<AppointmentFormDialog> {
  final _formKey = GlobalKey<FormState>();

  String? selectedDoctorId;
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Take your appointment'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                  'Choose a time slot between 8 AM and 12 PM or between 2 PM and 5 PM, except on Sundays.'),
              // Start Date
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                    );

                    if (pickedTime != null) {
                      final combined = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      setState(() => startDate = combined);
                    }
                  }
                },
                child: Text(
                  startDate != null
                      ? 'Start: ${startDate!.toLocal()}'
                      : 'Select Start Date & Time',
                ),
              ),

              // End Date
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                    );

                    if (pickedTime != null) {
                      final combined = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      setState(() => endDate = combined);
                    }
                  }
                },
                child: Text(
                  endDate != null
                      ? 'End: ${endDate!.toLocal()}'
                      : 'Select End Date & Time',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;

            // Prepare your data object
            final appointment = {
              'DebuitDate': startDate?.toIso8601String(),
              'FinDate': endDate?.toIso8601String(),
            };

            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
