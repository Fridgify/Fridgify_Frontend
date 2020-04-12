import 'package:flutter/material.dart';

class ContentMenuPage extends StatefulWidget {
  ContentMenuPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ContentMenuPageState createState() => _ContentMenuPageState();
}

class _ContentMenuPageState extends State<ContentMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Text('Menu')
          ),
        )
    );
  }
}

