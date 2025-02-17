import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateCarpoolPostScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onPostCreated; // Callback to update feed

  CreateCarpoolPostScreen({required this.onPostCreated});

  @override
  _CreateCarpoolPostScreenState createState() =>
      _CreateCarpoolPostScreenState();
}

class _CreateCarpoolPostScreenState extends State<CreateCarpoolPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _driverNameController = TextEditingController();
  final _pickupController = TextEditingController();
  final _classStartController = TextEditingController();
  final _classEndController = TextEditingController();
  final _daysController = TextEditingController();
  final _seatsController = TextEditingController();

  File? _uploadedTimetableImage;
  bool _isPosting = false;
  String? _selectedRoute;  // Variable to store selected route

  final List<String> _routes = [
    'Murree Road',
    'IJP Road',
    'Sirinagar Highway',
    'Tramri',
  ];

  @override
  void dispose() {
    _driverNameController.dispose();
    _pickupController.dispose();
    _classStartController.dispose();
    _classEndController.dispose();
    _daysController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _uploadedTimetableImage = File(pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Timetable image uploaded successfully!')),
      );
    }
  }

  void _postRide() async {
    if (!_formKey.currentState!.validate()) return;

    if (_uploadedTimetableImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload your timetable image')),
      );
      return;
    }

    if (_selectedRoute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a route')),
      );
      return;
    }

    setState(() {
      _isPosting = true; // Start showing loading indicator
    });

    // Simulate a post creation delay (can be replaced with real backend logic)
    await Future.delayed(Duration(seconds: 2));

    final post = {
      'driverName': _driverNameController.text.trim(),
      'pickupLocation': _pickupController.text.trim(),
      'classStartTime': _classStartController.text.trim(),
      'classEndTime': _classEndController.text.trim(),
      'daysToUniversity': int.parse(_daysController.text.trim()),
      'availableSeats': int.parse(_seatsController.text.trim()),
      'timetableImage': _uploadedTimetableImage,
      'selectedRoute': _selectedRoute,  // Store the selected route
    };

    widget.onPostCreated(post); // Pass post to feed callback

    setState(() {
      _isPosting = false; // Stop showing loading indicator
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ride Posted Successfully!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue.shade800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Post',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Driver Name
                TextFormField(
                  controller: _driverNameController,
                  decoration: InputDecoration(labelText: 'Driver Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter driver name' : null,
                ),
                // Pickup Location
                TextFormField(
                  controller: _pickupController,
                  decoration: InputDecoration(labelText: 'Driver Location'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter location' : null,
                ),
                // Class Start Time
                TextFormField(
                  controller: _classStartController,
                  decoration: InputDecoration(labelText: 'Class Start Time (e.g., 8:00 AM)'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter class start time' : null,
                ),
                // Class End Time
                TextFormField(
                  controller: _classEndController,
                  decoration: InputDecoration(labelText: 'Class End Time (e.g., 3:00 PM)'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter class end time' : null,
                ),
                // Days Driver Goes to University
                TextFormField(
                  controller: _daysController,
                  decoration: InputDecoration(labelText: 'University Days'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter number of University days' : null,
                ),
                // Available Seats
                TextFormField(
                  controller: _seatsController,
                  decoration: InputDecoration(labelText: 'Available Seats'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter number of available seats';
                    if (int.tryParse(value) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Route Selection
                Text(
                  'Select Your Route',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedRoute,
                  hint: Text('Select a route'),
                  items: _routes.map((route) {
                    return DropdownMenuItem<String>(
                      value: route,
                      child: Text(route),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRoute = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null ? 'Please select a route' : null,
                ),
                SizedBox(height: 20),
                // Timetable Image Upload
                Text(
                  'Upload Your Timetable Image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.photo, color: Colors.blue.shade800),
                  label: Text(
                    '',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ),
                if (_uploadedTimetableImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.file(
                      _uploadedTimetableImage!,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 20),
                // Post Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  onPressed: _isPosting ? null : _postRide,
                  child: _isPosting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Post',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

