import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final String count;
  final Color backgroundColor;

  const NotificationBadge({
    Key? key,
    required this.count,
    this.backgroundColor = const Color(0xFF4CAF50),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
} 