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

    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
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