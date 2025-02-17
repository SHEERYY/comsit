import 'package:comsit/login/controller/auth_controller.dart';
import 'package:comsit/shared/loadingScreen.dart';
import 'package:flutter/material.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  String email = '';
  final AuthController authController = AuthController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          const SizedBox(height: 20),
          const Text(
            'OTP VERIFICATION',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Color.fromARGB(255, 22, 108, 179),
            ),
          ),
          const SizedBox(height: 10),
          const Text(''),
          const SizedBox(height: 20),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter OTP sent to your email',
              border: OutlineInputBorder(),
            ),
          ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async{
                final otp = _otpController.text;

                 showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return LoadingScreen();
                    },
                  );

                if (otp.isNotEmpty) {
                  final response = await authController.verifyOtp(otp: otp);
                    Navigator.of(context,rootNavigator: true).pop();
                  if (response['success']) {

                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response['message'])),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter OTP')),
                  );
                }
              
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
