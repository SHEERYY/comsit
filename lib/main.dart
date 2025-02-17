import 'package:comsit/login/ResetOtpScreen.dart';
import 'package:comsit/login/forgotpassword.dart'; 
import 'package:comsit/login/controller/auth_controller.dart'; // Import AuthController
import 'package:comsit/newsfeed/controller/commentController.dart';
import 'package:comsit/newsfeed/controller/postController.dart';
import 'package:comsit/newsfeed/home.dart';
import 'package:comsit/login/loginscreen.dart';
import 'package:comsit/login/otpverificationscreen.dart';
import 'package:comsit/login/signupscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthController should be a singleton for the entire app
        Provider<AuthController>(
          create: (_) => AuthController(), 
          // If AuthController requires any initialization, do it here
        ),
        
        // PostFeedController is typically recreated for each feed
        ChangeNotifierProvider<PostFeedController>(
          create: (context) => PostFeedController(),
        ),
        
        // CommentController can be created on-demand
        ChangeNotifierProvider<CommentController>(
          create: (context) => CommentController(
            context.read<AuthController>(), 
            'http://10.0.2.2:8000', // Your base URL
          ),
        ),
      ],
      child: MaterialApp(
        title: 'COMSIT',
        theme: ThemeData(
          primaryColor: Colors.blue,
          hintColor: Colors.purple,
          scaffoldBackgroundColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/forgot_password': (context) => ForgotPasswordScreen(),
          '/otp_verification': (context) => OtpVerificationScreen(),
          '/otp_reset': (context) => ResetOtpScreen(),
          '/home': (context) => NewsFeedScreen(),
        },
      ),
    );
  }
}