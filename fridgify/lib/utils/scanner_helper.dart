import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan/gen/protos/protos.pb.dart';
import 'package:barcode_scan/gen/protos/protos.pbenum.dart';
import 'package:barcode_scan/platform_wrapper.dart';
import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/model/item.dart';
import 'package:fridgify/utils/logger.dart';
import 'package:fridgify/utils/web_helper.dart';

class ScannerHelper {
  static final ScannerHelper _this = ScannerHelper._internal();

  Logger _logger = Logger('ScannerHelper');
  ItemRepository _itemRepository = ItemRepository();
  WebHelper _webHelper = WebHelper();

  factory ScannerHelper() {
    return _this;
  }

  ScannerHelper._internal();

  Future<dynamic> scan() async {
    var result;
    try {          // !(format == BarcodeFormat.qr || format == BarcodeFormat.aztec ||
      //          format == BarcodeFormat.dataMatrix || format == BarcodeFormat.unknown ||
      //          format == BarcodeFormat.interleaved2of5 || format == BarcodeFormat.pdf417
      result = await BarcodeScanner.scan(options: ScanOptions(
          restrictFormat: [
            BarcodeFormat.code39,
            BarcodeFormat.ean13,
            BarcodeFormat.ean13,
            BarcodeFormat.ean8,
            BarcodeFormat.code93,
            BarcodeFormat.code93,
            BarcodeFormat.code128,
            BarcodeFormat.upce,
          ]));

    }
    catch(exception) {
      _logger.i("CAN'T SCAN IN BROWSER/NO PERMISSION");
      return null;
    }
    _logger.i("SCANNED BARCODE ${result.type}");
    if(result.type == ResultType.Cancelled) {
      return null;
    }
    return result;
  }

  Future<Item> findItem(var result) async {
    _logger.i("LOCATING ITEM ${result.rawContent}");
    if(isValidBarcode(result.format)) {
      _logger.i("FORMAT ${result.format}");
      return await _itemRepository.barcode(result.rawContent.toString());
    }
    return null;
  }

  String getBarcode(var result) {
    _logger.i("LOCATING ITEM ${result.rawContent}");
    if(isValidBarcode(result.format)) {
      _logger.i("FORMAT ${result.format}");

      return result.rawContent.toString();
    }
    return null;
  }

  Future<Item> fetchItem(var result) async {
    Item item;
    _logger.i("SCANNED BARCODE ${result.type}");

    if(result.type == ResultType.Barcode || !(result.type == ResultType.Cancelled)) {
      item = await findItem(result);
      _logger.i("FOUND ITEM $item");
    }
    return item;
  }



    bool isValidBarcode(BarcodeFormat format) {
      return !(format == BarcodeFormat.qr || format == BarcodeFormat.aztec ||
          format == BarcodeFormat.dataMatrix || format == BarcodeFormat.unknown ||
          format == BarcodeFormat.interleaved2of5 || format == BarcodeFormat.pdf417
      );
    }

  Future<void> scanQr() async {

    var result;

    _logger.i("LAUNCHING QR CODE SCANNER");

    try {
      result = await BarcodeScanner.scan(options: ScanOptions(
        restrictFormat: [
          BarcodeFormat.qr,
        ]
      ));
    }
    catch(exception) {
      _logger.e("NO CAMERA PERMISSION");
      return;
    }

    _logger.i("SCANNED BARCODE ${result.type}");

    if((result.type == ResultType.Cancelled)) {
      return null;
    }

    if(result.type == ResultType.Barcode) {
      if(isValidQR(result.format)) {
        _logger.i("$result is QR code with type ${result.rawContent}");
        _webHelper.launchUrl(result.rawContent);
      }
    }
    else {
      _logger.e("INVALID QR-CODE");
    }
  }
  bool isValidQR(BarcodeFormat format) {
    return format == BarcodeFormat.qr;
  }


}