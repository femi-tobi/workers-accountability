import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'https://workers-accountable.onrender.com/api/auth';
  
  // TODO: Use secure storage for token in production
  static String? _token;

  static String? get token => _token;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Attempting login for $email');
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 60));

      print('Login response status: ${response.statusCode}');
      print('Login response body: "${response.body}"');

      if (response.body.isEmpty) {
         return {'success': false, 'message': 'Server returned an empty response.'};
      }

      final dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return {'success': false, 'message': 'Invalid server response format.'};
      }

      if (response.statusCode == 200) {
        if (data['token'] != null) {
          _token = data['token'];
        }
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false, 
          'message': data['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      print('Login Error: $e');
      if (e.toString().contains('TimeoutException')) {
        return {'success': false, 'message': 'Server is waking up (Free Tier). Please try again in a moment.'};
      }
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      print('Attempting register for ${userData['email']}');
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      ).timeout(const Duration(seconds: 60));
      
      print('Register response status: ${response.statusCode}');
      print('Register response body: "${response.body}"');

      if (response.body.isEmpty) {
         return {'success': false, 'message': 'Server returned an empty response.'};
      }

      final dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return {'success': false, 'message': 'Invalid server response format.'};
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false, 
          'message': data['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      print('Register Error: $e');
      if (e.toString().contains('TimeoutException')) {
        return {'success': false, 'message': 'Server is waking up (Free Tier). Please try again in a moment.'};
      }
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<List<Map<String, String>>> getExecutives() async {
    try {
      final response = await http.get(
        Uri.parse('https://workers-accountable.onrender.com/api/enums/executives'),
      ).timeout(const Duration(seconds: 60));

      print('Executives API Response: "${response.body}"'); // Debug

      if (response.body.isEmpty) {
        return [];
      }

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        // Handle specific structure: { success: true, data: { executives: [...] } }
        if (decoded is Map<String, dynamic> && 
            decoded.containsKey('data') && 
            decoded['data'] is Map<String, dynamic> &&
            decoded['data']['executives'] is List) {
              
          final List<dynamic> rawList = decoded['data']['executives'];
          return rawList.map<Map<String, String>>((item) {
            final String name = item['fullName']?.toString() ?? 'Unknown';
            final String position = item['position']?.toString() ?? '';
            final String id = item['id']?.toString() ?? '';
            
            return {
              'label': position.isNotEmpty ? '$name ($position)' : name,
              'value': id
            };
          }).toList();
        }
        
        return [];
      } else {
        throw Exception('Failed to load executives');
      }
    } catch (e) {
      print('Get Executives Error: $e');
      return []; // Return empty list on error to avoid crashing UI
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      if (_token == null) return {'success': false, 'message': 'No token found'};

      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 60));

      print('Get Profile Response: "${response.body}"'); // Debug

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch profile'};
      }
    } catch (e) {
      print('Get Profile Error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ).timeout(const Duration(seconds: 10));
      }
    } catch (e) {
      print('Logout Error: $e');
      // Continue with local logout even if API fails
    } finally {
      _token = null;
    }
  }
}
