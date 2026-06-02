class AppException implements Exception {
  final String message;

  const AppException(this.message);
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class DatabaseException extends AppException {
  const DatabaseException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class PaymentException extends AppException {
  const PaymentException(super.message);
}