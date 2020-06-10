import 'package:dio/dio.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/utils/logger.dart';

class StatusService {
  static final String _aliveApiUrl = "${Repository.baseURL}ping";
  static final String _versionApiUrl = "${Repository.baseURL}version";

  Dio dio;

  Logger _logger = Logger('StatusService');

  static final StatusService _statusService = StatusService._internal();

  factory StatusService([Dio dio]) {
    _statusService.dio = Repository.getDio(dio);
    return _statusService;
  }

  StatusService._internal();

  Future<bool> isAlive() async {
    var response = await dio.get(_aliveApiUrl);

    _logger.i('CHECKING SERVER STATUS URL: ${response.data}');

    if(response.statusCode == 200) {
      _logger.i('ALIVE ${response.data}');
      return true;
    }
    _logger.e('COULD NOT CONNECT TO SERVER ${response.statusMessage}');
    return false;
  }

  Future<String> getVersion() async {
    var response = await dio.get(_versionApiUrl);

    _logger.i('REQUESTING VERSION FROM URL: ${response.data}');

    if(response.statusCode == 200) {
      _logger.i('VERSION ${response.data}');
      return response.data['version'];
    }
    _logger.e('COULD NOT RECEIVE VERSION ${response.statusMessage}');
    return null;
  }
}