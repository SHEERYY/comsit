import 'package:flutter/material.dart';

class FriendRequest {
  final String name;
  final String profileImage;
  final String mutualFriends;
  final String timeAgo;

  FriendRequest({
    required this.name,
    required this.profileImage,
    required this.mutualFriends,
    required this.timeAgo,
  });
}

class FriendRequestsScreen extends StatefulWidget {
  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List<FriendRequest> friendRequests = [
    FriendRequest(
        name: "Ali",
        profileImage: "assets/avatar1.png",
        mutualFriends: "286 mutual friends",
        timeAgo: "1d"),
    // Add more requests here
  ];

  List<String> friendSuggestions = [
    "Muhammad Waleed",
  ];

  void confirmRequest(int index) {
    setState(() {
      friendRequests.removeAt(index);
    });
  }

  void deleteRequest(int index) {
    setState(() {
      friendRequests.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Friend Requests",
        style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
        ),
      ),
      body: ListView.builder(
        itemCount: friendRequests.length + 1,
        itemBuilder: (context, index) {
          if (index < friendRequests.length) {
            final request = friendRequests[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(request.profileImage),
              ),
              title: Text(request.name),
              subtitle: Text("${request.mutualFriends} \u2022 ${request.timeAgo}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      confirmRequest(index);
                    },
                    child: Text("Confirm"),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      deleteRequest(index);
                    },
                    child: Text("Delete"),
                  ),
                ],
              ),
            );
          } else {
            return _FriendSuggestions(suggestions: friendSuggestions);
          }
        },
      ),
    );
  }
}

class _FriendSuggestions extends StatelessWidget {
  final List<String> suggestions;

  const _FriendSuggestions({required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "People you may know",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...suggestions.map((suggestion) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(suggestion[0]),
              ),
              title: Text(suggestion),
              trailing: ElevatedButton(
                onPressed: () {},
                child: Text("Add Friend"),
              ),
            )),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FriendRequestsScreen(),
  ));
}
