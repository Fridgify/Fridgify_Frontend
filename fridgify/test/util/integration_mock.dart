import 'package:fridgify/service/auth_service.dart';
import 'package:mockito/mockito.dart';

class IntegrationMock {
  static AuthenticationService authService = AuthenticationService();

  static void register() {
    when(authService.register()).thenAnswer((_) => Future.value('token'));
    when(authService.login()).thenAnswer((_) => Future.value('token'));
  }

  static void login() {
    when(authService.login()).thenAnswer((_) => Future.value('token'));
    when(authService.fetchApiToken()).thenAnswer((_) => Future.value('token'));
    when(authService.initiateRepositories())
        .thenAnswer((_) => Future.value(true));
  }
}
