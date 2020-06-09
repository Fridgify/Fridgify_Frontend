class FailedToAddContentException implements Exception {
  var exe;

  String res;

  FailedToAddContentException({this.exe, this.res});

  String errMsg() => 'Something went wrong while adding content ${exe ?? this.res ?? ""}}';

}