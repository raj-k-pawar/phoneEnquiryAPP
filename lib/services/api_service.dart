import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/user_model.dart';
import '../models/batch_model.dart';
import '../models/enquiry_model.dart';
import '../models/manager_model.dart';
import '../models/batch_report_model.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 25);

  // ─── Sanitize response body ───────────────────────────────────────────────
  // InfinityFree injects HTML like <html><body><script src="/aes.js">...
  // before the actual PHP output. This strips it and finds the JSON.
  static String _sanitize(String body) {
    final trimmed = body.trim();
    // Already clean JSON
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) return trimmed;

    // Try to find JSON object inside HTML
    final jsonStart = trimmed.indexOf('{');
    final jsonStartArr = trimmed.indexOf('[');

    int start = -1;
    if (jsonStart != -1 && jsonStartArr != -1) {
      start = jsonStart < jsonStartArr ? jsonStart : jsonStartArr;
    } else if (jsonStart != -1) {
      start = jsonStart;
    } else if (jsonStartArr != -1) {
      start = jsonStartArr;
    }

    if (start != -1) {
      // Find matching closing brace/bracket from the end
      final sub = trimmed.substring(start);
      // Find last } or ]
      final lastBrace   = sub.lastIndexOf('}');
      final lastBracket = sub.lastIndexOf(']');
      final end = lastBrace > lastBracket ? lastBrace : lastBracket;
      if (end != -1) return sub.substring(0, end + 1);
    }

    // Could not extract JSON — return original to let error surface clearly
    return trimmed;
  }

  static Map<String, dynamic> _decode(http.Response res) {
    try {
      final clean = _sanitize(res.body);
      return jsonDecode(clean) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Server returned invalid response. '
            'Check your API URL and server setup.\n'
            'HTTP ${res.statusCode}',
      };
    }
  }

  // ─── HTTP helpers ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> _post(
      String url, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-Requested-With': 'XMLHttpRequest',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _decode(res);
    } catch (e) {
      return {'success': false, 'message': 'Connection failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> _get(String url) async {
    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(_timeout);
      return _decode(res);
    } catch (e) {
      return {'success': false, 'message': 'Connection failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> _put(
      String url, Map<String, dynamic> body) async {
    try {
      final res = await http
          .put(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _decode(res);
    } catch (e) {
      return {'success': false, 'message': 'Connection failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> _delete(String url) async {
    try {
      final res = await http.delete(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(_timeout);
      return _decode(res);
    } catch (e) {
      return {'success': false, 'message': 'Connection failed: $e'};
    }
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static Future<UserModel> login(String username, String password) async {
    final res = await _post(AppConstants.loginUrl, {
      'username': username,
      'password': password,
    });
    if (res['success'] == true) return UserModel.fromJson(res);
    throw res['message']?.toString() ?? 'Login failed';
  }

  // ─── Enquiries ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> addEnquiry(
          Map<String, dynamic> data) async =>
      _post(AppConstants.addEnquiryUrl, data);

  static Future<List<EnquiryModel>> getEnquiriesByDate(String date,
      {int? managerId}) async {
    String url = '${AppConstants.getEnquiriesUrl}?date=$date';
    if (managerId != null) url += '&manager_id=$managerId';
    final res = await _get(url);
    if (res['success'] == true) {
      return (res['enquiries'] as List)
          .map((e) => EnquiryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ─── Batch Report ─────────────────────────────────────────────────────────
  static Future<List<BatchReportModel>> getBatchReport(String date) async {
    final res = await _get('${AppConstants.batchReportUrl}?date=$date');
    if (res['success'] == true) {
      return (res['report'] as List)
          .map((e) => BatchReportModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ─── Batches ──────────────────────────────────────────────────────────────
  static Future<List<BatchModel>> getBatches() async {
    final res = await _get(AppConstants.batchesUrl);
    if (res['success'] == true) {
      return (res['batches'] as List)
          .map((e) => BatchModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> addBatch(
          Map<String, dynamic> data) async =>
      _post(AppConstants.batchesUrl, data);

  static Future<Map<String, dynamic>> updateBatch(
          int id, Map<String, dynamic> data) async =>
      _put('${AppConstants.batchesUrl}?id=$id', data);

  static Future<Map<String, dynamic>> deleteBatch(int id) async =>
      _delete('${AppConstants.batchesUrl}?id=$id');

  // ─── Managers ─────────────────────────────────────────────────────────────
  static Future<List<ManagerModel>> getManagers() async {
    final res = await _get(AppConstants.managersUrl);
    if (res['success'] == true) {
      return (res['managers'] as List)
          .map((e) => ManagerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> addManager(
          Map<String, dynamic> data) async =>
      _post(AppConstants.managersUrl, data);

  static Future<Map<String, dynamic>> updateManager(
          int id, Map<String, dynamic> data) async =>
      _put('${AppConstants.managersUrl}?id=$id', data);

  static Future<Map<String, dynamic>> deleteManager(int id) async =>
      _delete('${AppConstants.managersUrl}?id=$id');
}
