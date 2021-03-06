import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/view/widgets/popup.dart';

class ErrorHandler {
  static final ErrorHandler _this = ErrorHandler._internal();

  static BuildContext _currentCtx;

  factory ErrorHandler() {
    return _this;
  }

  ErrorHandler._internal();

  void setContext(BuildContext ctx) {
    _currentCtx = ctx;
  }

  void handleError(Error err) {

  }

  void errorMessage(String msg,{Function callback}) {
    Popups.errorPopup(_currentCtx, msg, callback: callback);
  }

  BuildContext getContext() {
    return _currentCtx;
  }

  bool ctxNotNull() {
    return _currentCtx != null;
  }
}