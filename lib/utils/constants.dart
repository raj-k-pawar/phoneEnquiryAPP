// lib/utils/constants.dart

class AppConstants {
  static const String baseUrl = 'https://jankibooking.infinityfree.me/api';

  // API endpoints
  static const String loginUrl        = '$baseUrl/login.php';
  static const String addEnquiryUrl   = '$baseUrl/add_enquiry.php';
  static const String getEnquiriesUrl = '$baseUrl/get_enquiries_by_date.php';
  static const String batchReportUrl  = '$baseUrl/get_batchwise_report.php';
  static const String batchesUrl      = '$baseUrl/batches.php';
  static const String managersUrl     = '$baseUrl/managers.php';

  // SharedPreferences keys
  static const String keyToken    = 'auth_token';
  static const String keyRole     = 'user_role';
  static const String keyUserId   = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUsername = 'username';
}

class AppColors {
  static const int primaryValue      = 0xFF2D6A4F;
  static const int primaryDarkValue  = 0xFF1B4332;
  static const int primaryLightValue = 0xFF52B788;
  static const int accentValue       = 0xFFD4A017;
  static const int bgValue           = 0xFFF8FBF8;
}
