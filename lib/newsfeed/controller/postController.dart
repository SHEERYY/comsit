import 'dart:io';
import 'package:comsit/login/controller/auth_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class PostController {
  final Dio _dio = Dio();
  final AuthController _authController = AuthController();

  // Base URL for your API
  static const String _baseUrl = 'http://10.0.2.2:8000/post';

  // Generic method to create a post with improved error handling
Future<Map<String, dynamic>?> createPost({
  required String postType,
  required Map<String, dynamic> postData,
}) async {
  try {
    dynamic requestData;
    if (postType == 'photo' || postType == 'video') {
      // For photo or video posts, use Dio for multipart requests
      bool refreshed = await _authController.refreshAccessToken();

      var dio = Dio();
      
      // Create a FormData object
      var formData = FormData.fromMap({
        'post_type': postType,
        ...postData,
      });

      // If you have file uploads, make sure to add them like this:
      // if (postData['file'] != null) {
      //   formData.files.add(MapEntry(
      //     'file', 
      //     await MultipartFile.fromFile(postData['file'].path, filename: 'upload')
      //   ));
      // }

      final response = await dio.post(
        '$_baseUrl/create/post/',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _authController.getAccessToken()}',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Dio returns the response data directly
      return response.data;
    } else {
      // For text posts, use the existing authentication method
      final response = await _authController.makeAuthenticatedRequest(
        '$_baseUrl/create/post/',
        'POST',
        body: {
          'post_type': postType,
          ...postData,
        },
      );

      // Parse the response body
      return json.decode(response.body);
    }
  } catch (e) {
    print('Post Creation Error: $e');
    return null;
  }
}
  // Modify other methods similarly
  Future<Map<String, dynamic>?> createTextPost({
    required String content,
    String? caption,
  }) async {
    return createPost(
      postType: 'text',
      postData: {
        'content': content,
        if (caption != null) 'caption': caption,
      },
    );
  }

  Future<Map<String, dynamic>?> createPhotoPost({
    required File imageFile,
    String? caption,
  }) async {
    return createPost(
      postType: 'photo',
      postData: {
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        if (caption != null) 'caption': caption,
      },
    );
  }

  Future<Map<String, dynamic>?> createVideoPost({
      required File videoFile,
      String? caption,
    }) async {
      return createPost(
        postType: 'video',
        postData: {
          'video': await MultipartFile.fromFile(
            videoFile.path,
            filename: videoFile.path.split('/').last,
          ),
          if (caption != null) 'caption': caption,
        },
      );
    }

    Future<Map<String, dynamic>?> createLinkPost({
      required String url,
      String? title,
    }) async {
      return createPost(
        postType: 'link',
        postData: {
          'url': url,
          if (title != null) 'title': title,
        },
      );
    }

  // Similar modifications for other post creation methods

  // Fetch User Feed
  Future<List<dynamic>> fetchFeed() async {
    try {
      final response = await _authController.makeAuthenticatedRequest(
        '$_baseUrl/feed/',
        'GET',
      );

      return json.decode(response.body);
    } catch (e) {
      print('Feed Fetch Error: $e');
      return [];
    }
  }
  Future<Map<String, dynamic>?> fetchUserPosts({
          int page = 1,
          int pageSize = 10,
    }) async {
      try {
        final url = '$_baseUrl/user/posts/?page=$page&page_size=$pageSize';
        final response = await _authController.makeAuthenticatedRequest(
          url,
          'GET',
        );

        return json.decode(response.body);
      } catch (e) {
        print('User Posts Fetch Error: $e');
        return null;
      }
    }
}

class PostFeedController extends ChangeNotifier {
  final AuthController _authController = AuthController();
  static const String _baseUrl = 'http://10.0.2.2:8000/post';
  
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMorePosts = true;

  // Getters remain the same
  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get hasMorePosts => _hasMorePosts;

  // Fetch initial posts
  Future<void> fetchInitialPosts() async {
    _posts = [];
    _currentPage = 1;
    _hasMorePosts = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
    
    await fetchPosts();
  }

  // Fetch posts with pagination
  Future<void> fetchPosts() async {
    if (_isLoading || !_hasMorePosts) return;

    try {
      _isLoading = true;
      _hasError = false;
      notifyListeners();

      final response = await _authController.makeAuthenticatedRequest(
        '$_baseUrl/feed/?page=$_currentPage',
        'GET',
      );

      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      print(results);
      _hasMorePosts = data['next'] != null;

      if (results.isEmpty) {
        _hasMorePosts = false;
      } else {
        _posts.addAll(results.map((post) => post as Map<String, dynamic>));
        _currentPage++;
      }

    } catch (e) {
      _hasError = true;
      _errorMessage = _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh posts
  Future<void> refreshPosts() async {
    _currentPage = 1;
    _posts = [];
    _hasMorePosts = true;
    await fetchPosts();
  }

  String _handleError(dynamic error) {
    if (kDebugMode) {
      print('Feed Fetch Error: $error');
    }

    // Customize error handling based on the type of error
    if (error is http.Response) {
      switch (error.statusCode) {
        case 401:
          return 'Unauthorized. Please log in again.';
        case 403:
          return 'You do not have permission to access this feed';
        case 404:
          return 'No posts found';
        default:
          return 'Failed to fetch posts: ${error.body}';
      }
    } else {
      return 'Network error. Please check your connection.';
    }
  }

  Future<void> likePost(int postId) async {
    try {
      final response = await _authController.makeAuthenticatedRequest(
        '$_baseUrl/like/post/$postId/',
        'POST',
      );

      // Parse the response
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      
      final postIndex = _posts.indexWhere((post) => post['id'] == postId);
      
      // If post is found, update its data
      if (postIndex != -1) {
        // Update the entire post object with the new data
        _posts[postIndex] = responseData['post'];
        notifyListeners();
      }
    } catch (e) {
      // Error handling similar to other methods
      if (kDebugMode) {
        print('Like Post Error: $e');
      }
      
      // Optional: You might want to show an error to the user
      // This could be done through a separate method or using a state variable
      _hasError = true;
      _errorMessage = _handleError(e);
      notifyListeners();
    }
  }

  
}