import 'package:flutter/material.dart';
import './controller/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authController = AuthController();
  String email = '';
  String? _formErrorMessage;

  final String emailPattern = r'^[A-Za-z0-9.-]+@ISBSTUDENT\.COMSATS\.EDU\.PK$';

  void _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const Center(child: CircularProgressIndicator());
        },
      );
          try {
            Map<String, dynamic> response = await _authController.requestPasswordReset(email);

            Navigator.pop(context);

            if (response['success']) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response['message']),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushReplacementNamed(context, '/otp_reset');
            } else {
              setState(() {
                _formErrorMessage = response['message'];
              });
            }
          } catch (e) {
            Navigator.pop(context);
            setState(() {
              _formErrorMessage = 'An error occurred. Please try again later.';
            });
          }


    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 21, 101, 192),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Enter your University Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || !RegExp(emailPattern).hasMatch(value)) {
                    return 'Please enter a valid university email (e.g. FA21-BDS-019@ISBSTUDENT.COMSATS.EDU.PK)';
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value!; // Save the email in lowercase
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendResetLink,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue.shade800, // Button text color set to white
                ),
                child: const Text('Send OTP'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Back to Login', style: TextStyle(color: Colors.purple)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
