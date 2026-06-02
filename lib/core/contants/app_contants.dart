class AppConstants {
  AppConstants._();

  // APP INFO
  static const String appName = 'MoBurger';
  static const String appVersion = '1.0.0';

  // USER ROLES
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';

  // ORDER STATUS
  static const String orderPending = 'pending';
  static const String orderProcessing = 'processing';
  static const String orderCompleted = 'completed';
  static const String orderCancelled = 'cancelled';

  // PAYMENT STATUS
  static const String paymentPending = 'pending';
  static const String paymentSuccess = 'success';
  static const String paymentFailed = 'failed';
  static const String paymentExpired = 'expired';

  // PAGINATION
  static const int defaultPageSize = 10;

  // VALIDATION
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;

  // DATE FORMAT
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';
  static const String dateFormatShort = 'dd/MM/yy';
  static const String timeFormat = 'HH:mm';
}