import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Create a Form widget.
class RegisterForm extends StatefulWidget {
  @override
  RegisterFormState createState() {
    return RegisterFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class RegisterFormState extends State<RegisterForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final FocusNode _firstInputFocusNode = new FocusNode();
  final FocusNode _secondInputFocusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    // Build a Form widget using the _formKey created above.
    return Container(
        padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
        child: Form(
          key: _formKey,
          child: Column(
            key: new Key('register_screen'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.fromLTRB(0, _size.height*0.15, 0, 0)
              ),
              SizedBox(
                height: 50,
                child:
              TextFormField(
                onEditingComplete: () => FocusScope.of(context).requestFocus(_secondInputFocusNode),
                decoration: InputDecoration(
                    hintText: 'Enter your E-Mail',
                    filled: true,
                    border: OutlineInputBorder(),
                    fillColor: Color.fromARGB(255, 210, 210, 210)
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please enter an E-Mail')));
                  }
                  return null;
                },
                key: new Key('emailfield'),
                keyboardType: TextInputType.emailAddress,
                focusNode: _firstInputFocusNode,
              ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, _size.height*.01, 0, 0),
              ),
              SizedBox(
                height: 50,
                child: TextFormField(
                  decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      border: OutlineInputBorder(),
                      fillColor: Color.fromARGB(255, 210, 210, 210)
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please enter a password')));
                    }
                    return null;
                  },

                  obscureText: true,
                  key: new Key('passfield'),
                  keyboardType: TextInputType.visiblePassword,
                  focusNode: _secondInputFocusNode,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, _size.height*.01, 0, 0),
              ),
              SizedBox(
                height: 50,
                child: TextFormField(
                  decoration: InputDecoration(
                      hintText: 'Repeat Password',
                      filled: true,
                      border: OutlineInputBorder(),
                      fillColor: Color.fromARGB(255, 210, 210, 210)
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please enter a password')));
                    }
                    return null;
                  },

                  obscureText: true,
                  key: new Key('rep_passfield'),
                  keyboardType: TextInputType.visiblePassword,
                  focusNode: _secondInputFocusNode,
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, _size.height*.02, 0, 0),
                child: RichText(
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                          text: 'Already own an account?',
                          style: TextStyle(
                              color: Colors.white,
                          ))])),
              ),
              GestureDetector(
                key: new Key('login_lbl'),
                onTap: () => Navigator.pop(context),
                child: Container(
                  child: RichText(
                      text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: 'Sign-In here',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            decoration: TextDecoration.underline)),
                  ])),
                  padding: EdgeInsets.symmetric(vertical: _size.height*0.009),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, _size.height * 0.06, 0, 0),
                child: Center(
                  child: SizedBox(
                    width: 75,
                    height: 75,
                    child: RaisedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false
                        if (_formKey.currentState.validate()) {
                          Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text('Processing Data')));
                        }
                      },
                      color: Colors.green,
                      key: new Key("login_btn"),
                      child: Icon(
                        Icons.play_arrow,
                        size: 50,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.fromLTRB(0, 0, _size.width*0.008, 0),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(75)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: RichText(
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                          text: 'Read our Blog',
                          recognizer: new TapGestureRecognizer()..onTap = () => Scaffold.of(context).showSnackBar(SnackBar(content: Text('Pressed'),)),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              decoration: TextDecoration.underline)),
                      TextSpan(
                          text: ' | ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          )),
                        TextSpan(
                        text: 'Read the AGBs',
                        recognizer: new TapGestureRecognizer()..onTap = () => print('Tap Here onTap'),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            decoration: TextDecoration.underline)),
                      ])),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(_size.height*0.01),
              )
            ],
          ),
        ));
  }
}
class Register extends StatefulWidget {
  Register({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Scaffold(
      body:
      Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(

                image: DecorationImage(
                  image: ExactAssetImage('assets/images/bg.jpg'),
                  fit: BoxFit.fitHeight,
                ),
              ),
              child: BackdropFilter(
                filter: new ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: new Container(
                  decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
                ),
              ),
            ),
            Container(
              color: Color.fromARGB(100, 0, 0, 0),
            ),
            AppBar (
              backgroundColor: Colors.transparent,
              title: Text("Sign-In"),
            ),
            RegisterForm(),
          ]),
    );
  }
}
