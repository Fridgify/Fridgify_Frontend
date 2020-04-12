class NotUniqueException implements Exception {
  bool user = false;
  bool mail = false;

  NotUniqueException({this.user, this.mail});
}