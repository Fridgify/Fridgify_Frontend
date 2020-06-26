import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:fridgify/model/content.dart';



class ItemCircularSlider extends StatefulWidget {
  final Content content;

  ItemCircularSlider(this.content);


  @override
  _ItemCircularSliderState createState() => _ItemCircularSliderState(this.content);
}

class _ItemCircularSliderState extends State<ItemCircularSlider> {
  final Content content;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  ValueKey<DateTime> forceRebuild;

  int max;

  _ItemCircularSliderState(this.content) {
    this._controller.text = content.amount.toString();
    max = this.content.maxAmount;
  }

  void _updateLabels(int init, int end, int lapses) {
    setState(() {
      end = (end * (this.content.maxAmount / 300)).toInt();

      this._controller.text = end.toString();
      this.content.amount = end;
    });
  }

  void _checkValue(String text) {
    if(int.parse(this._controller.text) > max)
    {
      this._controller.text = max.toString();
    }
    setState(() {
      this.content.amount = int.parse(_controller.text);
    });

  }

  void _updateSlider() {
    _focusNode.unfocus();
    setState(() {
      this.content.amount = int.parse(_controller.text);
      forceRebuild = ValueKey(DateTime.now());
    });
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: forceRebuild,
        child: Container(child:
        SingleCircularSlider(300, (this.content.amount / this.content.maxAmount * 300).toInt(),
          baseColor: Colors.purple.withAlpha(80),
          handlerColor: Colors.purple.shade600,
          selectionColor: Colors.purple,
          onSelectionChange: _updateLabels,
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  EditableText(
                    backgroundCursorColor: Colors.purple,
                    controller: _controller,
                    cursorColor: Colors.purple,
                    focusNode: _focusNode,
                    style: TextStyle(fontSize: 36.0, color: Colors.purple),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter> [
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (text) => _checkValue(text),
                    onEditingComplete: () => _updateSlider(),



                  ),
                ],
              )),
        )),
      ),
    );
  }
}