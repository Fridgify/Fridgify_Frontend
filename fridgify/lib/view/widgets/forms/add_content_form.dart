import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fridgify/controller/auth.controller.dart';
import 'package:fridgify/controller/content.controller.dart';
import 'package:fridgify/view/screens/content.view.dart';
import 'package:fridgify/view/screens/overview.view.dart';

class AddContentForm extends StatefulWidget {
  ContentController c;
  AddContentForm(this.c);
  @override
  AddContentFormState createState() {
    return AddContentFormState(this.c);
  }
}


// This class holds data related to the form.
class AddContentFormState extends State<AddContentForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  final FocusNode _firstInputFocusNode = new FocusNode();
  final FocusNode _secondInputFocusNode = new FocusNode();
  final FocusNode _thirdInputFocusNode = new FocusNode();
  final FocusNode _fourthInputFocusNode = new FocusNode();
  final FocusNode _fifthInputFocusNode = new FocusNode();

  TextEditingController _textInputControllerName = TextEditingController();
  TextEditingController _textInputControllerDesc = TextEditingController();
  TextEditingController _textInputControllerStore = TextEditingController();
  TextEditingController _textInputControllerAmount = TextEditingController();
  TextEditingController _textInputControllerUnit = TextEditingController();
  TextEditingController _textInputControllerDate = TextEditingController();
  ContentController c;
  AddContentFormState(this.c);

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    // Build a Form widget using the _formKey created above.
    return Container(
        child: Form(
          key: _formKey,
          child: Column(
            key: new Key('add_Content_popup'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  key: new Key("name"),
                  onEditingComplete: () => FocusScope.of(context).requestFocus(_firstInputFocusNode),

                  decoration: InputDecoration(
                      hintText: "Item"
                  ),
                  controller: _textInputControllerName,
                  validator: (value) {
                    if(value.isEmpty)
                      return "Please enter a Item";
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  key: new Key("store"),
                  onEditingComplete: () => FocusScope.of(context).requestFocus(_secondInputFocusNode),
                  decoration: InputDecoration(
                      hintText: "Store"
                  ),
                  focusNode: _firstInputFocusNode,
                  controller: _textInputControllerStore,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  key: new Key("desc"),
                  onEditingComplete: () => FocusScope.of(context).requestFocus(_thirdInputFocusNode),
                  decoration: InputDecoration(
                      hintText: "Description"
                  ),
                  focusNode: _secondInputFocusNode,
                  controller: _textInputControllerDesc,
                  validator: (value) {
                    if(value.isEmpty)
                      return "Please enter a Description";
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  key: new Key("amount"),
                  onEditingComplete: () => FocusScope.of(context).requestFocus(_fourthInputFocusNode),
                  decoration: InputDecoration(
                      hintText: "Amount"
                  ),
                  focusNode: _thirdInputFocusNode,
                  controller: _textInputControllerAmount,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if(value.isEmpty)
                      return "Please enter an Amount";
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  key: new Key("unit"),
                  decoration: InputDecoration(
                      hintText: "Unit"
                  ),
                  focusNode: _fourthInputFocusNode,
                  controller: _textInputControllerUnit,
                  validator: (value) {
                    if(value.isEmpty)
                      return "Please enter an Unit";
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: GestureDetector(
                  child: TextFormField(
                      key: new Key("exp"),
                      decoration: InputDecoration(
                          hintText: "Expiration Date"
                      ),
                    focusNode: null,
                    controller: _textInputControllerDate,
                    )
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  key: new Key("add_con"),
                  child: Text("Add Content"),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      await c.addContent(_textInputControllerName.text, _textInputControllerStore.text, _textInputControllerDesc.text, int.parse(_textInputControllerAmount.text), _textInputControllerUnit.text, _textInputControllerDate.text);
                      List<Widget> cont = await c.getContent();
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ContentView(c.auth, c.id, cont)));

                      //Needs better way of passing Token/Frames!
                      //Needs better way of passing Token/Frames!
                      //Needs better way of passing Token/Frames!
                      //await this.Content.createContent(_textInputControllerName.text, _textInputControllerDesc.text);
                      //List<Widget> frames = await Content.fetchContentsOverview();
                      //Auth auth = Content.auth;

                      // Needed better way of refreshing
                      //Navigator.pop(context);
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => Overview(token: auth.clientToken, frames: frames)));

                    }
                  },
                ),
              )
            ],
          ),
        ));
  }
}