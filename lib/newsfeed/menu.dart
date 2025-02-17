import 'package:comsit/login/controller/auth_controller.dart';
import 'package:comsit/newsfeed/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:comsit/login/loginscreen.dart'; // Adjust import paths as needed

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _username = "User Name"; // Default placeholder for username
  String _profileImageUrl = ""; // Default to empty to handle no profile picture
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch user details when the menu screen loads
  }

  // Fetch user profile details from the backend
  Future<void> _fetchUserProfile() async {
    try {
      final result = await _authController.fetchUserProfile();
      if (result['success']) {
        final userData = result['data'];
        setState(() {
          _username = userData['user_name'] ?? 'No username';
          _profileImageUrl = (userData['image'] != null && userData['image'].isNotEmpty)
              ? 'http://10.0.2.2:8000${userData['image']}'
              : ""; // Handle no profile image
        });
      } else {
        print('Error: ${result['message']}');
      }
    } catch (e) {
      print("Failed to load profile data: $e");
    }
  }

  // Logout function to navigate to the LoginScreen
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Menu',
          style: TextStyle(
            color: Color.fromARGB(255, 14, 80, 134),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        children: [
          // ListTile with dynamic username and profile picture
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade800,
              radius: 30,
              backgroundImage: _profileImageUrl.isNotEmpty
                  ? NetworkImage(_profileImageUrl)
                  : null,
              child: _profileImageUrl.isEmpty
                  ? Text(
                      _username.isNotEmpty ? _username[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            title: Text(
              _username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Navigate to ProfileScreen when tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          const Divider(), // Divider between items

          // Other menu items
          ListTile(
            leading: const Icon(Icons.people, color: Color.fromARGB(255, 18, 90, 148)),
            title: const Text(
              'Friends',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Navigate to SettingsScreen (or wherever you want to go)
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_books, color: Color.fromARGB(255, 19, 90, 148)),
            title: const Text(
              'FYP Library',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Navigate to Fyp libarary
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics, color: Color.fromARGB(255, 20, 93, 153)),
            title: const Text(
              'Analytics',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Navigate to HomeScreen (or wherever you want to go)
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Color.fromARGB(255, 18, 90, 148)),
            title: const Text(
              'Delete Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Navigate to delete profile (or wherever you want to go)
            },
          ),
          const Divider(), // Divider before logout option

          // Logout option at the bottom
          ListTile(
            leading: const Icon(Icons.logout, color: Color.fromARGB(255, 22, 97, 158)),
            title: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: _logout, // Handle logout when pressed
          ),
        ],
      ),
    );
  }
}
