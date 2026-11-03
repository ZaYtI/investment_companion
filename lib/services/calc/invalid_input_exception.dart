class InvalidInputException implements Exception {
  final String message;

  const InvalidInputException(this.message);

  @override
  String toString() => 'InvalidInputException: $message';
}
