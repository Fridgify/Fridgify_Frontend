import 'package:fridgify/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class WebHelper {
  static final WebHelper _this = WebHelper._internal();

  Logger _logger = Logger('WebHelper');

  factory WebHelper() {
    return _this;
  }

  WebHelper._internal();

  Future<void> launchUrl(String url) async {
    if(await canLaunch(url)) {
      await launch(url);
    }
    else {
      _logger.e("FAILED TO LAUNCH URL $url");
    }
  }
}