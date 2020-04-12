class Validator {
  static bool userNotUnique = false;
  static bool mailNotUnique = false;
  static bool doNotMatch = true;

  static String validateMail(String text) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);

    if(text.isEmpty) {
      return 'Please enter an E-Mail';
    }

    if( (!regex.hasMatch(text))) {
      return 'Please enter a valid E-Mail';
    }

    if(mailNotUnique) {
      return 'E-Mail already used';
    }
    //RegExp exp = new RegExp(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)");
    //if(!exp.hasMatch(text))
    //  return 'Please enter a valid E-Mail';
    return null;
  }

  static String validateUser(String text) {
    if(text.isEmpty) {
      return 'Please enter an Username';
    }
    if(userNotUnique) {
      return 'Username already used';
    }
    return null;
  }

  static String validateName(String text) {
    if(text.isEmpty) {
      return 'Please enter an Name';
    }
    if(userNotUnique) {
      return 'Username already used';
    }
    return null;
  }

  static String validateFirst(String text) {
    if(text.isEmpty) {
      return 'Please enter an First Name';
    }
    if(userNotUnique) {
      return 'Username already used';
    }
    return null;
  }

  static String validateDate(String text) {
    if(text.isEmpty) {
      return 'Please enter an Birthdate';
    }
    if(userNotUnique) {
      return 'Username already used';
    }
    return null;
  }

  static String validatePassword(String text) {
    if(text.isEmpty) {
      return 'Please enter a Password!';
    }
    if(text.length < 6)
      return 'Your password is too short';
    return null;
  }

  static String repeatValidatePassword(String text) {
    if(text.isEmpty) {
      return 'Please repeat the Password!';
    }
    if(doNotMatch) {
      return 'Password do not match!';
    }
    return null;
  }
}