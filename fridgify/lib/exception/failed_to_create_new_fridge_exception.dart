class FailedToCreateNewFridgeException implements Exception {
  String res;

  FailedToCreateNewFridgeException(this.res);

  String errMsg() => 'Something went wrong while trying to join/add Fridge $res}';
}