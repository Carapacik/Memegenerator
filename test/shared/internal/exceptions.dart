class ExpectException implements Exception {
  const ExpectException(this.message);

  final String message;

  @override
  String toString() {
    return 'ExpectException{message: $message}';
  }
}
