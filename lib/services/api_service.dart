import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import '../models/user_model.dart';
import '../models/models.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 20);

  // ─────────────────────────────────────────────
  // POST
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> _post(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0',
        },
        body: body,
      ).timeout(_timeout);

      print("POST URL: $url");
      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");

      if (res.body.trim().startsWith('<')) {
        return {
          'success': false,
          'message': 'Server returned HTML instead of JSON'
        };
      }

      return jsonDecode(res.body);

    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // ─────────────────────────────────────────────
  // GET
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> _get(String url) async {
    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0',
        },
      ).timeout(_timeout);

      print("GET URL: $url");
      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");

      if (res.body.trim().startsWith('<')) {
        return {
          'success': false,
          'message': 'Server returned HTML instead of JSON'
        };
      }

      return jsonDecode(res.body);

    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // ─────────────────────────────────────────────
  // PUT
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> _put(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await http.put(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0',
        },
        body: body,
      ).timeout(_timeout);

      print("PUT URL: $url");
      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");

      if (res.body.trim().startsWith('<')) {
        return {
          'success': false,
          'message': 'Server returned HTML instead of JSON'
        };
      }

      return jsonDecode(res.body);

    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> _delete(String url) async {
    try {
      final res = await http.delete(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0',
        },
      ).timeout(_timeout);

      print("DELETE URL: $url");
      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");

      if (res.body.trim().startsWith('<')) {
        return {
          'success': false,
          'message': 'Server returned HTML instead of JSON'
        };
      }

      return jsonDecode(res.body);

    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // ─────────────────────────────────────────────
  // AUTH
  // ─────────────────────────────────────────────
  static Future<UserModel?> login(
    String username,
    String password,
  ) async {

    final res = await _post(
      AppConstants.loginUrl,
      {
        'username': username,
        'password': password,
      },
    );

    if (res['success'] == true) {
      return UserModel.fromJson(res);
    }

    throw res['message'] ?? 'Login failed';
  }

  // ─────────────────────────────────────────────
  // ENQUIRIES
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> addEnquiry(
    Map<String, dynamic> data,
  ) {
    return _post(AppConstants.addEnquiryUrl, data);
  }

  static Future<List<EnquiryModel>> getEnquiriesByDate(
    String date, {
    int? managerId,
  }) async {

    String url =
        '${AppConstants.getEnquiriesUrl}?date=$date';

    if (managerId != null) {
      url += '&manager_id=$managerId';
    }

    final res = await _get(url);

    if (res['success'] == true) {
      return (res['enquiries'] as List)
          .map((e) => EnquiryModel.fromJson(e))
          .toList();
    }

    return [];
  }

  // ─────────────────────────────────────────────
  // BATCH REPORT
  // ─────────────────────────────────────────────
  static Future<List<BatchReportModel>> getBatchReport(
    String date,
  ) async {

    final res = await _get(
      '${AppConstants.batchReportUrl}?date=$date',
    );

    if (res['success'] == true) {
      return (res['report'] as List)
          .map((e) => BatchReportModel.fromJson(e))
          .toList();
    }

    return [];
  }

  // ─────────────────────────────────────────────
  // BATCHES
  // ─────────────────────────────────────────────
  static Future<List<BatchModel>> getBatches() async {

    final res = await _get(AppConstants.batchesUrl);

    if (res['success'] == true) {
      return (res['batches'] as List)
          .map((e) => BatchModel.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<Map<String, dynamic>> addBatch(
    Map<String, dynamic> data,
  ) {
    return _post(AppConstants.batchesUrl, data);
  }

  static Future<Map<String, dynamic>> updateBatch(
    int id,
    Map<String, dynamic> data,
  ) {
    return _put(
      '${AppConstants.batchesUrl}?id=$id',
      data,
    );
  }

  static Future<Map<String, dynamic>> deleteBatch(
    int id,
  ) {
    return _delete(
      '${AppConstants.batchesUrl}?id=$id',
    );
  }

  // ─────────────────────────────────────────────
  // MANAGERS
  // ─────────────────────────────────────────────
  static Future<List<ManagerModel>> getManagers() async {

    final res = await _get(AppConstants.managersUrl);

    if (res['success'] == true) {
      return (res['managers'] as List)
          .map((e) => ManagerModel.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<Map<String, dynamic>> addManager(
    Map<String, dynamic> data,
  ) {
    return _post(AppConstants.managersUrl, data);
  }

  static Future<Map<String, dynamic>> updateManager(
    int id,
    Map<String, dynamic> data,
  ) {
    return _put(
      '${AppConstants.managersUrl}?id=$id',
      data,
    );
  }

  static Future<Map<String, dynamic>> deleteManager(
    int id,
  ) {
    return _delete(
      '${AppConstants.managersUrl}?id=$id',
    );
  }
}
