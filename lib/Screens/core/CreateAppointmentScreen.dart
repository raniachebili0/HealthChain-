import 'package:flutter/material.dart';
import 'package:health_chain/services/user_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CreateAppointmentScreen extends StatefulWidget {
  final String doctorId;
  final Map<String, dynamic>? doctorData;

  const CreateAppointmentScreen({
    Key? key, 
    required this.doctorId, 
    this.doctorData,
  }) : super(key: key);

  @override
  _CreateAppointmentScreenState createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final UserService _userService = UserService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(Duration(days: 2));
  TimeOfDay _selectedTime = TimeOfDay(hour: 10, minute: 0);
  
  bool _isLoading = false;
  int _selectedDayIndex = 2; // Default to the middle date (e.g., Wednesday)

  // Time slot options
  final List<String> _timeSlots = [
    "09:00 AM", 
    "10:00 AM", 
    "11:00 AM", 
    "02:00 PM", 
    "03:00 PM", 
    "04:00 PM", 
    "07:00 PM"
  ];

  // Type options (enum)
  final List<String> _typeOptions = [
    "appointment",
    "consultation",
    "checkup"
  ];

  // Selected time slot
  String? _selectedTimeSlot = "10:00 AM";
  
  // Selected appointment type
  String? _selectedType = "consultation";
  
  // Calculate start and end times
  DateTime? _calculatedStartTime;
  DateTime? _calculatedEndTime;

  @override
  void initState() {
    super.initState();
    // Set the selected time slot to 10:00 AM initially
    _selectedTimeSlot = _timeSlots[1];
    // Set default type
    _selectedType = _typeOptions[1]; // "consultation"
    // Calculate initial appointment times
    _updateAppointmentTimes();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // Update appointment times based on selected date and time slot
  void _updateAppointmentTimes() {
    if (_selectedTimeSlot != null) {
      // Parse the time slot
      final timeParts = _selectedTimeSlot!.split(' ');
      final timeValue = timeParts[0];
      final period = timeParts[1];
      
      final hourMinute = timeValue.split(':');
      int hour = int.parse(hourMinute[0]);
      final int minute = int.parse(hourMinute[1]);
      
      // Convert to 24-hour format if PM
      if (period == 'PM' && hour < 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      // Create start date time
      _calculatedStartTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
        minute,
      );

      // End time is 1 hour after start time
      _calculatedEndTime = _calculatedStartTime!.add(Duration(hours: 1));
    }
  }

  // Generate list of dates (today + 6 days)
  List<DateTime> _generateDates() {
    final now = DateTime.now();
    return List.generate(
      7, 
      (index) => DateTime(now.year, now.month, now.day + index)
    );
  }

  // Day abbreviation
  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  void _submitAppointment() async {
    if (_formKey.currentState!.validate() && 
        _selectedTimeSlot != null && 
        _selectedType != null) {
      
      setState(() {
        _isLoading = true;
      });

      try {
        // Format as ISO 8601 string
        final startDateTimeString = _calculatedStartTime!.toIso8601String();
        final endDateTimeString = _calculatedEndTime!.toIso8601String();

        final appointmentData = {
          "doctorId": widget.doctorId,
          "startDateTime": startDateTimeString,
          "endDateTime": endDateTimeString,
          "reason": _reasonController.text.trim(),
          "type": _selectedType
        };

        print("Creating appointment with data: $appointmentData");
        final result = await _userService.createAppointment(appointmentData);
        print("Appointment created successfully: $result");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Appointment booked successfully!"),
            backgroundColor: Colors.green,
          )
        );

        // Navigate back after successful booking
        Navigator.pop(context, true);
      } catch (e) {
        print("Error creating appointment: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to book appointment: $e"),
            backgroundColor: Colors.red,
          )
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in all required fields"),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = _generateDates();
    
    // Get doctor name safely
    String doctorName = "";
    if (widget.doctorData != null) {
      if (widget.doctorData!.containsKey('name') && widget.doctorData!['name'] != null) {
        doctorName = widget.doctorData!['name'];
      } else if (widget.doctorData!.containsKey('fullName') && widget.doctorData!['fullName'] != null) {
        doctorName = widget.doctorData!['fullName'];
      } else if (widget.doctorData!.containsKey('firstName') && widget.doctorData!['firstName'] != null) {
        String firstName = widget.doctorData!['firstName'];
        String lastName = widget.doctorData!.containsKey('lastName') && widget.doctorData!['lastName'] != null 
            ? widget.doctorData!['lastName'] 
            : "";
        doctorName = "$firstName $lastName".trim();
      } else {
        doctorName = "Doctor";
      }
    } else {
      doctorName = "Doctor";
    }
    
    // Get doctor specialization safely
    String doctorSpecialization = "";
    if (widget.doctorData != null) {
      if (widget.doctorData!.containsKey('specialization') && widget.doctorData!['specialization'] != null) {
        doctorSpecialization = widget.doctorData!['specialization'];
      } else if (widget.doctorData!.containsKey('specialty') && widget.doctorData!['specialty'] != null) {
        doctorSpecialization = widget.doctorData!['specialty'];
      } else if (widget.doctorData!.containsKey('specialties') && widget.doctorData!['specialties'] != null && 
                widget.doctorData!['specialties'] is List && widget.doctorData!['specialties'].isNotEmpty) {
        doctorSpecialization = widget.doctorData!['specialties'][0];
      } else {
        doctorSpecialization = "Specialist";
      }
    } else {
      doctorSpecialization = "Specialist";
    }
    
    // Get doctor photo URL
    String? photoUrl = null;
    if (widget.doctorData != null) {
      if (widget.doctorData!.containsKey('photo') && widget.doctorData!['photo'] != null && widget.doctorData!['photo'] != "null") {
        photoUrl = widget.doctorData!['photo'];
      } else if (widget.doctorData!.containsKey('profilePicture') && widget.doctorData!['profilePicture'] != null && 
                widget.doctorData!['profilePicture'] != "null") {
        photoUrl = widget.doctorData!['profilePicture'];
      } else if (widget.doctorData!.containsKey('avatar') && widget.doctorData!['avatar'] != null && 
                widget.doctorData!['avatar'] != "null") {
        photoUrl = widget.doctorData!['avatar'];
      }
    }
    
    // Build full URL if needed
    if (photoUrl != null && !photoUrl.startsWith('http')) {
      photoUrl = kIsWeb 
          ? "http://localhost:3006$photoUrl"  // Web browser
          : "http://10.0.2.2:3006$photoUrl";  // Android emulator
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book Appointment',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Profile Section
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: photoUrl != null && photoUrl.startsWith('http')
                        ? Image.network(
                            photoUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/imeges/defultDoctor.jpg',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/imeges/defultDoctor.jpg',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. $doctorName',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            doctorSpecialization,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '4.7',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Date Selection Section Title
              Padding(
                padding: EdgeInsets.only(left: 16, top: 20, right: 16, bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      'Select Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Calendar Day Selector
              Container(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dates.length,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    final isSelected = index == _selectedDayIndex;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDayIndex = index;
                          _selectedDate = date;
                          _updateAppointmentTimes();
                        });
                      },
                      child: Container(
                        width: 50,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.teal : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.teal : Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getDayAbbreviation(date.weekday),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Time Selection Section Title
              Padding(
                padding: EdgeInsets.only(left: 16, top: 20, right: 16, bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      'Select Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Time Slots
              Padding(
                padding: EdgeInsets.all(16),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _timeSlots.map((timeSlot) {
                    final isSelected = timeSlot == _selectedTimeSlot;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTimeSlot = timeSlot;
                          _updateAppointmentTimes();
                        });
                      },
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 50) / 3,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.teal : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? Colors.teal : Colors.grey.shade300,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          timeSlot,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              // Appointment Summary Card
              if (_calculatedStartTime != null && _calculatedEndTime != null)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.date_range, size: 18, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            'Date: ${DateFormat('EEEE, MMMM d, y').format(_calculatedStartTime!)}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 18, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            'Time: ${DateFormat('h:mm a').format(_calculatedStartTime!)} - ${DateFormat('h:mm a').format(_calculatedEndTime!)}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              
              // Appointment Type Dropdown
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Appointment Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(Icons.medical_services, color: Colors.teal),
                  ),
                  items: _typeOptions.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type.substring(0, 1).toUpperCase() + type.substring(1),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                  value: _selectedType,
                  validator: (value) => value == null ? 'Please select an appointment type' : null,
                ),
              ),
              
              // Reason Text Field
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Enter reason for your visit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(Icons.description, color: Colors.teal),
                  ),
                  maxLines: 2,
                  validator: (value) => value == null || value.trim().isEmpty 
                      ? 'Please enter a reason for your visit' 
                      : null,
                ),
              ),
              
              SizedBox(height: 20),
              
              // Book Appointment Button
              Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Center(
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Book Appointment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
