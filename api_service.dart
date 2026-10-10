import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}
class ApiService {
  static const String baseUrl = 'http://10.77.56.11:8000';

  static Future<Map<String, dynamic>> _request(
    Future<http.Response> request,
  ) async {
    try {
      final response = await request.timeout(const Duration(seconds: 10));
      Map<String, dynamic> data = {};

      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            data = decoded;
          }
        } catch (_) {}
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }
      throw ApiException(
        data['detail']?.toString() ??
            'Server error (${response.statusCode}).',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unable to connect to FieldX server.');
    }
  }
  static Future<Map<String, dynamic>> login({
    required String officerId,
    required String password,
  }) {
    return _request(
      http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'officer_id': officerId,
          'password': password,
        }),
      ),
    );
  }

  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String officerId,
    required String mobileNo,
    required String password,
    required String confirmPassword,
  }) {
    return _request(
      http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'officer_id': officerId,
          'mobile_no': mobileNo,
          'password': password,
          'confirm_password': confirmPassword,
        }),
      ),
    );
  }

  static Future<Map<String, dynamic>> createLandParcel({
    required String surveyNumber,
    required String ownerName,
    required double area,
    required double latitude,
    required double longitude,
    required String address,
  }) {
    return _request(
      http.post(
        Uri.parse('$baseUrl/land-parcel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'survey_number': surveyNumber,
          'owner_name': ownerName,
          'area': area,
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
        }),
      ),
    );
  }

  static Future<Map<String, dynamic>> getLandParcels() {
    return _request(http.get(Uri.parse('$baseUrl/land-parcels')));
  }

  static Future<Map<String, dynamic>> createSurvey({
    required int parcelId,
    required int userId,
  }) {
    return _request(
      http.post(
        Uri.parse('$baseUrl/survey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'parcel_id': parcelId,
          'user_id': userId,
        }),
      ),
    );
  }

  static Future<Map<String, dynamic>> sync({
    required List<Map<String, dynamic>> surveys,
  }) {
    return _request(
      http.post(
        Uri.parse('$baseUrl/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'surveys': surveys}),
      ),
    );
  }
}
