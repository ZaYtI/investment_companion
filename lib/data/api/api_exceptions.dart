class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class NoNetworkException extends ApiException {
  const NoNetworkException() : super('Pas de connexion internet.');
}

class NetworkTimeoutException extends ApiException {
  const NetworkTimeoutException()
    : super('Le serveur met trop de temps à répondre.');
}

class QuotaExceededException extends ApiException {
  const QuotaExceededException()
    : super('Trop de demandes. Réessayez dans une minute.');
}

class UnknownSymbolException extends ApiException {
  const UnknownSymbolException(String symbol)
    : super('Le symbole $symbol est inconnu.');
}

class InvalidResponseException extends ApiException {
  const InvalidResponseException() : super('Réponse du serveur illisible.');
}
