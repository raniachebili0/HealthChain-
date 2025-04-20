import 'package:flutter/material.dart';
import 'dart:math';

class RandomMovingWidget extends StatefulWidget {
  @override
  _RandomMovingWidgetState createState() => _RandomMovingWidgetState();
}

class _RandomMovingWidgetState extends State<RandomMovingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  final Random _random = Random();
  final double _widgetSize = 100.0; // Size of the moving widget

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Duration of each movement
    )..repeat(); // Repeat the animation indefinitely

    // Generate the first random position
    _animation = Tween<Offset>(
      begin: _generateRandomOffset(),
      end: _generateRandomOffset(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Smooth easing curve
    ));

    // Listen for animation completion to generate a new random position
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animation = Tween<Offset>(
            begin: _animation.value,
            end: _generateRandomOffset(),
          ).animate(CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ));
        });
        _controller.forward(from: 0.0); // Restart the animation
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Generate a random Offset within the screen boundaries
  Offset _generateRandomOffset() {
    final double maxX = MediaQuery.of(context).size.width - _widgetSize;
    final double maxY = MediaQuery.of(context).size.height - _widgetSize;
    return Offset(
      _random.nextDouble() * maxX,
      _random.nextDouble() * maxY,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: _animation.value.dx,
          top: _animation.value.dy,
          child: Container(
            width: _widgetSize,
            height: _widgetSize,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }
}

///////////////////*****************************///////////////////////
class AnimatedRandomWidgetScreen extends StatefulWidget {
  const AnimatedRandomWidgetScreen({super.key});

  @override
  _AnimatedRandomWidgetScreenState createState() =>
      _AnimatedRandomWidgetScreenState();
}

class _AnimatedRandomWidgetScreenState extends State<AnimatedRandomWidgetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _startAnimation();
  }

  void _startAnimation() {
    final double newX =
        _random.nextDouble() * 2 - 1; // Random value between -1 and 1
    final double newY = _random.nextDouble() * 2 - 1;

    _animation = Tween<Offset>(
      begin: _animation?.value ?? Offset.zero,
      end: Offset(newX, newY),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward(from: 0).whenComplete(_startAnimation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return FractionalTranslation(
              translation: _animation.value,
              child: child,
            );
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
