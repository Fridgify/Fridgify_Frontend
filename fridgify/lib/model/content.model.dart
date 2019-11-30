

import 'package:fridgify/exceptions/failed_to_add_content_exception.dart';
import 'package:fridgify/exceptions/failed_to_fetch_content_exception.dart';
import 'package:fridgify/exceptions/failed_to_remove_content_exception.dart';
import 'package:fridgify/utils/content.dart';
import 'package:http/http.dart';

import '../config.dart';

class ContentModel {
  Future<String> getContent(String token, String id) async {
    var response = await get(Config.API + Config.GET_CONTENT + id,
                  headers: { "Authorization": token});

    if(response.statusCode < 400)
      return response.body;
    Config.logger.i("Fetched Content ${response.body}");
    throw new FailedToFetchContentException();
  }

  Future<void> addContent(String token, String id, Content c) async {
    Config.logger.i("Adding Content ${c.getJson}");


    var response = await post(Config.API + Config.GET_CONTENT + id + "/",
                    headers: { "Authorization": token },
                    body: c.getJson()
                    );

    if(!(response.statusCode < 400))
      throw new FailedToAddContentException();

  }

  Future<void> removeContent(String token, String fId, String itemId )
  async {
    Config.logger.i("Removing Content $itemId from $fId");

    var response = await delete(Config.API + Config.GET_CONTENT + fId + "/" + itemId,
                                headers: {"Authorization": token } );

    if(!(response.statusCode < 400))
      throw new FailedToRemoveContentException();
  }

}