import 'package:flutter/material.dart';
import 'package:fridgify/controller/main_controller.dart';
import 'package:fridgify/data/fridge_repository.dart';
import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/data/store_repository.dart';
import 'package:fridgify/model/content.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:fridgify/view/screens/content_menu_screen.dart';
import 'package:fridgify/view/screens/login_screen.dart';
import 'package:fridgify/view/screens/register_screen.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

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
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  MainController _controller = MainController();

  void _incrementCounter() async {
    //var authService = AuthenticationService.register("dennis", "pw", "dennis", "rein", "testmail", "2000-04-25");
    //await authService.register();

    Repository.sharedPreferences = await SharedPreferences.getInstance();

    AuthenticationService authService =
    AuthenticationService.login("testUser", "password");
    await authService.login();
    await authService.fetchApiToken();
    await authService.validateToken();

    UserService userService = UserService();
    FridgeRepository fridgeRepository = FridgeRepository();
    ItemRepository itemRepository = ItemRepository();
    StoreRepository storeRepository = StoreRepository();

    var user = await userService.fetchUser();
    await userService.getUsersForFridge(2);
    user.name = "DuummyXY";

    await userService.update(user, "name", "teeeest");
    await storeRepository.fetchAll();
    await itemRepository.fetchAll();

    var f = await fridgeRepository.fetchAll();

    var id = await fridgeRepository.add(Fridge.create(name: "Test2"));
    await fridgeRepository.delete(id);

    await f[2].contentRepository.fetchAll();
    //id = await f[2].contentRepository.add(Content.create(item: itemRepository.get(6), amount: 2, unit: 'ml', expirationDate: '2020-04-10'));
    //await f[2].contentRepository.delete(id);

    var c = f[2].contentRepository.getAll()[1];
    c.unit = "LUL";

    await f[2].contentRepository.update(c, 'unit', 'tons');
    //await storeRepository.add(Store.create(name: "Lidl"));

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

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
