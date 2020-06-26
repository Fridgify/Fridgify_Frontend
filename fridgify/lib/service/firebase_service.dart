import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:fridgify/utils/logger.dart';

class FirebaseService {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;

  Logger _logger = Logger('FirebaseService');


  void initState() {
    _logger.i("INITIALISING STATE");

    // Fix for web application because of known Platform._platform issues
    bool ios = false;

    try {
      ios = Platform.isIOS;
    }
    catch(exception){
      _logger.e('Platform error', exception: exception, popup: false);
      ios = false;
    }

    if (ios) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        _logger.i("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        _logger.i("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        _logger.i("onResume: $message");
        // TODO optional
      },
    );

    this.registerNotification(_fcm);
  }

  Future<void> registerNotification(FirebaseMessaging fcm) async {
    UserService _userService = UserService();

    String fcmToken = await fcm.getToken();
    _logger.i("GOT TOKEN $fcmToken");

    // Save it to Firestore
    if (fcmToken != null) {
      _userService.registerNotificationToken(fcmToken);
    }

  }

}