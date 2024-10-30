import 'package:comsit/login/forgotpassword.dart';
import 'package:comsit/login/loginscreen.dart';
import 'package:comsit/login/otpverificationscreen.dart';
import 'package:comsit/login/signupscreen.dart';
import 'package:flutter/material.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COMSIT',
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/forgot_password': (context) => ForgotPasswordScreen(),
        '/otp_verification': (context) => OtpVerificationScreen(),
      },
    );
  }
}