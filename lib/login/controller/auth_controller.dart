import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  final String apiUrl = 'http://10.0.2.2:8000'; 

  Future<Map<String, dynamic>> login(String username, String password) async {

    final response = await http.post(
      Uri.parse('$apiUrl/api/token/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'email': username,
      'password': password,
    }),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final String accessToken = responseData['access'];
      final String refreshToken = responseData['refresh'];
      // Save tokens in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', accessToken);
      await prefs.setString('refreshToken', refreshToken);

      return {
      'success': true,
      'message': 'Login successful',
        };
    }
    if (response.statusCode == 401) {
     
      return {
      'success': false,
      'message': 'No active account found with the given credentials',
        };
    } 
    return {
      'success': false,
      'message': 'Unkown error, Try later',
      };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  Future<bool> refreshAccessToken() async {
    final String? refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      return false;
    }

    final response = await http.post(
      Uri.parse('$apiUrl/api/token/refresh/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'refresh': refreshToken,  
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final String newAccessToken = responseData['access'];  
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', newAccessToken);
      return true;
    } else {
      await logout();
      return false;
    }
  }



  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    // If the access token is missing or expired, try refreshing it
    if (accessToken == null) {
      return await refreshAccessToken();
    }
    return true;
  }

// Replace with your API URL

  Future<Map<String, dynamic>> register({
    required String email,
    required String userName,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
    required String department,
    required String about,
  }) async {
    final response = await http.post(
      Uri.parse('$apiUrl/account/register/'), 
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'user_name': userName,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender,
        'department': department,
        'about': about,
      }),
    );

    print(response.body);
    if (response.statusCode == 201) {

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', email);
      return {
        'success': true,
        'message': 'Registration successful. You can now log in.',
      };
    } else {
      // final data = json.decode(response.body);
      // print(data);
      try{
        print('Headers: ${response.headers}');
      }catch(e){
            print(e);}
      return {
        'success': false,
        'message':  'Invalid input. Please check your details.',
      };
    }
  }

  // Verify OTP function
  Future<Map<String, dynamic>> verifyOtp({
    required String otp,
  }) async {
    print(otp);
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');
    print(email);
    final response = await http.post(
      Uri.parse('$apiUrl/account/verify-otp/'), 
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'otp': otp
      }),
    );
    print(response.body);
    if (response.statusCode == 200) {
      await prefs.remove('userEmail');
      return {
        'success': true,
        'message': 'OTP verified successfully!',
      };
    } else if (response.statusCode == 400) {
      final responseData = json.decode(response.body);
      return {
        'success': false,
        'message': responseData['detail'] ?? 'Invalid OTP. Please try again.',
      };
    } else {
      return {
        'success': false,
        'message': 'An unknown error occurred while verifying OTP.',
      };
    }
  }


  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
      try {
        final response = await http.post(
          Uri.parse('$apiUrl/account/password-reset-request/'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'email': email,
          }),
        );

        print(response.body);

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('reset_email', email);
          return {
            'success': true,
            'message': 'Password reset email sent successfully',
          };
        } else if (response.statusCode == 404) {
          return {
            'success': false,
            'message': 'No account found with this email address',
          };
        } else if (response.statusCode == 400) {
          final responseData = json.decode(response.body);
          return {
            'success': false,
            'message': responseData['detail'] ?? 'Invalid email address',
          };
        } else {
          return {
            'success': false,
            'message': 'An unknown error occurred. Please try again later',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Network error occurred. Please check your connection',
        };
      }
  }


    Future<Map<String, dynamic>> verifyPasswordReset({
    required String otp,
    required String newPassword,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('reset_email');
      print(email);
      print(otp);
      print(newPassword);
      if (email == null) {
        return {
          'success': false,
          'message': 'Reset email not found. Please try again.',
        };
      }

      final response = await http.post(
        Uri.parse('$apiUrl/account/password-reset-verification/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'otp': otp,
          'new_password': newPassword,
        }),
      );

      print(response.body);
      if (response.statusCode == 200) {
        await prefs.remove('reset_email');
        
        return {
          'success': true,
          'message': 'Password reset successful. You can now login with your new password.',
        };
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);
        return {
          'success': false,
          'message': responseData['detail'] ?? 'Invalid OTP or password. Please try again.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Reset request not found or expired.',
        };
      } else {
        return {
          'success': false,
          'message': 'An unknown error occurred. Please try again later.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred. Please check your connection.',
      };
    }
  }

Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
  try {
    // Construct the multipart request URL
    final url = '$apiUrl/account/upload-profile-picture/';

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Get the access token
    String? accessToken = await getAccessToken();

    // If no access token, try to refresh
    if (accessToken == null) {
      bool refreshed = await refreshAccessToken();
      if (!refreshed) {
        throw Exception('Unable to refresh token');
      }
      accessToken = await getAccessToken();
    }

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $accessToken';

    // Add the image file to the request
    request.files.add(await http.MultipartFile.fromPath(
      'profile_picture', 
      imageFile.path,
    ));

    // Send the request
    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    // Create a http.Response from the MultipartResponse
    final response = http.Response(
      responseBody, 
      streamedResponse.statusCode,
      headers: streamedResponse.headers,
    );

    // Handle 401 (Unauthorized) - attempt to refresh token
    if (response.statusCode == 401) {
      bool refreshed = await refreshAccessToken();
      if (refreshed) {
        // Retry the upload with new token
        accessToken = await getAccessToken();
        
        // Recreate the request with new token
        request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers['Authorization'] = 'Bearer $accessToken';
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture', 
          imageFile.path,
        ));

        // Send the new request
        final retryStreamedResponse = await request.send();
        final retryResponseBody = await retryStreamedResponse.stream.bytesToString();

        final retryResponse = http.Response(
          retryResponseBody, 
          retryStreamedResponse.statusCode,
          headers: retryStreamedResponse.headers,
        );

        // Process the retry response
        if (retryResponse.statusCode == 200) {
          final responseData = json.decode(retryResponse.body);
          return {
            'success': true,
            'message': 'Profile picture uploaded successfully',
            'data': responseData,
          };
        } else {
          return {
            'success': false,
            'message': 'Failed to upload profile picture',
            'statusCode': retryResponse.statusCode,
          };
        }
      } else {
        await logout();
        throw Exception('Authentication failed');
      }
    }

    // Process the initial response
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return {
        'success': true,
        'message': 'Profile picture uploaded successfully',
        'data': responseData,
      };
    } else {
      return {
        'success': false,
        'message': 'Failed to upload profile picture',
        'statusCode': response.statusCode,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'An error occurred: ${e.toString()}',
    };
  }
}

      Future<http.Response> makeAuthenticatedRequest(
      String url, 
      String method, 
      {Map<String, String>? headers, 
      Object? body}
    ) async {
      String? accessToken = await getAccessToken();

      if (accessToken == null) {
        bool refreshed = await refreshAccessToken();
        if (!refreshed) {
          throw Exception('Unable to refresh token');
        }
        accessToken = await getAccessToken();
      }

      Map<String, String> authHeaders = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        ...?headers
      };

      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(Uri.parse(url), headers: authHeaders);
          break;
        case 'POST':
          response = await http.post(
            Uri.parse(url), 
            headers: authHeaders, 
            body: json.encode(body)
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse(url), 
            headers: authHeaders, 
            body: json.encode(body)
          );
          break;
        case 'DELETE':
          response = await http.delete(Uri.parse(url), headers: authHeaders);
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      // If the access token has expired, try to refresh and retry the request
      if (response.statusCode == 401) {
        bool refreshed = await refreshAccessToken();
        if (refreshed) {
          accessToken = await getAccessToken();
          authHeaders['Authorization'] = 'Bearer $accessToken';

          switch (method.toUpperCase()) {
            case 'GET':
              response = await http.get(Uri.parse(url), headers: authHeaders);
              break;
            case 'POST':
              response = await http.post(
                Uri.parse(url), 
                headers: authHeaders, 
                body: json.encode(body)
              );
              break;
            case 'PUT':
              response = await http.put(
                Uri.parse(url), 
                headers: authHeaders, 
                body: json.encode(body)
              );
              break;
            case 'DELETE':
              response = await http.delete(Uri.parse(url), headers: authHeaders);
              break;
          }
        } else {
          await logout();
          throw Exception('Authentication failed');
        }
      }

      return response;
    }


    Future<Map<String, dynamic>> fetchUserProfile() async {
    final url = 'http://10.0.2.2:8000/account/user/'; // Adjust endpoint
    final response = await makeAuthenticatedRequest(url, 'GET');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data['data']);
      return data;
    } else {
      throw Exception('Failed to load profile data');
    }
  }

    Future<Map<String, dynamic>> updateBio(String bio) async {
      try {
        final url = '$apiUrl/account/update-bio/';
        
        final response = await makeAuthenticatedRequest(
          url, 
          'PUT', 
          body: {'bio': bio}
        );

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': 'Bio updated successfully',
          };
        } else {
          return {
            'success': false,
            'message': 'Failed to update bio',
            'statusCode': response.statusCode,
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'An error occurred: ${e.toString()}',
        };
      }
    }
}
