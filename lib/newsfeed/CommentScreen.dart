// import 'package:comsit/login/controller/auth_controller.dart';
import 'package:comsit/newsfeed/controller/commentController.dart';
import 'package:comsit/newsfeed/controller/postController.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class CommentScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const CommentScreen({Key? key, required this.post}) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  late ScrollController _scrollController;
  late CommentController _commentFetchController;
  int? _replyToCommentId;
  // late final CommentController _actualCommentController;

  @override
  void initState() {
  super.initState();
  
  _scrollController = ScrollController()
    ..addListener(_scrollListener);

  // Call fetchComments directly
   WidgetsBinding.instance.addPostFrameCallback((_) {
      _commentFetchController = Provider.of<CommentController>(context, listen: false);
      _commentFetchController.fetchComments(widget.post['id']);
    });
}


  void _scrollListener() {
    final commentController = Provider.of<CommentController>(context, listen: false);
    
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      commentController.fetchComments(widget.post['id']);
    }
  }

  void _submitComment() async {
    final commentController = Provider.of<CommentController>(context, listen: false);
    
    if (_commentController.text.trim().isNotEmpty) {
      bool success = await commentController.addComment(
        widget.post['id'], 
        _commentController.text.trim(),
        parentCommentId: _replyToCommentId
      );

      if (success) {
        _commentController.clear();
        setState(() {
          _replyToCommentId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments',
        style: TextStyle(
                  color: Color.fromARGB(255, 23, 97, 158),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
        ),
      ),
      body: Column(
        children: [
          // Post Display Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info
                Row(
                  children: [
                        CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color.fromARGB(255, 38, 113, 187), // Using a light color for background
                    backgroundImage: widget.post['author']['image'] != null 
                        ? NetworkImage(widget.post['author']['image']) 
                        : null,
                    child: widget.post['author']['user_name'] == null 
                        ? Text(
                      widget.post['author']['user_name'][0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ): null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.post['author']['user_name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Post Content based on type
                if (widget.post['post_type'] == 'photo') ...[
                  Image.network(
                    'http://10.0.2.2:8000${widget.post['image_url']}',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  ),
                ],
                if (widget.post['post_type'] == 'text') ...[
                  Text(
                    widget.post['content'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
                if (widget.post['post_type'] == 'link') ...[
                  Text(
                    widget.post['url'] ?? '',
                    style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 21, 98, 161)),
                  ),
                ],

                // Interaction Section
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Like Button
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            widget.post['is_liked'] 
                              ? Icons.thumb_up 
                              : Icons.thumb_up_alt_outlined,
                            color: widget.post['is_liked'] 
                              ? const Color.fromARGB(255, 22, 99, 161) 
                              : Colors.blue.shade800,
                          ),
                          onPressed: () {
                            Provider.of<PostFeedController>(
                              context, 
                              listen: false
                            ).likePost(widget.post['id']);
                          },
                        ),
                        Text(
                          '${widget.post['likes_count']} likes',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    // Comments Count
                    Row(
                      children: [
                        const Icon(Icons.comment_outlined, color: Color.fromARGB(255, 21, 95, 156)),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.post['comments_count']} comments',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
          child: Consumer<CommentController>(
            builder: (context, commentController, child) {
              if (commentController.comments.isEmpty) {
                return const Center(child: Text('No comments yet'));
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification &&
                      _scrollController.position.atEdge &&
                      _scrollController.position.pixels != 0 &&
                      commentController.hasMoreComments) {
                    commentController.fetchComments(widget.post['id']);
                  }
                  return false;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: commentController.comments.length,
                  itemBuilder: (context, index) {
                    return _buildCommentItem(commentController.comments[index]);
                  },
                ),
              );
            },
          ),
        ),
          
          
          // Comment Input Area
          _buildCommentInputArea(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return ListTile(
      leading:  CircleAvatar(
                radius: 20,
                backgroundColor: const Color.fromARGB(255, 38, 113, 187), // Using a light color for background
                backgroundImage: comment['user']['image'] != null 
                    ? NetworkImage(comment['user']['image']) 
                    : null,
                child: comment['user']['user_name'] == null 
                    ? Text(
                  comment['user']['user_name'][0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ): null,
              ),
      title: Text(comment['user']['user_name']),
      subtitle: Text(comment['content']),
      );
  }


  Widget _buildCommentInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: _replyToCommentId != null 
                  ? '' 
                  : 'Add a comment...',
                suffixIcon: _replyToCommentId != null
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _replyToCommentId = null;
                        });
                      },
                    )
                  : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submitComment,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
     WidgetsBinding.instance.addPostFrameCallback((_) {
    _commentFetchController.resetComments();
  });
    // _actualCommentController.dispose();
    super.dispose();
  }
}