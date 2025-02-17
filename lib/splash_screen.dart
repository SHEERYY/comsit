import 'package:flutter/material.dart';
import 'dart:async';
import 'package:comsit/login/loginscreen.dart'; // Import the LoginScreen
import 'package:animated_text_kit/animated_text_kit.dart'; // For text animation

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Define the sliding animation (slide upward)
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(0, -1)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Set a timer to start the swipe animation after the text animation finishes
    Timer(const Duration(seconds: 6), () {
      _controller.forward(); // Start the slide animation after 6 seconds
      // After the slide animation completes, navigate to the login screen
      Timer(const Duration(milliseconds: 600), () { // Reduced time to 800ms
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to LoginScreen
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color of splash screen
      body: SlideTransition(
        position: _slideAnimation, // Apply slide animation to the whole screen
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated "COMSIT" text
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'COMSIT',
                    textStyle: const TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 21, 99, 163),
                    ),
                    speed: const Duration(milliseconds: 600),
                  ),
                ],
                totalRepeatCount: 1,
                isRepeatingAnimation: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
