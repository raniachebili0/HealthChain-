import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: StreamBuilder<Object>(
              stream: null,
              builder: (context, snapshot) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ClipOval(
                      child: Image.network(
                        "http://10.0.2.2:3000/uploads/your-image.jpg",
                        width: 100, // Set width
                        height: 100, // Set height
                        fit: BoxFit.cover, // Ensures the image fills the circle
                      ),
                    )
                  ],
                );
              })),
    );
  }
}
