class ApiException implements Exception {
  const new(this.message, {this.unauthorized = false});

  final String message;
  final bool unauthorized;

  @override
  String toString() => message;
}
