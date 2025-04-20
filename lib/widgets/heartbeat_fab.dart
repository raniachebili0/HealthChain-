import 'package:flutter/material.dart';
import 'package:health_chain/utils/colors.dart';

class HeartbeatFAB extends StatefulWidget {
  final VoidCallback? onPressed;

  const HeartbeatFAB({super.key, this.onPressed});
  @override
  _HeartbeatFABState createState() => _HeartbeatFABState();
}

class _HeartbeatFABState extends State<HeartbeatFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
 
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true); // Keeps pulsing
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: FloatingActionButton.extended(
        onPressed: widget.onPressed,
        icon: Icon(Icons.calendar_month, color: Colors.white),
        label: Text("Add Appointment"),
         backgroundColor: AppColors.primaryColor,
      ),
    );
  }
}
