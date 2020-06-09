import 'package:auto_size_text/auto_size_text.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/controller/fridge_detail_controller.dart';
import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/utils/constants.dart';
import 'package:fridgify/utils/error_handler.dart';
import 'package:fridgify/utils/item_state_helper.dart';

class FridgeDetailPage extends StatefulWidget {
  FridgeDetailPage({Key key, this.fridge}) : super(key: key);
  final Fridge fridge;

  @override
  _FridgeDetailPageState createState() =>
      _FridgeDetailPageState(fridge: this.fridge);
}

class _FridgeDetailPageState extends State<FridgeDetailPage> {
  final Fridge fridge;
  final List<ExpandableController> _controllerCollection = List();
  ErrorHandler _errorHandler = ErrorHandler();

  FridgeDetailController _controller;

  _FridgeDetailPageState({this.fridge}) {
    _controller = FridgeDetailController(setState, this.fridge);
  }

  @override
  Widget build(BuildContext context) {
    _errorHandler.setContext(context);
    _controller.contents = fridge.contentRepository.getAll().values.toList();


    return Scaffold(
        appBar: new AppBar(
          title: new Text("Fridgify"),
          actions: _controller.isEditMode
              ? <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    onPressed: () => _controller.deleteSelection(context),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.white,
                    ),
                    onPressed: _controller.cancelSelection,
                  ),
                ]
              : [
                  PopupMenuButton<String>(
                    onSelected: (string) =>
                        _controller.handleOptions(string, context),
                    itemBuilder: (BuildContext context) {
                      return _controller.isOwner(this.fridge) ?
                      Constants.ownerDetailOptions.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList()
                          : Constants.detailOptions.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  )
                ],
        ),
        body: ListView.separated(
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey,
            indent: 10,
            endIndent: 10,
          ),
          itemCount: fridge.contentRepository.getAsGroup().length,
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          itemBuilder: (context, index) {
            var key =
                fridge.contentRepository.getAsGroup().keys.toList()[index];
            var group = fridge.contentRepository.getAsGroup()[key];
            if(_controllerCollection.asMap().containsKey(index) == false) _controllerCollection.add(ExpandableController());
            return ExpandablePanel(
              controller: _controllerCollection[index],
              header: ListTile(
                onLongPress: () => _controller.selectGroup(group),
                onTap: () => _controller.groupTap(group, _controllerCollection[index]),
                title: AutoSizeText(key,
                    style: TextStyle(
                        fontFamily: 'Montserrat', fontSize: 20.0), maxLines: 2,),
                trailing:
                Text('x${group.length}',
                    style: TextStyle(
                        fontFamily: 'Montserrat', fontSize: 20.0)),
              ),
              expanded: ListView.builder(
                  shrinkWrap: true,
                  itemCount: group.length,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index2) {
                    return ListTile(
                      title: AutoSizeText(group[index2].item.name,
                          style: TextStyle(
                              fontFamily: 'Montserrat', fontSize: 16.0), maxLines: 2,),
                      trailing:
                      Text(
                          '${group[index2].amount.toString()} ${group[index2].unit.toString()}',
                          style: TextStyle(
                              fontFamily: 'Montserrat', fontSize: 16.0)),
                      onTap: () => _controller.tileTapped(
                          fridge.contentRepository, group[index2], context),
                      isThreeLine: true,
                      subtitle: Slider(
                        min: 0,
                        max: group[index2].maxAmount.toDouble(),
                        activeColor: group[index2].state.color,
                        value: group[index2].amount.toDouble(),
                        onChangeStart: (double value) => _controller.tileTapped(
                            fridge.contentRepository, group[index2], context),
                        onChanged: (double value) {},
                      ),
                      selected: _controller.isSelected(group[index2]),
                      onLongPress: () =>
                          _controller.toggleSelection(group[index2]),
                    );
                  }),
            );
          },
        ));
  }
}
