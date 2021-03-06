import 'package:flutter/material.dart';
import 'package:fridgify/controller/register_controller.dart';
import 'package:fridgify/utils/error_handler.dart';
import 'package:fridgify/view/widgets/form_elements.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final key = GlobalKey<FormState>();
  RegisterController _controller = RegisterController();
  ErrorHandler _errorHandler = ErrorHandler();

  void _updateForm(RegisterController _controller, GlobalKey key,
      BuildContext context) async {
    await _controller.getNextForm(key, context);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _errorHandler.setContext(context);
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Padding(
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
                          SizedBox(height: 20.0),
                          for (var widget in _controller.interactiveForm) widget,
                          SizedBox(height: 20.0),
                          FormButton(
                              key: Key('nextButton'),
                              text: "Next",
                              onPressed: () =>
                                  _updateForm(_controller, key, context),
                              context: this.context,
                              style: this.style),
                        ],
                      ),
                    ),
                  )),
              Column(
                children: <Widget>[
                  Label(
                      text: "ALREAEDY OWN AN ACCOUNT?",
                      key: Key('registerButton'),
                      onPressed: () => Navigator.pop(context)
                  ),
                  Label(
                      text: "DATAPRIVACY",
                      onPressed: () async => await _controller.launchPrivacy()),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
