import 'package:flutter/material.dart';
import 'package:fridgify/controller/main_controller.dart';
import 'package:fridgify/view/screens/content_menu_screen.dart';
import 'package:fridgify/view/screens/login_screen.dart';
import 'package:fridgify/view/screens/register_screen.dart';
import 'package:fridgify/view/widgets/loader.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Fridgify',
        routes: <String, WidgetBuilder>{
          '/login': (BuildContext context) => new LoginPage(),
          '/register': (BuildContext context) => new RegisterPage(),
          '/menu': (BuildContext context) => new ContentMenuPage(),
          '/startup': (BuildContext context) => new MyHomePage()

        },
        theme: ThemeData(
          backgroundColor: Colors.white,
          primarySwatch: Colors.purple,
        ),
        home: MyHomePage(
          title: 'Fridgify',
        ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  MainController _controller = MainController();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Loader.showSimpleLoadingDialog(context);
      bool cached = await _controller.initialLaunch(context);

      if (cached) {
        await Navigator.pushNamedAndRemoveUntil(
            context, '/menu', (route) => false);
      } else {
        await Navigator.pushNamedAndRemoveUntil(
            context, '/login', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          child:
        Column(
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
        ]
    ),));
  }
}
