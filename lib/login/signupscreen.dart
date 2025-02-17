import 'package:comsit/shared/loadingScreen.dart';
import 'package:flutter/material.dart';
import './controller/auth_controller.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}


class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String userName = '';
  String firstName = '';
  String lastName = '';
  String gender = '';
  String email = '';
  String department = '';

  // TextEditingControllers to capture password and confirm password
  final TextEditingController passwordController = TextEditingController();
  final AuthController _authController = AuthController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String? _formErrorMessage;
  final String emailPattern = r'^[A-Za-z0-9.-]+@ISBSTUDENT.COMSATS.EDU.PK$';

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (passwordController.text != confirmPasswordController.text) {
        setState(() {
          _formErrorMessage = 'Passwords do not match';
        });
        return;
      }


     
      
      showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingScreen();
      },
    );

      Map<String, dynamic>  result = await _authController.register(
        email: email,
        userName: userName,  
        password: passwordController.text.trim(),
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        department: department,
        about: '', 
      );

      print(result);

      Navigator.of(context,rootNavigator: true).pop();


      if (result['success']) {
        Navigator.pushNamed(context, '/otp_verification', arguments: email);
      } else {
          setState(() {
          if (result['success'] == true) {
            _formErrorMessage = null;
          } else {
            _formErrorMessage = result['message'] ;
          }
  });
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers when no longer needed
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 21, 101, 192),
                ),
              ),
              const SizedBox(height: 20),
              // First Name Input
              TextFormField(
                decoration: const InputDecoration(labelText: 'User Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your User name';
                  }
                  return null;
                },
                onSaved: (value) {
                  userName = value!;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
                onSaved: (value) {
                  firstName = value!;
                },
              ),
              const SizedBox(height: 10),
              // Last Name Input
              TextFormField(
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
                onSaved: (value) {
                  lastName = value!;
                },
              ),
              const SizedBox(height: 10),
              // Gender Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Gender'),
                 value: gender.isEmpty ? 'Others' : gender,
                items: ['Male', 'Female', 'Others']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    gender = value!;
                  });
                },
              ),
              const SizedBox(height: 10),
              // Email Input
              TextFormField(
                decoration: const InputDecoration(labelText: 'University Email'),
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
              const SizedBox(height: 10),
              // Department Input
              TextFormField(
                decoration: const InputDecoration(labelText: 'Department'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your department';
                  }
                  return null;
                },
                onSaved: (value) {
                  department = value!;
                },
              ),
              const SizedBox(height: 10),
              // Password Input
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Confirm Password Input
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Create Button
              ElevatedButton(
                onPressed: _createAccount,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue.shade800, // Button text color
                ),
                child: const Text('Create'),
              ),
              const SizedBox(height: 10),
              // Back to Login Button
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Already have an account? Login', style: TextStyle(color: Colors.purple)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
