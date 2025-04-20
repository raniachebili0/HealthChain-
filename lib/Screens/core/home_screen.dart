import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/core/docter_detailles_screnn.dart';
import 'package:health_chain/Screens/core/home_view_model.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:health_chain/widgets/doctor_item.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load doctors when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadDoctors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();

    return Scaffold(
      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeaderCard(homeViewModel),
                _buildPopularDoctorsSection(homeViewModel),
                _buildDoctorsList(homeViewModel),
                _buildUpcomingAppointmentsSection(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => homeViewModel.navigateToChat(context),
        backgroundColor: Colors.blue,
        child: Icon(Icons.message_rounded),
      ),
    );
  }

  Widget _buildHeaderCard(HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        height: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Opacity(
              opacity: 0.2,
              child: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/imeges/hexagon_pattern.jpg',
                  width: 400,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Get the Best \nMedical Services',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'We  provide best quality medical\nservices without further cost.',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: viewModel.checkNow,
                    child: Text('Check Now'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue[900],
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularDoctorsSection(HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Popular Doctors',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 19,
              color: AppColors.secondaryColor2,
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () => viewModel.navigateToDoctorsList(context),
            child: Text(
              'See All',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList(HomeViewModel viewModel) {
    return Container(
      height: 210.h,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
        child: viewModel.isLoading
            ? Center(child: CircularProgressIndicator())
            : viewModel.error != null
                ? Center(child: Text("Error: ${viewModel.error}"))
                : viewModel.doctors == null || viewModel.doctors!.isEmpty
                    ? Center(child: Text("No doctors found"))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: viewModel.doctors!.length < 6
                            ? viewModel.doctors!.length
                            : 6,
                        itemBuilder: (context, index) {
                          final doctor = viewModel.doctors![index];
                          return DoctorCard(
                            doctor: doctor,
                            onTap: () => viewModel.navigateToDoctorDetails(
                                context, doctor),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildUpcomingAppointmentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Upcoming Appointments',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 19,
                  color: AppColors.secondaryColor2,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          AppointmentCard(
            day: "Tue",
            date: "12",
            time: "09:30 AM",
            doctorName: "Dr. Mim Ankht",
            specialty: "Depression",
          ),
          SizedBox(height: 10),
          AppointmentCard(
            day: "Tue",
            date: "16",
            time: "09:30 AM",
            doctorName: "Dr. Mim Ankht",
            specialty: "Depression",
          ),
          SizedBox(height: 10),
          AppointmentCard(
            day: "Tue",
            date: "12",
            time: "09:30 AM",
            doctorName: "Dr. Mim Ankht",
            specialty: "Depression",
          ),
        ],
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String day;
  final String date;
  final String time;
  final String doctorName;
  final String specialty;

  const AppointmentCard({
    Key? key,
    required this.day,
    required this.date,
    required this.time,
    required this.doctorName,
    required this.specialty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue.shade900,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  doctorName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  specialty,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
