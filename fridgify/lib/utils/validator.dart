class Validator {

  static String validateMail(String text) {
    if(text.isEmpty)
      return 'Please enter an E-Mail';
    RegExp exp = new RegExp(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)");
    if(!exp.hasMatch(text))
      return 'Please enter a valid E-Mail';
    return null;
  }

  static String validatePassword(String text) {
    if(text.isEmpty)
      return 'Please enter a Password!';
    if(text.length < 6)
      return 'Your password is too short';
    return null;
  }
}