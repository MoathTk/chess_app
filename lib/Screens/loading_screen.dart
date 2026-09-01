import 'dart:async';
import 'package:flutter/material.dart';

class LoadingMatchScreen extends StatefulWidget {
  const LoadingMatchScreen({super.key});

  @override
  State<LoadingMatchScreen> createState() => _LoadingMatchScreenState();
}

class _LoadingMatchScreenState extends State<LoadingMatchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Setup Pulsing Animation for the Icon
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 2. The 3-Second Timer to Navigate Away
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Replace with your actual home or game board route
        // Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Colors.orangeAccent;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Matching your app's theme
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing Logo Section
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.grid_view_rounded, // Replace with your App Icon
                  size: 50,
                  color: accentColor,
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Text Info
            const Text(
              "PREPARING MATCH",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Setting up the board...",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),

            const SizedBox(height: 40),

            // Modern Progress Bar
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: Color(0xFF2C2C2C),
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
