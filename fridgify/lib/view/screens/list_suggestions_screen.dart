import 'package:flutter/material.dart';

class ListSuggestionsScreen extends StatefulWidget {
  final String title;
  final List<String> items;
  final TextEditingController controller;
  final String placeholder;

  ListSuggestionsScreen(this.title, this.placeholder, this.items, this.controller);

  @override
  _ListSuggestionsScreenState createState() => _ListSuggestionsScreenState(this.title, this.placeholder, this.items, this.controller);
}

class _ListSuggestionsScreenState extends State<ListSuggestionsScreen> {
  final String title;
  final List<String> items;
  final TextEditingController controller;
  final String placeholder;
  Widget inputField;

  List<Widget> widgets = List();

  _ListSuggestionsScreenState(this.title, this.placeholder, this.items, this.controller) {
    widgets = List();
    widgets.addAll(filter());
    inputField = ListTile(
      title: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: this.placeholder,
      ),
    ));
  }

  @override
  void initState() {
    super.initState();

    controller.addListener(update);
  }

  List<Widget> filter() {
    return this.items.where((element) => element.toLowerCase().contains(controller.text.toLowerCase())).map((e) => ListTile(
      title: Text(e),
      onTap: () {
        controller.text = e;
        Navigator.of(context).pop(e);
      },
    )).toList();
  }
  
  void update() {
    widgets = List();
    widgets.addAll(filter());
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.separated(
          itemBuilder: (context, index) => index == 0 ? inputField : widgets[index-1],
          separatorBuilder: (context, index) => Divider(),
          itemCount: widgets.length+1
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.check,
        ),
        onPressed: () => Navigator.of(context).pop(controller.text),
      ),

    );
  }
}
