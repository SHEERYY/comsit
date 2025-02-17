import 'package:comsit/shared/loadingScreen.dart';
import 'package:flutter/material.dart';
import './controller/auth_controller.dart';


class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = AuthController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  String? _formErrorMessage;

  void _login() async {

     final emailPattern = RegExp(r'^[\w\.-]+@ISBSTUDENT\.COMSATS\.EDU\.PK$');
    if (_usernameController.text.isEmpty || !emailPattern.hasMatch(_usernameController.text.trim())) {
        print("reached emal");
      setState(() {
        _formErrorMessage = 'Email must be in the format *@ISBSTUDENT.COMSATS.EDU.PK';
      });
      return;
    }

    // Manual validation for password length
    if (_passwordController.text.isEmpty || _passwordController.text.length < 8) {
        print("reached password");
      setState(() {
        _formErrorMessage = 'Enter Valid Password';
      });
      return;
    }

    // Clear any existing error message before showing the loading screen
    setState(() {
      _formErrorMessage = null;
    });

    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingScreen();
      },
    );

    
    Map<String, dynamic> response = await _authController.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    Navigator.of(context,rootNavigator: true).pop();

    if (response["success"]) {
    debugPrint('Next Success');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showErrorModal(response["message"]);
    }
  }


  void _showErrorModal(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:Form(
          key: _formKey,
          child: ListView(
            children:<Widget>[
              // Big Text Section
              Center(
                child: Text(
                  'COMSIT', // Replace with your desired text
                  style: TextStyle(
                    fontSize: 32, // Adjust the font size for "big" text
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 21, 101, 192), // Change the color as needed
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const Text(
              '',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
             if (_formErrorMessage != null) // Show error message if available
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _formErrorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
            const SizedBox(height: 20),
             TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.mail)
                ),
              ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
              ),
             
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _login();
                // Handle login logic here
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 21, 101, 192)),
              child: const Text('Login' , style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgot_password');
              },
              child: const Text('Forgot Password?', style: TextStyle(color: Color.fromARGB(255, 156, 39, 176))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text('Don’t have an account? Sign Up', style: TextStyle(color: Color.fromRGBO(21, 101, 192, 1))),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
