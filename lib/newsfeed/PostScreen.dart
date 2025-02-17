import 'package:comsit/newsfeed/controller/postController.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

enum PostType { text, photo, video, link }

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final PostController _postController = PostController(); 
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  
  File? _selectedMedia;
  final ImagePicker _picker = ImagePicker();
  PostType _currentPostType = PostType.text;
  bool _isPosting = false;

  Future<void> _pickMedia(bool isImage) async {
    final XFile? pickedFile = await (isImage
        ? _picker.pickImage(source: ImageSource.gallery)
        : _picker.pickVideo(source: ImageSource.gallery));
    
    if (pickedFile != null) {
      setState(() {
        _selectedMedia = File(pickedFile.path);
        _currentPostType = isImage ? PostType.photo : PostType.video;
      });
    }
  }

  Future<void> _createPost() async {
    if (_isPosting) return;

    setState(() {
      _isPosting = true;
    });

    try {
      Map<String, dynamic>? result;

      switch (_currentPostType) {
        case PostType.text:
          if (_textController.text.isEmpty) {
            _showErrorSnackBar('Please enter something');
            return;
          }
          result = await _postController.createTextPost(
            content: _textController.text
          );
          break;
        
        case PostType.photo:
          if (_selectedMedia == null) {
            _showErrorSnackBar('Please select a photo');
            return;
          }
          result = await _postController.createPhotoPost(
            imageFile: _selectedMedia!,
            caption: _textController.text
          );
          break;
        
        case PostType.video:
          if (_selectedMedia == null) {
            _showErrorSnackBar('Please select a video');
            return;
          }
          result = await _postController.createVideoPost(
            videoFile: _selectedMedia!,
            caption: _textController.text
          );
          break;
        
        case PostType.link:
          if (_linkController.text.isEmpty) {
            _showErrorSnackBar('Please enter a valid link');
            return;
          }
          result = await _postController.createLinkPost(
            url: _linkController.text,
            title: _titleController.text
          );
          break;
      }

      if (result != null) {
        _showSuccessSnackBar('Post created successfully');
        Navigator.pop(context, result);
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Create Post',
        style: TextStyle(
                  color: Color.fromARGB(255, 22, 99, 161),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
        ),
        foregroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Post Type Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text('Text'),
                    selected: _currentPostType == PostType.text,
                    onSelected: (_) => setState(() {
                      _currentPostType = PostType.text;
                    }),
                  ),
                  SizedBox(width: 10),
                  ChoiceChip(
                    label: Text('Photo'),
                    selected: _currentPostType == PostType.photo,
                    onSelected: (_) => setState(() {
                      _currentPostType = PostType.photo;
                    }),
                  ),
                  SizedBox(width: 10),
                  ChoiceChip(
                    label: Text('Video'),
                    selected: _currentPostType == PostType.video,
                    onSelected: (_) => setState(() {
                      _currentPostType = PostType.video;
                    }),
                  ),
                  SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Link'),
                    selected: _currentPostType == PostType.link,
                    onSelected: (_) => setState(() {
                      _currentPostType = PostType.link;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Content Input
              if (_currentPostType == PostType.text || 
                  _currentPostType == PostType.photo || 
                  _currentPostType == PostType.video)
                TextField(
                  controller: _textController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: _currentPostType == PostType.text 
                      ? 'What\'s on your mind?' 
                      : 'Add a caption...',
                    border: OutlineInputBorder(),
                  ),
                ),

              // Link Input
              if (_currentPostType == PostType.link)...[
              TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _linkController,
                  decoration: const InputDecoration(
                    hintText: 'Enter URL',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Media Preview
              if (_selectedMedia != null && 
                  (_currentPostType == PostType.photo || _currentPostType == PostType.video))
                _selectedMedia!.path.endsWith('.mp4')
                    ? Icon(Icons.videocam, size: 100, color: Colors.blue.shade800)
                    : Image.file(
                        _selectedMedia!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),

              // Media Selection Buttons
              if (_currentPostType == PostType.photo )
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.image, color: Colors.blue.shade800),
                      onPressed: () => _pickMedia(true),
                    ),
                    
                  ],
                ),
                if ( _currentPostType == PostType.video)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    
                    IconButton(
                      icon: Icon(Icons.videocam, color: Colors.blue.shade800),
                      onPressed: () => _pickMedia(false),
                    ),
                  ],
                ),
                
                

              const SizedBox(height: 16),

              // Post Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                ),
                onPressed: _isPosting ? null : _createPost,
                child: _isPosting 
                  ? CircularProgressIndicator(color: Colors.white)
                  : const Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _linkController.dispose();
    super.dispose();
  }
}