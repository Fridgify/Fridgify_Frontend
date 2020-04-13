import 'package:fridgify/utils/validator.dart';
import 'package:test/test.dart';

void main() {
  group('Validate user', () {
    test('should return empty message', () {
      expect(Validator.validateUser(''), 'Please enter an username');
    });

    test('should return not unique message', () {
      Validator.userNotUnique = true;
      expect(Validator.validateUser('Test'), 'Username already used');
      Validator.userNotUnique = false;
    });

    test('should return null', () {
      expect(Validator.validateUser('Test'), null);
    });
  });

  group('Validate email', () {
    test('should return empty message', () {
      expect(Validator.validateMail(''), 'Please enter an email');
    });

    test('should return not unique message', () {
      Validator.mailNotUnique = true;
      expect(Validator.validateMail('test@test.com'), 'Email already used');
      Validator.mailNotUnique = false;
    });

    test('should return email invalid message', () {
      var invalidEmails = [
        'Abc.example.com',
        'A@b@c@example.com',
        'a"b',
        'just"not"right@example.com',
        'this is"not\allowed@example.com',
        'this\ still\"not\\allowed@example.com',
        '1234567890123456789012345678901234567890123456789012345678901234+x@example.com',
      ];

      invalidEmails.forEach((email) {
        expect(Validator.validateMail(email), 'Please enter a valid email');
      });
    });

    test('should return null', () {
      var validEmails = [
        'simple@example.com',
        'very.common@example.com',
        'disposable.style.email.with+symbol@example.com',
        'other.email-with-hyphen@example.com',
        'fully-qualified-domain@example.com',
        'user.name+tag+sorting@example.com',
        'x@example.com',
        'example-indeed@strange-example.com',
        'admin@mailserver1',
        'example@s.example',
        'mailhost!username@example.org',
        'user%example.com@example.org',
      ];
      validEmails.forEach((email) {
        expect(Validator.validateMail(email), null);
      });
    });
  });

  group('Validate first name', () {
    test('should return empty message', () {
      expect(Validator.validateFirst(''), 'Please enter a first name');
    });

    test('should return null', () {
      expect(Validator.validateUser('Test'), null);
    });
  });

  group('Validate date', () {
    test('should return empty message', () {
      expect(Validator.validateDate(''), 'Please enter a birthdate');
    });

    test('should return null', () {
      expect(Validator.validateDate('Test'), null);
    });
  });

  group('Validate password', () {
    test('should return empty message', () {
      expect(Validator.validatePassword(''), 'Please enter a password');
    });

    test('should return too short message', () {
      expect(Validator.validatePassword('Brrr'), 'Your password is too short');
    });

    test('should return null', () {
      expect(Validator.validatePassword('TestWithMoreThan6Characters'), null);
    });
  });

  group('Validate password', () {
    test('should return empty message', () {
      expect(Validator.repeatValidatePassword(''), 'Please repeat the password');
    });

    test('should return too short message', () {
      Validator.doNotMatch = true;
      expect(Validator.repeatValidatePassword('Brrrrrr'), 'Password doesn\'t match');
      Validator.doNotMatch = false;
    });

    test('should return null', () {
      expect(Validator.repeatValidatePassword('TestWithMoreThan6Characters'), null);
    });
  });

}
