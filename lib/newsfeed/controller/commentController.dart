import 'dart:convert';
import 'package:comsit/login/controller/auth_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CommentController extends ChangeNotifier {
  final AuthController _authController;
  final String _baseUrl;

  CommentController(this._authController, this._baseUrl);

  List<Map<String, dynamic>> _comments = [];
  List<Map<String, dynamic>> get comments => _comments;

  int _currentPage = 1;
  bool hasMoreComments = true;
  bool _isLoading = false;

  bool _hasError = false;
  String _errorMessage = '';
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  String _handleError(dynamic error) {
    if (kDebugMode) {
      print('Feed Fetch Error: $error');
    }

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
  
  Future<void> fetchComments(int postId) async {
    print('Fetching comments for post $postId');
    try {
      final response = await _authController.makeAuthenticatedRequest(
        '$_baseUrl/post/$postId/comments/',
        'GET',
      );

      print('Comments response: ${response.body}');
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> comments = responseData['data']['results'] ?? [];

      print('Parsed comments: $comments');
      _comments = comments.map((comment) => comment as Map<String, dynamic>).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  Future<bool> addComment(int postId, String content, {int? parentCommentId}) async {
    try {
      final Map<String, dynamic> requestBody = {
        'content': content,
        if (parentCommentId != null) 'parent_comment_id': parentCommentId,
      };

      final response = await _authController.makeAuthenticatedRequest(
        '$_baseUrl/post/$postId/comments/',
        'POST',
        body: json.encode(requestBody),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);
      
      if (responseData['success']) {
        // Insert the new comment at the beginning of the list
        _comments.insert(0, responseData['comment']);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _hasError = true;
      _errorMessage = _handleError(e);
      notifyListeners();
      return false;
    }
  }

  void resetComments() {
    _comments.clear();
    _currentPage = 1;
    hasMoreComments = true;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    print("Being disposed");
    resetComments();
    super.dispose();
  }
}