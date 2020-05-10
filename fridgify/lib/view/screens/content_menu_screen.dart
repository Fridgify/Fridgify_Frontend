import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/controller/content_menu_controller.dart';
import 'package:fridgify/data/fridge_repository.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:fridgify/utils/constants.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:fridgify/view/widgets/menu_elements.dart';

class ContentMenuPage extends StatefulWidget {
  ContentMenuPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ContentMenuPageState createState() => _ContentMenuPageState();
}

class _ContentMenuPageState extends State<ContentMenuPage> {
  FridgeRepository _fridgeRepository = FridgeRepository();
  AuthenticationService _authenticationService = AuthenticationService();
  ContentMenuController _controller = ContentMenuController();
  RefreshController _refreshController =  RefreshController(initialRefresh: false);

  Future<void> _handleOptions(String string, BuildContext context) async {

    await _controller.choiceAction(string,  context, _onChanged);


    setState(() {

    });
  }

  void _onRefresh() async{
    // monitor network fetch
    await _authenticationService.initiateRepositories();
    setState(() {

    });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch
    if(await _authenticationService.initiateRepositories())
      setState(() {

      });
    _refreshController.loadComplete();
  }

  void _onChanged() {
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text("Fridgify"),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (string) => _handleOptions(string, context),
              itemBuilder: (BuildContext context){
                return Constants.menuOptions.map((String choice){
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: WaterDropHeader(),
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus mode){
              Widget body ;
              if(mode == LoadStatus.loading){
                body =  CupertinoActivityIndicator();
              }
              return Container(
                height: 55.0,
                child: Center(child:body),
              );
            },
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: Center(
            child:
          MenuElements.carousel(_fridgeRepository.getAll().values.toList(), context, _onChanged, _controller)//MenuElements.fridgeCard(_fridgeRepository.get(2), context)
        ))
    );
  }
}
