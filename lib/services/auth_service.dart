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
        // Response structure: { "success": true, "data": { "user": {...}, "tokens": { "accessToken": "..." } } }
        if (data is Map && data.containsKey('data') && data['data'] is Map) {
          final innerData = data['data'];
          
          // Extract Token
          if (innerData['tokens'] != null && innerData['tokens']['accessToken'] != null) {
            _token = innerData['tokens']['accessToken'];
          } else if (innerData['token'] != null) {
             _token = innerData['token'];
          }

          return {'success': true, 'data': innerData};
        } 
        
        // Fallback for flat structure
        if (data is Map && data['token'] != null) {
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

  Future<List<Map<String, dynamic>>> getExecutives() async {
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
          return rawList.map<Map<String, dynamic>>((item) {
            return {
              'id': item['id']?.toString() ?? '',
              'fullName': item['fullName']?.toString() ?? 'Unknown',
              'email': item['email']?.toString() ?? '',
              'position': item['position']?.toString() ?? '',
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
        
        // Handle: { "data": { "user": { ... } } }
        if (data is Map && data.containsKey('data') && data['data'] is Map) {
          final innerData = data['data'];
          if (innerData['user'] != null && innerData['user'] is Map) {
             return {'success': true, 'data': innerData['user']};
          }
          // Fallback for { "data": { ... } } (flat user in data)
          return {'success': true, 'data': innerData};
        }

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
  // =======================================================================
  // Discipline APIs
  // =======================================================================

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      if (_token == null) return {'success': false, 'message': 'No token found'};

      final response = await http.get(
        Uri.parse('https://workers-accountable.onrender.com/api/disciplines/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
         final data = jsonDecode(response.body);
         // Structure: { success: true, data: { dashboard: { ... } } }
         if (data['success'] == true && data['data'] != null) {
           return {'success': true, 'data': data['data']['dashboard']};
         }
         return {'success': false, 'message': 'Invalid dashboard data'};
      }
      return {'success': false, 'message': 'Failed to fetch dashboard stats'};
    } catch (e) {
      print('Get Dashboard Stats Error: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  Future<Map<String, dynamic>> getCurrentWeekDisciplines() async {
    try {
      if (_token == null) return {'success': false, 'message': 'No token found'};

      final response = await http.get(
        Uri.parse('https://workers-accountable.onrender.com/api/disciplines/current-week'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 60));

      print('Current Week Response: ${response.body}');

      if (response.statusCode == 200) {
         final data = jsonDecode(response.body);
         if (data['success'] == true && data['data'] != null) {
           // Unwrap 'weeklyDiscipline' if present
           if (data['data']['weeklyDiscipline'] != null) {
             return {'success': true, 'data': data['data']['weeklyDiscipline']};
           }
           return {'success': true, 'data': data['data']};
         }
         return {'success': false, 'message': 'Invalid discipline data'};
      }
      return {'success': false, 'message': 'Failed to fetch current week'};
    } catch (e) {
      print('Get Current Week Error: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  Future<Map<String, dynamic>> saveDisciplineProgress(List<Map<String, dynamic>> disciplines) async {
    try {
      if (_token == null) return {'success': false, 'message': 'No token found'};

      final payload = {'disciplines': disciplines};
      print('Saving Discipline Payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse('https://workers-accountable.onrender.com/api/disciplines/save'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 60));

      print('Save Response: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Progress saved successfully'};
      }
      return {'success': false, 'message': 'Failed to save progress'};
    } catch (e) {
      print('Save Discipline Error: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  Future<Map<String, dynamic>> saveReflection(String reflection) async {
    try {
      if (_token == null) return {'success': false, 'message': 'No token found'};

      final payload = {'reflection': reflection};
      final response = await http.post(
        Uri.parse('https://workers-accountable.onrender.com/api/disciplines/reflection'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 30));

      print('Save Reflection Response: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Reflection saved successfully'};
      }
      return {'success': false, 'message': 'Failed to save reflection'};
    } catch (e) {
      print('Save Reflection Error: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  Future<List<dynamic>> getPreviousWeeksDisciplines() async {
    try {
      if (_token == null) return [];

      final response = await http.get(
        Uri.parse('https://workers-accountable.onrender.com/api/disciplines/previous-weeks?limit=4'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
         final data = jsonDecode(response.body);
         if (data['success'] == true && data['data'] != null && data['data']['weeks'] != null) {
           return data['data']['weeks'];
         }
      }
      return [];
    } catch (e) {
      print('Get Previous Weeks Error: $e');
      return [];
    }
  }


  // Executive Endpoints
  Future<Map<String, dynamic>> getExecutiveDashboardStats() async {
    try {
      if (_token == null) return {'success': false, 'message': 'No token'};
      final response = await http.get(
        Uri.parse('https://workers-accountable.onrender.com/api/executive/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true ? data['data'] : {};
      }
      return {};
    } catch (e) {
      print('Exec Stats Error: $e');
      return {};
    }
  }

  Future<List<dynamic>> getExecutiveWorkers() async {
    try {
      if (_token == null) return [];
      final response = await http.get(
        Uri.parse('https://workers-accountable.onrender.com/api/executive/workers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['workers'] ?? [];
      }
      return [];
    } catch (e) {
      print('Exec Workers Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getExecutiveWorkersProgress() async {
    try {
      if (_token == null) return [];
      final response = await http.get(
        Uri.parse('https://workers-accountable.onrender.com/api/executive/workers/progress'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // data['data']['workers'] contains the list with progress
        return data['data']['workers'] ?? [];
      }
      return [];
    } catch (e) {
      print('Exec Progress Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getWorkerDetails(String workerId) async {
    try {
      if (_token == null) return {};
      final response = await http.get(
        Uri.parse('https://workers-accountable.onrender.com/api/executive/workers/$workerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      }
      return {};
    } catch (e) {
      print('Worker Details Error: $e');
      return {};
    }
  }

  Future<List<dynamic>> getWorkerHistory(String workerId) async {
    try {
      if (_token == null) return [];
      final response = await http.get(
        Uri.parse('https://workers-accountable.onrender.com/api/executive/workers/$workerId/history'),
        headers: {
           'Content-Type': 'application/json',
           'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['history'] ?? [];
      }
      return [];
    } catch (e) {
      print('Worker History Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getExecutiveReflections() async {
    try {
       if (_token == null) return [];
      final response = await http.get(
        Uri.parse('https://workers-accountable.onrender.com/api/executive/reflections'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
         final data = jsonDecode(response.body);
        return data['data']['reflections'] ?? [];
      }
      return [];
    } catch (e) {
      print('Exec Reflections Error: $e');
      return [];
    }
  }
}
