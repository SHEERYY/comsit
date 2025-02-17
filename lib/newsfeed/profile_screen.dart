import 'package:comsit/login/controller/auth_controller.dart';
import 'package:comsit/newsfeed/CommentScreen.dart';
import 'package:comsit/newsfeed/controller/commentController.dart';
import 'package:comsit/newsfeed/controller/postController.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For selecting images
import 'dart:io'; // For handling files
import 'package:http/http.dart' as http; // For backend requests
import 'dart:convert';

import 'package:provider/provider.dart'; // For decoding JSON

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = "User Name"; // Replace with fetched username
  String _bio = "Bio or user information goes here.";
  String _department = "";
  String _gender = "";
  String _profileImageUrl = "https://via.placeholder.com/150"; // Default image
  List<dynamic> _userPosts = []; // User posts fetched from the backend
  File? _selectedImage; // Selected image file for profile picture
  final AuthController _authController = AuthController();
  final PostController _postController = PostController();
  final TextEditingController _bioController = TextEditingController();
  int _currentPage = 1;
  bool _hasMorePosts = true;

  @override
  void initState() {

    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostFeedController>(context, listen: false).fetchInitialPosts();
    });
    _fetchUserProfile(); // Fetch user details on screen load
    _fetchUserPosts(); // Fetch user posts
  }

  // Fetch user profile details from the backend
  Future<void> _fetchUserProfile() async {
    try {
      final result = await _authController.fetchUserProfile();
      if (result['success']) {
        final userData = result['data'];
        setState(() {
          _username = userData['user_name'] ?? 'No username';
          _bio = userData['about'] ?? 'No bio';
          _department = userData['department'] ?? 'NO deparment';
          _gender = userData['gender'] ?? 'Pefer No to Say';
          _profileImageUrl = (userData['image'] != null && userData['image'].isNotEmpty)
            ? 'http://10.0.2.2:8000${userData['image']}'
            : ""; // Default to an empty string if no image
       });
      } else {
        print('Error: ${result['message']}');
        // Show error message to the user
      }
    } catch (e) {
      print("Failed to load profile data: $e");
    }
  }

  // Fetch user posts from the backend
  Future<void> _fetchUserPosts() async {
    try {
      final response = await _postController.fetchUserPosts(page: _currentPage);
      if (response != null) {
        
        setState(() {
          if (_currentPage == 1) {
            _userPosts = response['data']['results'];
          } else {
            _userPosts.addAll(response['data']['results']);
          }
          _hasMorePosts = response['data']['next'] != null;
          _currentPage++;
        });
      } else {
        print("Failed to load user posts");
      }
    } catch (e) {
      print("Failed to load user posts: $e");
    }
  }

  // Update profile picture
Future<void> _updateProfilePicture(File image) async {
    try {
      final result = await _authController.uploadProfileImage(image);
      print(result);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture updated successfully')),
        );
        
        _fetchUserProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to update profile picture')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
  }

  // Update bio
  Future<void> _updateBio(String bio) async {
    try {
        final result = await _authController.updateBio(bio);
    if (result['success']) {
      
      setState(() {
        _bio = bio;
      });

      print(result['message']);
    } else {
      // Handle error
      print(result['message']);
    }  
    } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
    
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      _updateProfilePicture(_selectedImage!);
    }
  }

  // Show bio editing dialog
  void _editBio() {
    _bioController.text = _bio; // Set current bio to the controller
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Bio'),
          content: TextField(
                        controller: _bioController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "Enter new bio",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateBio(_bioController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.symmetric(),
      color: const Color.fromARGB(255, 254, 255, 255),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color.fromARGB(255, 38, 113, 187), // Using a light color for background
                backgroundImage: post['author']['image'] != null 
                    ? NetworkImage(post['author']['image']) 
                    : null,
                child: post['author']['image'] == null 
                    ? Text(
                  post['author']['user_name'][0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ): null,
              ),
              const SizedBox(width: 8),
              Text(
                post['author']['user_name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Spacer(),
              IconButton(
                color: Colors.blue.shade800,
                icon: const Icon(Icons.more_vert, size: 20),
                onPressed: () => _showPostOptions(post),
                tooltip: 'More options',
              )
            ],
            ),
            const SizedBox(height: 8),
            Text(
              post['title'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            if (post['post_type'] == 'photo') ...[
              const SizedBox(height: 8),
              Image.network(
                'http://10.0.2.2:8000${post['image_url']}',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
              ),
            ],
            if (post['post_type'] == 'link') ...[
              const SizedBox(height: 8),
              Text(
                post['url'],
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ],
            if (post['post_type'] == 'text') ...[
              const SizedBox(height: 8),
              Text(
                post['content'] ?? '',
                style: const TextStyle(fontSize: 16, color: Color.fromARGB(232, 17, 17, 17)),
              ),
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post['is_liked'] ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        color: post['is_liked'] ? Colors.blue.shade800 : Colors.blue.shade800,
                      ),
                      onPressed: () {
                        print("jngnet");
                       Provider.of<PostFeedController>(context, listen: false).likePost(post['id']);
                       setState(() {
                         _gender = _gender;
                       });
                      },
                    ),
                    Text(
                      '${post['likes_count']} likes',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      color: Colors.blue.shade800,
                      onPressed: () {
                       Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider.value(
                              value: context.read<CommentController>(),
                              child: CommentScreen(post: post),
                            ),
                          ),
                        );
                      },
                    ),
                    Text(
                      '${post['comments_count']} comments',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  color: Colors.blue.shade800,
                  onPressed: () {
                    // Share post logic here
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

void _showPostOptions(Map<String, dynamic> post) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Post'),
              onTap: () {
                // Implement delete post logic
                // Provider.of<PostFeedController>(context, listen: false).deletePost(post['id']);
                // Navigator.pop(context); // Close the menu after deletion
              },
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
        backgroundColor: Colors.white,
            title: const Text('Profile',
               style: TextStyle(
                  color: Color.fromARGB(255, 14, 80, 134),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                   ),
                ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            if (_hasMorePosts) {
              _fetchUserPosts();
            }
          }
          return true;
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color.fromARGB(255, 19, 90, 148),
                      backgroundImage: _profileImageUrl.isNotEmpty && !_profileImageUrl.contains('placeholder')
                          ? NetworkImage(_profileImageUrl)
                          : null,
                      child: _profileImageUrl.isEmpty || _profileImageUrl.contains('placeholder')
                          ? Text(
                              _username.isNotEmpty ? _username[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Color.fromARGB(255, 12, 12, 12)),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Text(
                _username,
                style: const TextStyle(
                                    fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              // Display bio as text instead of text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: _editBio, // Call the edit bio function regardless of bio content
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center the bio
                    children: [
                      Text(
                        _bio.isNotEmpty ? _bio : 'Add Bio', // Show placeholder if no bio
                        style: TextStyle(
                          fontSize: 16,
                          color: _bio.isNotEmpty ? Colors.black : Colors.black54, // Grey for placeholder
                          fontStyle: _bio.isNotEmpty ? FontStyle.normal : FontStyle.italic, // Italic for placeholder
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Display bio as text instead of text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _department,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Display bio as text instead of text field
             
             
              const Divider(),
              const SizedBox(height: 16),
              _userPosts.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No posts to display.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _userPosts.length,
                      itemBuilder: (context, index) {
                        return _buildPostCard(_userPosts[index]);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}