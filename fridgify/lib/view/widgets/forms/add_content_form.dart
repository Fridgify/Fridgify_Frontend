import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/controller/auth.controller.dart';
import 'package:fridgify/view/screens/overview.view.dart';

class AddContentForm extends StatefulWidget {
  AddContentForm();
  @override
  AddContentFormState createState() {
    return AddContentFormState();
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
  TextEditingController _textInputControllerName = TextEditingController();
  TextEditingController _textInputControllerDesc = TextEditingController();

  AddContentFormState();

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
                  onEditingComplete: () => FocusScope.of(context).requestFocus(_firstInputFocusNode),

                  decoration: InputDecoration(
                      hintText: "Content Name"
                  ),
                  controller: _textInputControllerName,
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
                  decoration: InputDecoration(
                      hintText: "Description"
                  ),
                  focusNode: _firstInputFocusNode,
                  controller: _textInputControllerDesc,
                  validator: (value) {
                    if(value.isEmpty)
                      return "Please enter a Description";
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text("Add Content"),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
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