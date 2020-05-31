import 'package:fridgify/service/auth_service.dart';
import 'package:mockito/mockito.dart';

class MockAuthenticationService extends Mock implements AuthenticationService {}

class IntegrationMock {
  static MockAuthenticationService mockAuthService =
      MockAuthenticationService();

  static void register() {
    when(mockAuthService.register()).thenAnswer((_) => Future.value('token'));
    when(mockAuthService.login()).thenAnswer((_) => Future.value('token'));
  }

  static void login() {
    when(mockAuthService.login()).thenAnswer((_) => Future.value('token'));
    when(mockAuthService.fetchApiToken())
        .thenAnswer((_) => Future.value('token'));
    when(mockAuthService.initiateRepositories())
        .thenAnswer((_) => Future.value(true));
  }
}
