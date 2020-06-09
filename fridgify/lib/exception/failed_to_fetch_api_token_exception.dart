class FailedToFetchApiTokenException implements Exception {
  String errMsg() => 'Something went wrong while fetching ApiToken';
}