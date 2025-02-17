import 'package:comsit/carpooling/carpoolingfeedscreen.dart';
// import 'package:comsit/login/controller/auth_controller.dart';
import 'package:comsit/newsfeed/SearchScreen.dart';
import 'package:comsit/newsfeed/commentScreen.dart';
import 'package:comsit/newsfeed/controller/commentController.dart';
import 'package:comsit/newsfeed/controller/postController.dart';
import 'package:comsit/newsfeed/friends.dart';
import 'package:comsit/newsfeed/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this import
// import 'dart:io';
import 'package:comsit/newsfeed/PostScreen.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({Key? key}) : super(key: key);

  @override
  _NewsFeedScreenState createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  // Define _staticScreens
  final List<Widget> _staticScreens = [
    CarpoolFeedScreen(),
    FriendRequestsScreen(),
    const Center(child: Text('Societies & Alumni Groups', style: TextStyle(fontSize: 18))),
    const Center(child: Text('Notifications', style: TextStyle(fontSize: 18))),
    MenuScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize feed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostFeedController>(context, listen: false).fetchInitialPosts();
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      Provider.of<PostFeedController>(context, listen: false).fetchPosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildFeedContent() {
    return Consumer<PostFeedController>(
      builder: (context, controller, child) {
        if (controller.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage ?? 'An error occurred'),
                ElevatedButton(
                  onPressed: () => controller.fetchInitialPosts(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.posts.isEmpty && controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.posts.isEmpty) {
          return const Center(
            child: Text(
              'No posts to show yet.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshPosts(),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: controller.posts.length + (controller.hasMorePosts ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.posts.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final post = controller.posts[index];
              return _buildPostCard(post);
            },
          ),
        );
      },
    );
  }
Widget _buildPostCard(Map<String, dynamic> post) {
  return Card(
    margin: const EdgeInsets.symmetric( ),
    color: const Color.fromARGB(255, 255, 255, 255),
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
              Spacer(), // Adds space between user name and the three dots button
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
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          if (post['post_type'] == 'photo') ...[
          Text(
            post['caption'] ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),

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
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
          if (post['post_type'] == 'text') ...[
            const SizedBox(height: 8),
            Text(
              post['content'] ?? '',
              style: const TextStyle(fontSize: 16, color: Color.fromARGB(232, 0, 0, 0)),
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
                      color: post['is_liked'] ? const Color.fromARGB(255, 21, 97, 158) : Colors.blue.shade800,
                    ),
                    onPressed: () {
                       Provider.of<PostFeedController>(context, listen: false).likePost(post['id']);
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
                      print("Somethinf Clocked");
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
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
  

void _showPostOptions(Map<String, dynamic> post) {
  // Replace with logic to get the current user's ID from your auth system
  String currentUserId = 'currentUserId'; // Replace this with actual current user ID logic
  
  // Check if the current user is the post owner
  bool isOwner = post['author']['id'] == currentUserId;

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOwner) // Show "Delete Post" option only for the owner's post
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Post'),
              onTap: () {
                // Implement delete post logic
                // Provider.of<PostFeedController>(context, listen: false).deletePost(post['id']);
                // Navigator.pop(context); // Close the menu after deletion
              },
            ),
          if (!isOwner) // Show "Report Post" option only for other posts
            ListTile(
              leading: const Icon(Icons.report, color: Colors.orange),
              title: const Text('Report Post'),
              onTap: () {
                // Implement report post logic
                // Provider.of<PostFeedController>(context, listen: false).reportPost(post['id']);
                // Navigator.pop(context); // Close the menu after reporting
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
      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: Colors.white,
              title: Text(
                'COMSIT',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: Colors.blue.shade800,
                  onPressed: () async {
                    final newPost = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PostScreen()),
                    );
                    if (newPost != null) {
                      Provider.of<PostFeedController>(context, listen: false)
                          .fetchInitialPosts();
                    }
                  },
                  tooltip: 'Create Post',
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  color: Colors.blue.shade800,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchScreen()),
                    );
                  },
                  tooltip: 'Search',
                ),

                IconButton(
                  icon: const Icon(Icons.message),
                  color: Colors.blue.shade800,
                  onPressed: () {},
                  tooltip: 'Messaging',
                ),
              ],
            )
          : null,
      body: _currentIndex == 0 ? _buildFeedContent() : _staticScreens[_currentIndex - 1],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Carpooling'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Societies & Alumni'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}