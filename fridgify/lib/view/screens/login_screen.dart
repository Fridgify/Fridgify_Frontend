import 'package:flutter/material.dart';
import 'package:fridgify/controller/login_controller.dart';
import 'package:fridgify/utils/error_handler.dart';
import 'package:fridgify/utils/validator.dart';
import 'package:fridgify/view/screens/register_screen.dart';
import 'package:fridgify/view/widgets/form_elements.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  LoginController _controller = LoginController();
  ErrorHandler _errorHandler = ErrorHandler();
  final key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _errorHandler.setContext(context);
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: SingleChildScrollView(
              child: Form(
                key: key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 155.0,
                      child: Image.asset(
                        "assets/images/logo_full.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 45.0),
                    FormTextField(
                        key: Key('loginUsername'),
                        style: style,
                        controller: _controller.textInputControllerUser,
                        obscureText: false,
                        hintText: 'Username',
                        validator: Validator.validateUser),
                    SizedBox(height: 25.0),
                    FormTextField(
                        key: Key('loginPassword'),
                        style: style,
                        controller: _controller.textInputControllerPass,
                        obscureText: true,
                        hintText: 'Password',
                        validator: Validator.validatePassword),
                    SizedBox(
                      height: 35.0,
                    ),
                    FormButton(
                        key: Key('loginButton'),
                        context: context,
                        style: style,
                        onPressed: () => _controller.login(context, key),
                        text: 'Login'),
                    SizedBox(
                      height: 15.0,
                    ),
                    Label(
                        text: "DON'T HAVE AN ACCOUNT?",
                        key: Key('registerButton'),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
