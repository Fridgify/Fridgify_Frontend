import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/controller/auth.controller.dart';
import 'package:fridgify/controller/fridge.controller.dart';
import 'package:fridgify/utils/validator.dart';
import 'package:fridgify/view/screens/overview.view.dart';
import 'package:fridgify/view/screens/register.view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config.dart';



class LoginForm extends StatefulWidget {
  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class LoginFormState extends State<LoginForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final FocusNode _firstInputFocusNode = new FocusNode();
  final FocusNode _secondInputFocusNode = new FocusNode();
  TextEditingController _textInputControllerMail = TextEditingController();
  TextEditingController _textInputControllerPass = TextEditingController();
  String password = "";
  String mail = "";
  Auth auth;

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    // Build a Form widget using the _formKey created above.
    return Container(
        padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
        child: Form(
          key: _formKey,
          child: Column(
            key: new Key('login_screen'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.fromLTRB(0, _size.height*0.15, 0, 0)
              ),
              SizedBox(
                height: _size.height * 0.12,
                child:
                TextFormField(
                  onEditingComplete: () => FocusScope.of(context).requestFocus(_secondInputFocusNode),
                  decoration: InputDecoration(
                      hintText: 'E-Mail/Username',
                      filled: true,
                      border: OutlineInputBorder(),
                      fillColor: Color.fromARGB(255, 210, 210, 210)
                  ),
                  controller: _textInputControllerMail,
                  validator: (value) {
                    return Validator.validateMail(value);
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
                height: _size.height * 0.12,
                child: TextFormField(
                  decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      border: OutlineInputBorder(),
                      fillColor: Color.fromARGB(255, 210, 210, 210)
                  ),
                  controller: _textInputControllerPass,
                  validator: (value) {
                    return value.isEmpty ? "Please enter a password" : null;
                  },

                  obscureText: true,
                  key: new Key('passfield'),
                  keyboardType: TextInputType.visiblePassword,
                  focusNode: _secondInputFocusNode,
                ),
              ),
              Container(
                child: RichText(
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                          text: 'Need an account?',
                          style: TextStyle(
                            color: Colors.white,
                          ))])),
              ),
              GestureDetector(
                key: new Key('register_lbl'),
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Register())),
                child: Container(
                  child: RichText(
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                            text: 'Sign-Up here',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                decoration: TextDecoration.underline)),
                      ])),
                  padding: EdgeInsets.symmetric(vertical: _size.height*0.009),
                ),
              ),
              GestureDetector(
                key: new Key('forgot_lbl'),
                onTap: () {},
                child: Container(
                  child: RichText(
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                            text: 'Forgot your password?',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                decoration: TextDecoration.underline)),
                      ])),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height * 0.1),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, _size.height * 0.09, 0, 0),
                child: Center(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: RaisedButton(
                      onPressed: () async {
                        // Validate returns true if the form is valid, or false
                        if (_formKey.currentState.validate()) {
                          //Needs better way of passing Token/Frames!
                          //Needs better way of passing Token/Frames!
                          //Needs better way of passing Token/Frames!

                          auth = new Auth(_textInputControllerMail.text, _textInputControllerPass.text);
                          await auth.login();
                          Fridge f = Fridge(auth);
                          List<Widget> frames = await f.fetchFridgesOverview();
                          if(await auth.validateToken()) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Overview(token: auth.clientToken, frames: frames)));
                        }
                      },
                      color: Colors.green,
                      key: new Key("login_btn"),
                      child: Icon(
                        Icons.play_arrow,
                        size: _size.height * 0.09,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.fromLTRB(0, 0, _size.width*0.008, 0),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(_size.height * 0.13)),
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
                            recognizer: new TapGestureRecognizer()..onTap = () async {
                              const url = 'https://fridgify.donkz.dev/';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
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