class FailedToFetchApiTokenException implements Exception {
  String errMsg() => 'Something went wrong when fetching ApiToken';
}