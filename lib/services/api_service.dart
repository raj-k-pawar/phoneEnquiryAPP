import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/user_model.dart';
import '../models/models.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 20);

  static Future<Map<String, dynamic>> _post(String url, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _get(String url) async {
    try {
      final res = await http.get(Uri.parse(url)).timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _put(String url, Map<String, dynamic> body) async {
    try {
      final res = await http
          .put(Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _delete(String url) async {
    try {
      final res = await http.delete(Uri.parse(url)).timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ── Auth ──────────────────────────────────────
  static Future<UserModel?> login(String username, String password) async {
    final res = await _post(AppConstants.loginUrl, {
      'username': username, 'password': password,
    });
    if (res['success'] == true) return UserModel.fromJson(res);
    throw res['message'] ?? 'Login failed';
  }

  // ── Enquiries ─────────────────────────────────
  static Future<Map<String, dynamic>> addEnquiry(Map<String, dynamic> data) =>
      _post(AppConstants.addEnquiryUrl, data);

  static Future<List<EnquiryModel>> getEnquiriesByDate(String date, {int? managerId}) async {
    String url = '${AppConstants.getEnquiriesUrl}?date=$date';
    if (managerId != null) url += '&manager_id=$managerId';
    final res = await _get(url);
    if (res['success'] == true) {
      return (res['enquiries'] as List).map((e) => EnquiryModel.fromJson(e)).toList();
    }
    return [];
  }

  // ── Batch Report ──────────────────────────────
  static Future<List<BatchReportModel>> getBatchReport(String date) async {
    final res = await _get('${AppConstants.batchReportUrl}?date=$date');
    if (res['success'] == true) {
      return (res['report'] as List).map((e) => BatchReportModel.fromJson(e)).toList();
    }
    return [];
  }

  // ── Batches ───────────────────────────────────
  static Future<List<BatchModel>> getBatches() async {
    final res = await _get(AppConstants.batchesUrl);
    if (res['success'] == true) {
      return (res['batches'] as List).map((e) => BatchModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> addBatch(Map<String, dynamic> data) =>
      _post(AppConstants.batchesUrl, data);

  static Future<Map<String, dynamic>> updateBatch(int id, Map<String, dynamic> data) =>
      _put('${AppConstants.batchesUrl}?id=$id', data);

  static Future<Map<String, dynamic>> deleteBatch(int id) =>
      _delete('${AppConstants.batchesUrl}?id=$id');

  // ── Managers ──────────────────────────────────
  static Future<List<ManagerModel>> getManagers() async {
    final res = await _get(AppConstants.managersUrl);
    if (res['success'] == true) {
      return (res['managers'] as List).map((e) => ManagerModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> addManager(Map<String, dynamic> data) =>
      _post(AppConstants.managersUrl, data);

  static Future<Map<String, dynamic>> updateManager(int id, Map<String, dynamic> data) =>
      _put('${AppConstants.managersUrl}?id=$id', data);

  static Future<Map<String, dynamic>> deleteManager(int id) =>
      _delete('${AppConstants.managersUrl}?id=$id');
}
