import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:metadata_fetch/metadata_fetch.dart';

class Utilities {
  static void launchUrl(String url) {
    if (url == null || url.compareTo("") == 0)
      showToast("Link Not Available");
    else {
      launch(url);
    }
  }

  static showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static Future<String> getTitle(String url) async {
    try {
      var response = await http.get(url);
      var document = responseToDocument(response);
      var data = MetadataParser.parse(document);
      return data.title;
    } catch (e) {
      Utilities.showToast("Invalid url");
      return null;
    }
  }
}
