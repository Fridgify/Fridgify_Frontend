class FailedToFetchClientTokenException implements Exception {
  String errMsg() => 'Something went wrong while fetching the client token';
}