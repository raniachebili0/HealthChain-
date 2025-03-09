
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/services/doctor_service.dart';
import 'package:health_chain/widgets/doctor_item.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final DoctorService doctorService = DoctorService();
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: null,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Color(0xFF949393)),
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor: Color(0xFFCBE0F3),
          ),
          onChanged: (value) {
            // Handle search text changes
          },
        ),
                  ),
                  Padding(
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
                    // Add a geometric pattern image
                    width: 400,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
        
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
                    SizedBox(height: 10),
                    Text(
                      'We  provide best quality medical\nservices without further cost.',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        // Add your onPressed code here!
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue[900],
                        padding: EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text('Check Now'),
                    ),
                  ],
                ),
                
              ),
            ],
          ),
        ),
                  ),
                  SizedBox(
        height: 210.h,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: doctorService.getAllDoctors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No doctors found"));
              } else {
                final doctors = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return DoctorCard(doctor: doctor);
                  },
                );
              }
            },
          ),
        ),
                  )
                ],
              ),
            )));
  }
}
