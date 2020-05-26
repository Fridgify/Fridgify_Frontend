import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class FormElements {
  static SizedBox textField(
      {TextStyle style,
      TextEditingController controller,
      bool obscureText,
      String hintText,
      Function(String) validator}) {
    return SizedBox(
        height: 75.0,
        child: TextFormField(
          obscureText: obscureText ?? false,
          style: style,
          controller: controller ?? TextEditingController(),
          //_controller.textInputControllerUser,
          validator: (value) => validator(value),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: hintText ?? "", //"Username",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0))),
        ));
  }

  static SizedBox autocompleteTextForm({
    TextStyle style,
    TextEditingController controller,
    bool obscureText,
    String hintText,
    Function(String) validator,
    List<String> suggestions,
  }) {
    return SizedBox(
        height: 75.0,
        child: SimpleAutoCompleteTextField(
          minLength: 0,
          style: style,
          controller: controller ?? TextEditingController(),
          //_controller.textInputControllerUser,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: hintText ?? "", //"Username",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0))),
          suggestions: suggestions,
          key: GlobalKey(),
        ));
  }

  static SizedBox numberField(
      {TextStyle style,
      TextEditingController controller,
      bool obscureText,
      String hintText,
      Function(String) validator}) {
    return SizedBox(
        height: 75.0,
        child: TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly,
          ],
          obscureText: obscureText ?? false,
          style: style,
          controller: controller ?? TextEditingController(),
          //_controller.textInputControllerUser,
          validator: (value) => validator(value),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: hintText ?? "", //"Username",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0))),
        ));
  }

  static Material button(
      {BuildContext context,
      void Function() onPressed,
      TextStyle style,
      String text}) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color.fromARGB(255, 152, 105, 174),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: onPressed ?? () => {}, //() => _controller.register(context),
        child: Text(text ?? "", //Register",
                textAlign: TextAlign.center,
                style: style?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)) ??
            TextStyle(),
      ),
    );
  }

  static SizedBox datePickerText({
    TextStyle style,
    TextEditingController controller,
    bool obscureText,
    String hintText,
    BuildContext context,
    Function(String) validator,
    DateTime max,
  }) {
    return SizedBox(
        height: 75.0,
        child: TextFormField(
          onTap: () => {
            DatePicker.showDatePicker(context,
                showTitleActions: true,
                minTime: DateTime(1900, 1, 1),
                maxTime: max ?? DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day),
                theme: DatePickerTheme(
                    headerColor: Colors.white,
                    backgroundColor: Colors.white,
                    itemStyle: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    doneStyle: TextStyle(color: Colors.purple, fontSize: 16)),
                onChanged: (date) {}, onConfirm: (date) {
              controller.text = "${date.year}-${date.month < 10 ? "0${date.month}" : date.month}-${date.day}";
            }, currentTime: DateTime.now(), locale: LocaleType.en)
          },
          readOnly: true,
          obscureText: obscureText ?? false,
          style: style,
          controller: controller ?? TextEditingController(),
          //_controller.textInputControllerUser,
          validator: (value) => validator(value),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: hintText ?? "", //"Username",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0))),
        ));
  }

  static Container label({String text, void Function() onPressed}) {
    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: FlatButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.only(left: 20.0),
                  alignment: Alignment.center,
                  child: Text(
                    text ?? "", //"DON'T HAVE AN ACCOUNT?",
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
                onPressed: onPressed ?? () => {} //() =>
                //Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => RegisterPage())),
                ),
          ),
        ],
      ),
    );
  }
}
