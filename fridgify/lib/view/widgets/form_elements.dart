import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';


class AutocompleteTextForm extends StatelessWidget {
  const AutocompleteTextForm({
    Key key,
    @required this.style,
    @required this.controller,
    @required this.obscureText,
    @required this.hintText,
    @required this.validator,
    @required this.suggestions,
  }) : super(key: key);

  final TextStyle style;
  final TextEditingController controller;
  final bool obscureText;
  final String hintText;
  final Function(String p1) validator;
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
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
}

class NumberField extends StatefulWidget {
  const NumberField({
    Key key,
    @required this.style,
    @required this.controller,
    @required this.obscureText,
    @required this.hintText,
    @required this.validator,
    int max, this.maxNumber,
  }) : super(key: key);

  final int maxNumber;
  final TextStyle style;
  final TextEditingController controller;
  final bool obscureText;
  final String hintText;
  final Function(String p1) validator;

  @override
  _NumberFieldState createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 75.0,
        child: TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly,
          ],
          obscureText: widget.obscureText ?? false,
          style: widget.style,
          controller: widget.controller ?? TextEditingController(),
          //_controller.textInputControllerUser,
          validator: (value) => widget.validator(value),
          onChanged: (text) => widget.maxNumber != null ? _checkValue(text) : () => {},
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: widget.hintText ?? "", //"Username",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0))),
        ));
  }

  void _checkValue(String txt) {
    if(int.parse(widget.controller.text) > widget.maxNumber)
    {
      widget.controller.text = widget.maxNumber.toString();
    }
    setState(() {
    });
  }
}

class FormButton extends StatelessWidget {
  const FormButton({
    Key key,
    @required this.context,
    @required this.onPressed,
    @required this.style,
    @required this.text,
  }) : super(key: key);

  final BuildContext context;
  final void Function() onPressed;
  final TextStyle style;
  final String text;

  @override
  Widget build(BuildContext context) {
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
}

class DatePickerText extends StatelessWidget {
  const DatePickerText({
    Key key,
    @required this.style,
    @required this.controller,
    @required this.obscureText,
    @required this.hintText,
    @required this.context,
    @required this.validator,
    @required this.max,
  }) : super(key: key);

  final TextStyle style;
  final TextEditingController controller;
  final bool obscureText;
  final String hintText;
  final BuildContext context;
  final Function(String p1) validator;
  final DateTime max;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 75.0,
        child: TextFormField(
          onTap: () => {
            DatePicker.showDatePicker(context,
                showTitleActions: true,
                minTime: DateTime(1900, 1, 1),
                maxTime: max ??
                    DateTime(DateTime.now().year, DateTime.now().month,
                        DateTime.now().day),
                theme: DatePickerTheme(
                    headerColor: Colors.white,
                    backgroundColor: Colors.white,
                    itemStyle: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    doneStyle: TextStyle(color: Colors.purple, fontSize: 16)),
                onChanged: (date) {}, onConfirm: (date) {
              controller.text =
                  "${date.year}-${date.month < 10 ? "0${date.month}" : date.month}-${date.day < 10 ? "0${date.day}" : date.day}";
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
}

class Label extends StatelessWidget {
  const Label({
    Key key,
    @required this.text,
    @required this.onPressed,
  }) : super(key: key);

  final String text;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
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
                key: key,
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

class FormTextField extends StatelessWidget {
  const FormTextField({
    Key key,
    @required this.style,
    @required this.controller,
    @required this.obscureText,
    @required this.hintText,
    @required this.validator,
  }) : super(key: key);

  final TextStyle style;
  final TextEditingController controller;
  final bool obscureText;
  final String hintText;
  final Function(String p1) validator;

  @override
  Widget build(BuildContext context) {
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
}
