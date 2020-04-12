import 'package:flutter/material.dart';
import 'package:fridgify/controller/login_controller.dart';
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
  final key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                    FormElements.textField(
                        style: style,
                        controller: _controller.textInputControllerUser,
                        obscureText: false,
                        hintText: 'Username',
                        validator: Validator.validateUser),
                    SizedBox(height: 25.0),
                    FormElements.textField(
                        style: style,
                        controller: _controller.textInputControllerPass,
                        obscureText: true,
                        hintText: 'Password',
                        validator: Validator.validatePassword),
                    SizedBox(
                      height: 35.0,
                    ),
                    FormElements.button(
                        context: context,
                        style: style,
                        onPressed: () => _controller.login(context, key),
                        text: 'Login'),
                    SizedBox(
                      height: 15.0,
                    ),
                    FormElements.label(
                        text: "DON'T HAVE AN ACCOUNT?",
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
