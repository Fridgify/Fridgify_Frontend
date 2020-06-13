class FailedToFetchClientTokenException implements Exception {
  String err;

  FailedToFetchClientTokenException();

  FailedToFetchClientTokenException.withErr(this.err);

  String errMsg() => err ?? 'Something went wrong while fetching the client token';

  @override
  String toString() {
    return errMsg();
  }
}